// Google Places API (New) helper utilities.
// Docs: https://developers.google.com/maps/documentation/places/web-service/overview

const PLACES_BASE = 'https://places.googleapis.com/v1';
const API_KEY = Deno.env.get('GOOGLE_PLACES_API_KEY') ?? '';

export interface PlacesSearchResult {
  places: GooglePlace[];
}

export interface GooglePlace {
  id: string;
  displayName: { text: string; languageCode: string };
  formattedAddress: string;
  location: { latitude: number; longitude: number };
  rating?: number;
  userRatingCount?: number;
  priceLevel?: string;  // PRICE_LEVEL_FREE | _INEXPENSIVE | _MODERATE | _EXPENSIVE | _VERY_EXPENSIVE
  currentOpeningHours?: { openNow: boolean; weekdayDescriptions: string[] };
  regularOpeningHours?: { weekdayDescriptions: string[] };
  nationalPhoneNumber?: string;
  websiteUri?: string;
  types?: string[];
  photos?: GooglePlacePhoto[];
  editorialSummary?: { text: string };
  primaryType?: string;
  googleMapsUri?: string;
}

export interface GooglePlacePhoto {
  name: string;                    // e.g. "places/{id}/photos/{ref}"
  widthPx: number;
  heightPx: number;
  authorAttributions: { displayName: string; uri: string; photoUri: string }[];
}

// ─── Nearby search ───────────────────────────────────────────────────────────

export async function searchNearby(
  lat: number,
  lng: number,
  radiusM: number = 2000,
  maxResults: number = 20,
): Promise<GooglePlace[]> {
  const body = {
    includedTypes: ['restaurant', 'food', 'cafe', 'bar'],
    maxResultCount: Math.min(maxResults, 20),
    locationRestriction: {
      circle: {
        center: { latitude: lat, longitude: lng },
        radius: radiusM,
      },
    },
    rankPreference: 'POPULARITY',
  };

  const res = await fetch(`${PLACES_BASE}/places:searchNearby`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': API_KEY,
      'X-Goog-FieldMask': placeFieldMask(),
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) throw new Error(`Google Places nearby search failed: ${res.status}`);
  const data: PlacesSearchResult = await res.json();
  return data.places ?? [];
}

// ─── Text search (keyword) ────────────────────────────────────────────────────

export async function searchByText(
  query: string,
  lat?: number,
  lng?: number,
): Promise<GooglePlace[]> {
  const body: Record<string, unknown> = {
    textQuery: query,
    maxResultCount: 20,
    languageCode: 'en',
  };

  if (lat !== undefined && lng !== undefined) {
    body.locationBias = {
      circle: {
        center: { latitude: lat, longitude: lng },
        radius: 5000,
      },
    };
  }

  const res = await fetch(`${PLACES_BASE}/places:searchText`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': API_KEY,
      'X-Goog-FieldMask': placeFieldMask(),
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) throw new Error(`Google Places text search failed: ${res.status}`);
  const data: PlacesSearchResult = await res.json();
  return data.places ?? [];
}

// ─── Place detail ─────────────────────────────────────────────────────────────

export async function getPlaceDetail(placeId: string): Promise<GooglePlace> {
  const res = await fetch(`${PLACES_BASE}/places/${placeId}`, {
    headers: {
      'X-Goog-Api-Key': API_KEY,
      'X-Goog-FieldMask': placeFieldMask(true),
    },
  });

  if (!res.ok) throw new Error(`Google Places detail failed: ${res.status}`);
  return res.json();
}

// ─── Photo URL ────────────────────────────────────────────────────────────────

export function photoUrl(photoName: string, maxWidth = 800): string {
  return `${PLACES_BASE}/${photoName}/media?maxWidthPx=${maxWidth}&key=${API_KEY}&skipHttpRedirect=false`;
}

// ─── Price level mapping ──────────────────────────────────────────────────────

export function priceLevelInt(level?: string): number {
  return {
    PRICE_LEVEL_FREE: 1,
    PRICE_LEVEL_INEXPENSIVE: 1,
    PRICE_LEVEL_MODERATE: 2,
    PRICE_LEVEL_EXPENSIVE: 3,
    PRICE_LEVEL_VERY_EXPENSIVE: 4,
  }[level ?? ''] ?? 2;
}

// ─── Field mask ───────────────────────────────────────────────────────────────

function placeFieldMask(includeDetails = false): string {
  const base = [
    'places.id',
    'places.displayName',
    'places.formattedAddress',
    'places.location',
    'places.rating',
    'places.userRatingCount',
    'places.priceLevel',
    'places.currentOpeningHours.openNow',
    'places.nationalPhoneNumber',
    'places.websiteUri',
    'places.types',
    'places.primaryType',
    'places.googleMapsUri',
    'places.photos',
  ];

  const detailed = [
    'places.regularOpeningHours.weekdayDescriptions',
    'places.editorialSummary',
  ];

  return (includeDetails ? [...base, ...detailed] : base).join(',');
}
