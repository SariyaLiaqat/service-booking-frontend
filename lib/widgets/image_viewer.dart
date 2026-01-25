import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final File? file;
  final String? imageUrl; // Added this to handle web images

  const ImageViewer({
    super.key, 
    this.file, 
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // 1. If we have a network URL, show network image
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 50,
        ),
      );
    } 
    
    // 2. Otherwise, if we have a local file, show file image
    if (file != null && file!.path.isNotEmpty) {
      return Image.file(
        file!,
        fit: BoxFit.contain,
      );
    }

    // 3. Fallback
    return const Icon(Icons.image_not_supported, color: Colors.white, size: 50);
  }
}