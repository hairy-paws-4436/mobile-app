import 'package:flutter/material.dart';

class SafeAnimalImage extends StatelessWidget {
  final List<String> images;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;
  final BorderRadius? borderRadius;

  const SafeAnimalImage({
    Key? key,
    required this.images,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrar imágenes válidas
    final validImages = images.where((image) =>
    image.isNotEmpty &&
        (image.startsWith('http://') || image.startsWith('https://'))
    ).toList();

    Widget content;

    if (validImages.isNotEmpty) {
      content = Image.network(
        validImages.first,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    } else {
      content = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.pets,
        size: iconSize,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: SizedBox(
          width: iconSize * 0.6,
          height: iconSize * 0.6,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}