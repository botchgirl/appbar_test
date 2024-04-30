import 'package:flutter/material.dart';

class MediaViewerDefaultError extends StatelessWidget {
  const MediaViewerDefaultError({Key? key, required this.decoration}) : super(key: key);

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey[400],
          size: 40.0,
        ),
      ),
    );
  }
}

class MediaViewerDefaultLoading extends StatelessWidget {
  const MediaViewerDefaultLoading({Key? key, this.event}) : super(key: key);

  final ImageChunkEvent? event;

  @override
  Widget build(BuildContext context) {
    final expectedBytes = event?.expectedTotalBytes;
    final loadedBytes = event?.cumulativeBytesLoaded;
    final value = loadedBytes != null && expectedBytes != null ? loadedBytes / expectedBytes : null;

    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(value: value),
      ),
    );
  }
}
