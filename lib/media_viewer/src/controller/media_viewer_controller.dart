import 'dart:async';

import 'package:appbar_test/media_viewer/src/utils/ignorable_change_notifier.dart';
import 'package:flutter/widgets.dart';

abstract class MediaViewerControllerBase<T extends MediaViewerControllerValue> {
  /// The output for state/value updates. Usually a broadcast [Stream]
  Stream<T> get outputStateStream;

  /// The state value before the last change or the initial state if the state has not been changed.
  late T prevValue;

  /// The actual state value
  late T value;

  /// Resets the state to the initial value;
  void reset();

  /// Closes streams and removes eventual listeners.
  void dispose();

  /// Add a listener that will ignore updates made internally
  ///
  /// Since it is made for internal use, it is not performatic to use more than one
  /// listener. Prefer [outputStateStream]
  void addIgnorableListener(VoidCallback callback);

  /// Remove a listener that will ignore updates made internally
  ///
  /// Since it is made for internal use, it is not performatic to use more than one
  /// listener. Prefer [outputStateStream]
  void removeIgnorableListener(VoidCallback callback);

  late double backgroundOpacity;

  late double deltaY;

  /// The position of the image in the screen given its offset after pan gestures.
  late Offset position;

  /// The scale factor to transform the child (image or a customChild).
  late double? scale;

  /// Nevermind this method :D, look away
  void setScaleInvisibly(double? scale);

  /// The rotation factor to transform the child (image or a customChild).
  late double rotation;

  /// The center of the rotation transformation. It is a coordinate referring to the absolute dimensions of the image.
  Offset? rotationFocusPoint;

  /// Update multiple fields of the state with only one update streamed.
  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  });

  void updateDrag({
    double? positionY,
    double? backgroundOpacity,
    double? deltaY,
  });
}

/// The state value stored and streamed by [MediaViewerController].
@immutable
class MediaViewerControllerValue {
  const MediaViewerControllerValue({
    required this.position,
    required this.scale,
    required this.rotation,
    required this.rotationFocusPoint,
    required this.backgroundOpacity,
    required this.deltaY,
  });

  final Offset position;
  final double? scale;
  final double rotation;
  final Offset? rotationFocusPoint;
  final double backgroundOpacity;
  final double deltaY;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaViewerControllerValue &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          scale == other.scale &&
          rotation == other.rotation &&
          rotationFocusPoint == other.rotationFocusPoint;

  @override
  int get hashCode =>
      position.hashCode ^ scale.hashCode ^ rotation.hashCode ^ rotationFocusPoint.hashCode;

  @override
  String toString() {
    return 'PhotoViewControllerValue{position: $position, scale: $scale, rotation: $rotation, rotationFocusPoint: $rotationFocusPoint}';
  }
}

/// The default implementation of [MediaViewerControllerBase].
///
/// Containing a [ValueNotifier] it stores the state in the [value] field and streams
/// updates via [outputStateStream].
///
/// For details of fields and methods, check [MediaViewerControllerBase].
///
class MediaViewerController implements MediaViewerControllerBase<MediaViewerControllerValue> {
  MediaViewerController({
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
    double? initialScale,
  })  : _valueNotifier = IgnorableValueNotifier(
          MediaViewerControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale: initialScale,
            rotationFocusPoint: null,
            backgroundOpacity: 1,
            deltaY: 1,
          ),
        ),
        super() {
    initial = value;
    prevValue = initial;

    _valueNotifier.addListener(_changeListener);
    _outputCtrl = StreamController<MediaViewerControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  final IgnorableValueNotifier<MediaViewerControllerValue> _valueNotifier;

  late MediaViewerControllerValue initial;

  late StreamController<MediaViewerControllerValue> _outputCtrl;

  @override
  Stream<MediaViewerControllerValue> get outputStateStream => _outputCtrl.stream;

  @override
  late MediaViewerControllerValue prevValue;

  @override
  void reset() {
    value = initial;
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  @override
  void addIgnorableListener(VoidCallback callback) {
    _valueNotifier.addIgnorableListener(callback);
  }

  @override
  void removeIgnorableListener(VoidCallback callback) {
    _valueNotifier.removeIgnorableListener(callback);
  }

  @override
  void dispose() {
    _outputCtrl.close();
    _valueNotifier.dispose();
  }

  @override
  double get backgroundOpacity => value.backgroundOpacity;

  @override
  set backgroundOpacity(double opacity) {
    if (value.backgroundOpacity == opacity) {
      return;
    }
    // logw('PASITION CONTROLLER $position');
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  double get deltaY => value.deltaY;

  @override
  set deltaY(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  set position(Offset position) {
    if (value.position == position) {
      return;
    }
    // position = Offset(0, position.dy + 10);
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  double? get scale => value.scale;

  @override
  void setScaleInvisibly(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    _valueNotifier.updateIgnoring(
      MediaViewerControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint,
        backgroundOpacity: backgroundOpacity,
        deltaY: deltaY,
      ),
    );
  }

  @override
  set rotation(double rotation) {
    if (value.rotation == rotation) {
      return;
    }
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  double get rotation => value.rotation;

  @override
  set rotationFocusPoint(Offset? rotationFocusPoint) {
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
    value = MediaViewerControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  @override
  Offset? get rotationFocusPoint => value.rotationFocusPoint;

  @override
  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    prevValue = value;
    final controller = MediaViewerControllerValue(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      rotation: rotation ?? value.rotation,
      rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
    value = controller;
  }

  @override
  void updateDrag({
    double? positionY,
    double? backgroundOpacity,
    double? deltaY,
  }) {
    prevValue = value;
    final controller = MediaViewerControllerValue(
      position: Offset(value.position.dx, positionY ?? value.position.dy),
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
      backgroundOpacity: backgroundOpacity ?? value.backgroundOpacity,
      deltaY: deltaY ?? value.deltaY,
    );
    value = controller;
  }

  @override
  MediaViewerControllerValue get value => _valueNotifier.value;

  @override
  set value(MediaViewerControllerValue newValue) {
    if (_valueNotifier.value == newValue) {
      return;
    }
    _valueNotifier.value = newValue;
  }
}
