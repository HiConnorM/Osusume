class RestaurantPhoto {
  final String id;
  final String restaurantId;
  final String source;
  final String? sourcePhotoRef;
  final String displayUrl;
  final String? attributionText;
  final String? attributionUrl;
  final int? width;
  final int? height;
  final bool isPrimary;
  final int sortOrder;

  const RestaurantPhoto({
    required this.id,
    required this.restaurantId,
    required this.source,
    this.sourcePhotoRef,
    required this.displayUrl,
    this.attributionText,
    this.attributionUrl,
    this.width,
    this.height,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory RestaurantPhoto.fromJson(Map<String, dynamic> json) {
    return RestaurantPhoto(
      id: json['id'] as String? ?? '',
      restaurantId: json['restaurant_id'] as String? ?? '',
      source: json['source'] as String? ?? 'google',
      sourcePhotoRef: json['source_photo_ref'] as String?,
      displayUrl: json['display_url'] as String,
      attributionText: json['attribution_text'] as String?,
      attributionUrl: json['attribution_url'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  bool get needsAttribution =>
      source == 'google' && attributionText != null && attributionText!.isNotEmpty;
}
