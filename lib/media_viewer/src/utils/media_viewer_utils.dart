// ignore_for_file: prefer_asserts_with_message

import 'dart:math' as math;

import 'package:appbar_test/media_viewer/src/media_viewer_computed_scale.dart';
import 'package:appbar_test/media_viewer/src/media_viewer_scale_state.dart';
import 'package:flutter/widgets.dart';

double getScaleForScaleState(
  MediaViewerState scaleState,
  ScaleBoundaries scaleBoundaries,
) {
  switch (scaleState) {
    case MediaViewerState.initial:
    case MediaViewerState.zoomedIn:
    case MediaViewerState.zoomedOut:
      return _clampSize(scaleBoundaries.initialScale, scaleBoundaries);
    case MediaViewerState.covering:
      return _clampSize(
        _scaleForCovering(scaleBoundaries.outerSize, scaleBoundaries.childSize),
        scaleBoundaries,
      );
    case MediaViewerState.originalSize:
      return _clampSize(1, scaleBoundaries);
    // Will never be reached
    default:
      return 0;
  }
}

@immutable
class ScaleBoundaries {
  const ScaleBoundaries(
    this._minScale,
    this._maxScale,
    this._initialScale,
    this.outerSize,
    this.childSize,
  );

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  final Size outerSize;
  final Size childSize;

  double get minScale {
    assert(_minScale is double || _minScale is MediaViewerComputedScale);
    if (_minScale == MediaViewerComputedScale.contained) {

      return _scaleForContained(outerSize, childSize) *
          (_minScale as MediaViewerComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == MediaViewerComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_minScale as MediaViewerComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);

    return _minScale;
  }

  double get maxScale {
    assert(_maxScale is double || _maxScale is MediaViewerComputedScale);
    if (_maxScale == MediaViewerComputedScale.contained) {
      return (_scaleForContained(outerSize, childSize) *
              (_maxScale as MediaViewerComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    if (_maxScale == MediaViewerComputedScale.covered) {
      return (_scaleForCovering(outerSize, childSize) *
              (_maxScale as MediaViewerComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }

    return _maxScale.clamp(minScale, double.infinity);
  }

  double get initialScale {
    assert(_initialScale is double || _initialScale is MediaViewerComputedScale);
    if (_initialScale == MediaViewerComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_initialScale as MediaViewerComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == MediaViewerComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_initialScale as MediaViewerComputedScale) // ignore: avoid_as
              .multiplier;
    }

    return _initialScale.clamp(minScale, maxScale);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleBoundaries &&
          runtimeType == other.runtimeType &&
          _minScale == other._minScale &&
          _maxScale == other._maxScale &&
          _initialScale == other._initialScale &&
          outerSize == other.outerSize &&
          childSize == other.childSize;

  @override
  int get hashCode =>
      _minScale.hashCode ^
      _maxScale.hashCode ^
      _initialScale.hashCode ^
      outerSize.hashCode ^
      childSize.hashCode;
}

double _scaleForContained(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _scaleForCovering(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _clampSize(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}

class CornersRange {
  const CornersRange(this.min, this.max);
  final double min;
  final double max;
}
