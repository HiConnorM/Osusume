// Edge Function: search-restaurants
// POST { lat, lng, radiusM?, query?, filter? }
// → { restaurants: NormalizedRestaurant[] }
//
// Pipeline:
//   1. Check Supabase DB cache (restaurants within radius, synced < 24h ago)
//   2. If stale or empty → call Google Places API
//   3. Upsert normalized results into DB
//   4. Return enriched results to app

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders, handleCors } from '../_shared/cors.ts';
import { searchNearby, searchByText } from '../_shared/google_places.ts';
import { normalizePlace } from '../_shared/normalizer.ts';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { lat, lng, radiusM = 2000, query, filter } = await req.json();

    if (typeof lat !== 'number' || typeof lng !== 'number') {
      return jsonError('lat and lng are required', 400);
    }

    // ── 1. Check DB cache ────────────────────────────────────────────────────
    const cacheThreshold = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { data: cached } = await supabase
      .rpc('restaurants_near', { lat, lng, radius_m: radiusM, result_limit: 30 });

    const freshEnough = cached?.some(
      (r: { last_synced_at: string }) =>
        r.last_synced_at && r.last_synced_at > cacheThreshold
    );

    let restaurants = cached ?? [];

    // ── 2. Refresh from Google Places if cache is stale ──────────────────────
    if (!freshEnough) {
      const places = query
        ? await searchByText(query, lat, lng)
        : await searchNearby(lat, lng, radiusM);

      const normalized = places.map(normalizePlace);

      // ── 3. Upsert into DB ─────────────────────────────────────────────────
      for (const r of normalized) {
        const { photos, opening_hours_text, ...restaurantRow } = r;

        const { data: upserted } = await supabase
          .from('restaurants')
          .upsert(
            { ...restaurantRow, last_synced_at: new Date().toISOString() },
            { onConflict: 'google_place_id', ignoreDuplicates: false }
          )
          .select('id')
          .single();

        if (upserted?.id && photos.length > 0) {
          // Replace photos (delete old, insert fresh — URLs can expire)
          await supabase
            .from('restaurant_photos')
            .delete()
            .eq('restaurant_id', upserted.id)
            .eq('source', 'google');

          await supabase.from('restaurant_photos').insert(
            photos.map((p) => ({ ...p, restaurant_id: upserted.id }))
          );
        }
      }

      // Re-fetch from DB so response includes DB IDs
      const { data: refreshed } = await supabase
        .rpc('restaurants_near', { lat, lng, radius_m: radiusM, result_limit: 30 });

      restaurants = refreshed ?? normalized;
    }

    // ── 4. Apply client-side filter ──────────────────────────────────────────
    const filtered = applyFilter(restaurants, filter);

    // ── 5. Attach photos to each restaurant ──────────────────────────────────
    const ids = filtered.map((r: { id: string }) => r.id).filter(Boolean);
    const { data: photos } = ids.length > 0
      ? await supabase
          .from('restaurant_photos')
          .select('*')
          .in('restaurant_id', ids)
          .order('sort_order')
      : { data: [] };

    const photosByRestaurant: Record<string, unknown[]> = {};
    for (const p of photos ?? []) {
      const rid = (p as { restaurant_id: string }).restaurant_id;
      if (!photosByRestaurant[rid]) photosByRestaurant[rid] = [];
      photosByRestaurant[rid].push(p);
    }

    const enriched = filtered.map((r: { id: string }) => ({
      ...r,
      photos: photosByRestaurant[r.id] ?? [],
    }));

    return json({ restaurants: enriched });
  } catch (err) {
    console.error('search-restaurants error:', err);
    return jsonError('Internal server error', 500);
  }
});

function applyFilter(restaurants: unknown[], filter?: string) {
  if (!filter || filter === 'all') return restaurants;
  return (restaurants as Record<string, unknown>[]).filter((r) => {
    switch (filter) {
      case 'open_now':   return r.is_open_now === true;
      case 'budget':     return (r.price_level as number) <= 2;
      case 'top_rated':  return (r.google_rating as number) >= 4.5;
      default:           return true;
    }
  });
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function jsonError(message: string, status: number): Response {
  return json({ error: message }, status);
}
