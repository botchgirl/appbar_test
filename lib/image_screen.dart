import 'package:appbar_test/media_viewer/media_viewer.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaViewer(
      // enablePanAlways: true,
      minScale: MediaViewerComputedScale.contained,
      maxScale: MediaViewerComputedScale.covered * 1.8,
      initialScale: MediaViewerComputedScale.contained,
      imageProvider: const AssetImage("assets/test_hor.jpg"),
    );
  }
}
