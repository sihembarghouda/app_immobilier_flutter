import 'package:flutter/material.dart';

/// Widget pour afficher une image avec fallback en cas d'erreur
class ImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const ImageWithFallback({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.fallbackIcon = Icons.image_not_supported,
    this.fallbackColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si pas d'URL, afficher le fallback directement
    if (imageUrl == null ||
        imageUrl!.isEmpty ||
        imageUrl!.contains('placeholder')) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image loading error: $error');
          return _buildFallback();
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Icon(
        fallbackIcon,
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.5
            : 50,
        color: fallbackColor.withOpacity(0.5),
      ),
    );
  }
}

/// Widget pour afficher un avatar avec fallback
class AvatarWithFallback extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? initials;
  final Color backgroundColor;

  const AvatarWithFallback({
    Key? key,
    this.imageUrl,
    this.radius = 20,
    this.initials,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si pas d'URL, afficher les initiales ou icône
    if (imageUrl == null ||
        imageUrl!.isEmpty ||
        imageUrl!.contains('placeholder')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: initials != null && initials!.isNotEmpty
            ? Text(
                initials!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                size: radius,
                color: Colors.white,
              ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (error, stackTrace) {
        print('❌ Avatar loading error: $error');
      },
      child: null,
    );
  }
}
