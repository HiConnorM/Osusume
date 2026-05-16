import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/remote/restaurant_photo_model.dart';
import '../../core/theme/app_colors.dart';

class PhotoGallery extends StatefulWidget {
  final List<RestaurantPhoto> photos;
  final double height;
  final String? fallbackImageUrl;
  final BoxFit fit;

  const PhotoGallery({
    super.key,
    required this.photos,
    this.height = 220,
    this.fallbackImageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;

    if (photos.isEmpty) {
      return _Placeholder(
        height: widget.height,
        imageUrl: widget.fallbackImageUrl,
        fit: widget.fit,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return _PhotoTile(photo: photos[index], fit: widget.fit);
            },
          ),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: _PageDots(count: photos.length, current: _current),
          ),
        if (photos[_current].needsAttribution)
          Positioned(
            bottom: photos.length > 1 ? 28 : 8,
            right: 8,
            child: _AttributionBadge(photo: photos[_current]),
          ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final RestaurantPhoto photo;
  final BoxFit fit;

  const _PhotoTile({required this.photo, required this.fit});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: photo.displayUrl,
      fit: fit,
      width: double.infinity,
      placeholder: (_, _) => _shimmer(),
      errorWidget: (_, _, _) => _errorBox(),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      );

  Widget _errorBox() => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.restaurant, color: Colors.grey, size: 40),
        ),
      );
}

class _Placeholder extends StatelessWidget {
  final double height;
  final String? imageUrl;
  final BoxFit fit;

  const _Placeholder({required this.height, this.imageUrl, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        height: height,
        width: double.infinity,
        fit: fit,
        placeholder: (_, _) => _shimmerBox(),
        errorWidget: (_, _, _) => _emptyBox(),
      );
    }
    return _emptyBox();
  }

  Widget _shimmerBox() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(height: height, width: double.infinity, child: Container(color: Colors.white)),
      );

  Widget _emptyBox() => Container(
        height: height,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.restaurant, color: Colors.grey, size: 40)),
      );
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _AttributionBadge extends StatelessWidget {
  final RestaurantPhoto photo;

  const _AttributionBadge({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (photo.attributionUrl != null) {
          final uri = Uri.tryParse(photo.attributionUrl!);
          if (uri != null) await launchUrl(uri);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera, color: Colors.white70, size: 10),
            const SizedBox(width: 3),
            Text(
              photo.attributionText ?? 'Google',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone badge for use where a full gallery isn't needed.
class GoogleAttributionBadge extends StatelessWidget {
  final RestaurantPhoto photo;

  const GoogleAttributionBadge({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    if (!photo.needsAttribution) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(photo.attributionUrl ?? '');
          if (uri != null && uri.hasScheme) await launchUrl(uri);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera_outlined, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              'Photo: ${photo.attributionText}',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
