// Edge Function: restaurant-detail
// POST { restaurantId } | { googlePlaceId }
// → { restaurant, photos, foreignerFactors }
//
// Fetches a single restaurant's full detail, refreshing from Google if stale.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders, handleCors } from '../_shared/cors.ts';
import { getPlaceDetail } from '../_shared/google_places.ts';
import { normalizePlace } from '../_shared/normalizer.ts';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

const STALE_AFTER_MS = 6 * 60 * 60 * 1000; // 6 hours

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { restaurantId, googlePlaceId } = await req.json();

    if (!restaurantId && !googlePlaceId) {
      return jsonError('restaurantId or googlePlaceId required', 400);
    }

    // ── 1. Load from DB ───────────────────────────────────────────────────────
    let query = supabase.from('restaurants').select('*');
    if (restaurantId) query = query.eq('id', restaurantId);
    else query = query.eq('google_place_id', googlePlaceId);

    const { data: restaurant } = await query.single();

    const isStale =
      !restaurant?.last_synced_at ||
      Date.now() - new Date(restaurant.last_synced_at).getTime() > STALE_AFTER_MS;

    let enriched = restaurant;

    // ── 2. Refresh from Google Places if stale ────────────────────────────────
    if (isStale && (restaurant?.google_place_id ?? googlePlaceId)) {
      const placeId = restaurant?.google_place_id ?? googlePlaceId;
      try {
        const place = await getPlaceDetail(placeId);
        const normalized = normalizePlace(place);
        const { photos, ...row } = normalized;

        const { data: updated } = await supabase
          .from('restaurants')
          .upsert(
            { ...row, last_synced_at: new Date().toISOString() },
            { onConflict: 'google_place_id' }
          )
          .select('*')
          .single();

        enriched = updated ?? enriched;

        // Replace Google photos
        if (enriched?.id && photos.length > 0) {
          await supabase
            .from('restaurant_photos')
            .delete()
            .eq('restaurant_id', enriched.id)
            .eq('source', 'google');

          await supabase.from('restaurant_photos').insert(
            photos.map((p) => ({ ...p, restaurant_id: enriched.id }))
          );
        }
      } catch (e) {
        console.warn('Google Places refresh failed, using cached data:', e);
      }
    }

    if (!enriched) return jsonError('Restaurant not found', 404);

    // ── 3. Load photos ────────────────────────────────────────────────────────
    const { data: photos } = await supabase
      .from('restaurant_photos')
      .select('*')
      .eq('restaurant_id', enriched.id)
      .order('sort_order');

    // ── 4. Load foreigner factors ─────────────────────────────────────────────
    const { data: factors } = await supabase
      .from('restaurant_foreigner_factors')
      .select('*')
      .eq('restaurant_id', enriched.id)
      .single();

    return json({ restaurant: enriched, photos: photos ?? [], foreignerFactors: factors });
  } catch (err) {
    console.error('restaurant-detail error:', err);
    return jsonError('Internal server error', 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function jsonError(message: string, status: number): Response {
  return json({ error: message }, status);
}
