import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final File? file;
  final String? url;

  const FullScreenImage({Key? key, this.file, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: file != null
              ? kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: file!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!,
                              fit: BoxFit.contain);
                        }
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      },
                    )
                  : Image.file(file!, fit: BoxFit.contain)
              : url != null
                  ? Image.network(
                      url!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image,
                            color: Colors.white, size: 80);
                      },
                    )
                  : const Icon(Icons.broken_image,
                      color: Colors.white, size: 80),
        ),
      ),
    );
  }
}
