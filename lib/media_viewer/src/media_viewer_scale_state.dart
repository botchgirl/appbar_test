enum MediaViewerState {
  initial,
  covering,
  originalSize,
  zoomedIn,
  zoomedOut,
  horizontalDragging,
  verticalDragging,
}

extension MediaViewerStateIZoomingExtension on MediaViewerState {
  bool get isScaleStateZooming =>
      this == MediaViewerState.zoomedIn || this == MediaViewerState.zoomedOut;
}
