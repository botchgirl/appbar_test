import 'dart:async';
import 'dart:ui';

import 'package:appbar_test/media_viewer/src/media_viewer_scale_state.dart';
import 'package:appbar_test/media_viewer/src/utils/ignorable_change_notifier.dart';
import 'package:flutter/widgets.dart' show VoidCallback;

typedef ScaleStateListener = void Function(double prevScale, double nextScale);

class MediaViewerStateController {
  late final IgnorableValueNotifier<MediaViewerState> _scaleStateNotifier =
      IgnorableValueNotifier(MediaViewerState.initial)..addListener(_scaleStateChangeListener);
  final StreamController<MediaViewerState> _outputScaleStateCtrl =
      StreamController<MediaViewerState>.broadcast()..sink.add(MediaViewerState.initial);

  /// The output for state/value updates
  Stream<MediaViewerState> get outputScaleStateStream => _outputScaleStateCtrl.stream;

  /// The state value before the last change or the initial state if the state has not been changed.
  MediaViewerState prevScaleState = MediaViewerState.initial;

  /// The actual state value
  MediaViewerState get scaleState => _scaleStateNotifier.value;

  /// Updates scaleState and notify all listeners (and the stream)
  set scaleState(MediaViewerState newValue) {
    // if (_scaleStateNotifier.value == newValue) {
    //   return;
    // }

    // prevScaleState = _scaleStateNotifier.value;
    // _scaleStateNotifier.value = newValue;
  }

  /// Checks if its actual value is different than previousValue
  bool get hasChanged => prevScaleState != scaleState;

  /// Check if is `zoomedIn` & `zoomedOut`
  bool get isZooming =>
      scaleState == MediaViewerState.zoomedIn || scaleState == MediaViewerState.zoomedOut;

  /// Check if is `verticalDragging` & `horizontalDragging`
  bool get isDragging =>
      scaleState == MediaViewerState.verticalDragging || scaleState == MediaViewerState.horizontalDragging;

  /// Resets the state to the initial value;
  void reset() {
    prevScaleState = scaleState;
    scaleState = MediaViewerState.initial;
  }

  /// Closes streams and removes eventual listeners
  void dispose() {
    _outputScaleStateCtrl.close();
    _scaleStateNotifier.dispose();
  }

  /// Nevermind this method :D, look away
  /// Seriously: It is used to change scale state without trigging updates on the []
  void setInvisibly(MediaViewerState newValue) {
    if (_scaleStateNotifier.value == newValue) {
      return;
    }
    prevScaleState = _scaleStateNotifier.value;
    _scaleStateNotifier.updateIgnoring(newValue);
  }

  void _scaleStateChangeListener() {
    _outputScaleStateCtrl.sink.add(scaleState);
  }

  /// Add a listener that will ignore updates made internally
  ///
  /// Since it is made for internal use, it is not performatic to use more than one
  /// listener. Prefer [outputScaleStateStream]
  void addIgnorableListener(VoidCallback callback) {
    _scaleStateNotifier.addIgnorableListener(callback);
  }

  /// Remove a listener that will ignore updates made internally
  ///
  /// Since it is made for internal use, it is not performatic to use more than one
  /// listener. Prefer [outputScaleStateStream]
  void removeIgnorableListener(VoidCallback callback) {
    _scaleStateNotifier.removeIgnorableListener(callback);
  }
}
