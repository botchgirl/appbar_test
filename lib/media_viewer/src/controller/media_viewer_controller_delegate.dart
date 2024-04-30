// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_int_literals, use_function_type_syntax_for_parameters, use_setters_to_change_properties

import 'package:appbar_test/media_viewer/src/core/media_viewer_core.dart';
import 'package:appbar_test/media_viewer/src/utils/media_viewer_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:appbar_test/media_viewer/media_viewer.dart'
    show
        MediaViewerControllerBase,
        MediaViewerState,
        MediaViewerStateController,
        MediaViewerStateIZoomingExtension,
        StateCycle;

/// A  class to hold internal layout logic to sync both controller states
///
/// It reacts to layout changes (eg: enter landscape or widget resize) and syncs the two controllers.
mixin MediaViewerControllerDelegate on State<MediaViewerCore> {
  MediaViewerControllerBase get controller => widget.controller;

  MediaViewerStateController get stateController => widget.stateController;

  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;

  StateCycle get scaleStateCycle => widget.stateCycle;

  Alignment get basePosition => widget.basePosition;
  Function(double prevScale, double nextScale)? _animateScale;

  /// Mark if scale need recalculation, useful for scale boundaries changes.
  bool markNeedsScaleRecalc = true;

  void initDelegate() {
    controller.addIgnorableListener(_blindScaleListener);
    stateController.addIgnorableListener(_blindScaleStateListener);
  }

  void _blindScaleStateListener() {
    if (!stateController.hasChanged) {
      return;
    }
    if (_animateScale == null || stateController.isZooming) {
      controller.setScaleInvisibly(scale);

      return;
    }
    final double prevScale = controller.scale ??
        getScaleForScaleState(
          stateController.prevScaleState,
          scaleBoundaries,
        );

    final double nextScale = getScaleForScaleState(
      stateController.scaleState,
      scaleBoundaries,
    );

    _animateScale!(prevScale, nextScale);
  }

  void addAnimateOnScaleStateUpdate(
    void animateScale(double prevScale, double nextScale),
  ) {
    _animateScale = animateScale;
  }

  void _blindScaleListener() {
    if (!widget.enablePanAlways) {
      controller.position = clampPosition();
    }
    if (controller.scale == controller.prevValue.scale) {
      return;
    }
    final MediaViewerState newScaleState =
        (scale > scaleBoundaries.initialScale)
            ? MediaViewerState.zoomedIn
            : MediaViewerState.zoomedOut;

    stateController.setInvisibly(newScaleState);
  }

  Offset get position => controller.position;

  double get scale {
    // for figuring out initial scale
    final needsRecalc =
        markNeedsScaleRecalc && !stateController.scaleState.isScaleStateZooming;

    // final needsRecalc = markNeedsScaleRecalc && !stateController.isZooming;

    final scaleExistsOnController = controller.scale != null;
    if (needsRecalc || !scaleExistsOnController) {
      final newScale = getScaleForScaleState(
        stateController.scaleState,
        scaleBoundaries,
      );
      markNeedsScaleRecalc = false;
      scale = newScale;

      return newScale;
    }

    return controller.scale!;
  }

  set scale(double scale) => controller.setScaleInvisibly(scale);

  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    controller.updateMultiple(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  void updateDrag({
    double? positionY,
    double? backgroundOpacity,
    double? deltaY,
  }) {
    controller.updateDrag(
      positionY: positionY,
      backgroundOpacity: backgroundOpacity,
      deltaY: deltaY,
    );
  }

  void updateScaleStateFromNewScale(double newScale) {
    MediaViewerState newScaleState = MediaViewerState.initial;
    if (scale != scaleBoundaries.initialScale) {
      newScaleState = (newScale > scaleBoundaries.initialScale)
          ? MediaViewerState.zoomedIn
          : MediaViewerState.zoomedOut;
    }
    stateController.setInvisibly(newScaleState);
  }

  void nextScaleState() {
    final MediaViewerState scaleState = stateController.scaleState;
    if (scaleState == MediaViewerState.zoomedIn ||
        scaleState == MediaViewerState.zoomedOut) {
      stateController.scaleState = scaleStateCycle(scaleState);

      return;
    }
    final double originalScale = getScaleForScaleState(
      scaleState,
      scaleBoundaries,
    );

    double prevScale = originalScale;
    MediaViewerState prevScaleState = scaleState;
    double nextScale = originalScale;
    MediaViewerState nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = scaleStateCycle(prevScaleState);
      nextScale = getScaleForScaleState(nextScaleState, scaleBoundaries);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) {
      return;
    }
    stateController.scaleState = nextScaleState;
  }

  CornersRange cornersX({double? scale}) {
    final double _scale = scale ?? this.scale;

    final double computedWidth = scaleBoundaries.childSize.width * _scale;
    final double screenWidth = scaleBoundaries.outerSize.width;

    final double positionX = basePosition.x;
    final double widthDiff = computedWidth - screenWidth;

    final double minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final double maxX = ((positionX + 1).abs() / 2) * widthDiff;

    return CornersRange(minX, maxX);
  }

  CornersRange cornersY({double? scale}) {
    final double _scale = scale ?? this.scale;

    final double computedHeight = scaleBoundaries.childSize.height * _scale;
    final double screenHeight = scaleBoundaries.outerSize.height;

    final double positionY = basePosition.y;
    final double heightDiff = computedHeight - screenHeight;

    final double minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final double maxY = ((positionY + 1).abs() / 2) * heightDiff;

    return CornersRange(minY, maxY);
  }

  Offset clampPosition({Offset? position, double? scale}) {
    final double _scale = scale ?? this.scale;
    final Offset _position = position ?? this.position;

    final double computedWidth = scaleBoundaries.childSize.width * _scale;
    final double computedHeight = scaleBoundaries.childSize.height * _scale;

    final double screenWidth = scaleBoundaries.outerSize.width;
    final double screenHeight = scaleBoundaries.outerSize.height;

    double finalX = 0.0;
    if (screenWidth < computedWidth) {
      final cornersX = this.cornersX(scale: _scale);
      finalX = _position.dx.clamp(cornersX.min, cornersX.max);
    }

    if (!isOverflow()) {
      return Offset(finalX, _position.dy);
    }

    double finalY = 0.0;
    if (screenHeight < computedHeight) {
      final cornersY = this.cornersY(scale: _scale);
      finalY = _position.dy.clamp(cornersY.min, cornersY.max);
    }

    return Offset(finalX, finalY);
  }

  bool isOverflow() {
    final double computedHeight = scaleBoundaries.childSize.height * scale;

    final double screenHeight = scaleBoundaries.outerSize.height;

    if (screenHeight < computedHeight) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _animateScale = null;
    controller.removeIgnorableListener(_blindScaleListener);
    stateController.removeIgnorableListener(_blindScaleStateListener);
    super.dispose();
  }
}
