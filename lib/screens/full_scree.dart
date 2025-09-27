import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final File? file;
  final String? url;

  const FullScreenImage({Key? key, this.file, this.url})
      : assert(file != null || url != null, "Provide file or url"),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: file != null
              ? kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: file!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!);
                        }
                        return const CircularProgressIndicator();
                      },
                    )
                  : Image.file(file!)
              : Image.network(url!),
        ),
      ),
    );
  }
}
