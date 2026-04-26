// Converts raw Google Places data into the normalized Osusume restaurant shape
// that both the database and the Flutter app consume.

import { GooglePlace, priceLevelInt, photoUrl } from './google_places.ts';

export interface NormalizedRestaurant {
  google_place_id: string;
  name_en: string;
  address: string;
  latitude: number;
  longitude: number;
  google_rating: number | null;
  google_review_count: number | null;
  price_level: number;
  is_open_now: boolean | null;
  phone: string | null;
  website: string | null;
  google_maps_url: string | null;
  cuisine_type: string;
  opening_hours_text: string[];
  photos: NormalizedPhoto[];
}

export interface NormalizedPhoto {
  source: 'google';
  source_photo_ref: string;
  display_url: string;
  attribution_text: string;
  attribution_url: string;
  width: number;
  height: number;
  is_primary: boolean;
  sort_order: number;
}

export function normalizePlace(place: GooglePlace): NormalizedRestaurant {
  const photos: NormalizedPhoto[] = (place.photos ?? [])
    .slice(0, 10)
    .map((p, i) => ({
      source: 'google' as const,
      source_photo_ref: p.name,
      display_url: photoUrl(p.name, 800),
      attribution_text: p.authorAttributions[0]?.displayName ?? 'Google',
      attribution_url: p.authorAttributions[0]?.uri ?? 'https://maps.google.com',
      width: p.widthPx,
      height: p.heightPx,
      is_primary: i === 0,
      sort_order: i,
    }));

  return {
    google_place_id: place.id,
    name_en: place.displayName.text,
    address: place.formattedAddress,
    latitude: place.location.latitude,
    longitude: place.location.longitude,
    google_rating: place.rating ?? null,
    google_review_count: place.userRatingCount ?? null,
    price_level: priceLevelInt(place.priceLevel),
    is_open_now: place.currentOpeningHours?.openNow ?? null,
    phone: place.nationalPhoneNumber ?? null,
    website: place.websiteUri ?? null,
    google_maps_url: place.googleMapsUri ?? null,
    cuisine_type: mapCuisineType(place.types ?? [], place.primaryType),
    opening_hours_text: place.regularOpeningHours?.weekdayDescriptions ?? [],
    photos,
  };
}

function mapCuisineType(types: string[], primaryType?: string): string {
  const typeMap: Record<string, string> = {
    ramen_restaurant: 'Ramen',
    sushi_restaurant: 'Sushi',
    japanese_restaurant: 'Japanese',
    izakaya_restaurant: 'Izakaya',
    yakitori_restaurant: 'Yakitori',
    tempura_restaurant: 'Tempura',
    tonkatsu_restaurant: 'Tonkatsu',
    cafe: 'Café',
    coffee_shop: 'Café',
    bar: 'Bar',
    italian_restaurant: 'Italian',
    chinese_restaurant: 'Chinese',
    korean_restaurant: 'Korean',
    fast_food_restaurant: 'Fast Food',
    restaurant: 'Restaurant',
  };

  if (primaryType && typeMap[primaryType]) return typeMap[primaryType];
  for (const t of types) {
    if (typeMap[t]) return typeMap[t];
  }
  return 'Restaurant';
}
