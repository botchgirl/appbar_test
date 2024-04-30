// ignore_for_file: use_late_for_private_fields_and_variables, avoid_types_on_closure_parameters, cascade_invocations, prefer_int_literals, no_leading_underscores_for_local_identifiers, unnecessary_const, prefer_const_constructors

import 'package:appbar_test/media_viewer/src/controller/media_viewer_controller.dart';
import 'package:appbar_test/media_viewer/src/controller/media_viewer_controller_delegate.dart';
import 'package:appbar_test/media_viewer/src/core/media_viewer_gesture_detector.dart';
import 'package:appbar_test/media_viewer/src/core/media_viewer_hit_corners.dart';
import 'package:appbar_test/media_viewer/src/utils/media_viewer_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:appbar_test/media_viewer/media_viewer.dart'
    show
        MediaViewerControllerBase,
        MediaViewerHeroAttributes,
        MediaViewerImageScaleEndCallback,
        MediaViewerImageTapDownCallback,
        MediaViewerImageTapUpCallback,
        MediaViewerState,
        MediaViewerStateController,
        StateCycle;

const _defaultDecoration = const BoxDecoration(
  color: const Color.fromRGBO(0, 0, 0, 1.0),
);

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class MediaViewerCore extends StatefulWidget {
  const MediaViewerCore({
    Key? key,
    required this.imageProvider,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.enableRotation,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.stateCycle,
    required this.stateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  })  : customChild = null,
        super(key: key);

  const MediaViewerCore.customChild({
    Key? key,
    required this.customChild,
    required this.backgroundDecoration,
    this.heroAttributes,
    required this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.stateCycle,
    required this.stateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  })  : imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        super(key: key);

  final Decoration? backgroundDecoration;
  final ImageProvider? imageProvider;
  final String? semanticLabel;
  final bool? gaplessPlayback;
  final MediaViewerHeroAttributes? heroAttributes;
  final bool enableRotation;
  final Widget? customChild;

  final MediaViewerControllerBase controller;
  final MediaViewerStateController stateController;
  final ScaleBoundaries scaleBoundaries;
  final StateCycle stateCycle;
  final Alignment basePosition;

  final MediaViewerImageTapUpCallback? onTapUp;
  final MediaViewerImageTapDownCallback? onTapDown;
  final MediaViewerImageScaleEndCallback? onScaleEnd;

  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final bool disableGestures;
  final bool enablePanAlways;
  final bool strictScale;

  final FilterQuality filterQuality;

  @override
  State<StatefulWidget> createState() {
    return MediaViewerCoreState();
  }

  bool get hasCustomChild => customChild != null;
}

class MediaViewerCoreState extends State<MediaViewerCore>
    with
        TickerProviderStateMixin,
        MediaViewerControllerDelegate,
        HitCornersDetector {
  Offset? _normalizedPosition;
  double? _scaleBefore;
  double? _rotationBefore;

  Offset shiftOffset = Offset(0, 0);

  late final AnimationController _scaleAnimationController;
  Animation<double>? _scaleAnimation;

  late final AnimationController _positionAnimationController;
  Animation<Offset>? _positionAnimation;

  late final AnimationController _rotationAnimationController =
      AnimationController(vsync: this)..addListener(handleRotationAnimation);
  Animation<double>? _rotationAnimation;

  MediaViewerHeroAttributes? get heroAttributes => widget.heroAttributes;

  late ScaleBoundaries cachedScaleBoundaries = widget.scaleBoundaries;

  void handleScaleAnimation() {
    scale = _scaleAnimation!.value;
  }

  void handlePositionAnimate() {
    controller.position = _positionAnimation!.value;
  }

  void handleRotationAnimation() {
    controller.rotation = _rotationAnimation!.value;
  }

  void onScaleStart(ScaleStartDetails details) {
    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore! * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition!;

    if (widget.strictScale &&
        (newScale > widget.scaleBoundaries.maxScale ||
            newScale < widget.scaleBoundaries.minScale)) {
      return;
    }

    updateScaleStateFromNewScale(newScale);

    updateMultiple(
      scale: newScale,
      // position: widget.enablePanAlways ? delta : clampPosition(position: delta * details.scale),
      position: clampPosition(position: delta * details.scale),
      rotation:
          widget.enableRotation ? _rotationBefore! + details.rotation : null,
      rotationFocusPoint: widget.enableRotation ? details.focalPoint : null,
    );
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = scale;
    final Offset _position = controller.position;
    final double maxScale = scaleBoundaries.maxScale;
    final double minScale = scaleBoundaries.minScale;

    widget.onScaleEnd?.call(context, details, controller.value);

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: maxScale,
      );
      animatePosition(_position, clampedPosition);

      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
        _position,
        clampPosition(
          position: _position * scaleComebackRatio,
          scale: minScale,
        ),
      );

      return;
    }

    final test = clampPosition(
      position: _position,
    );

    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore! / _scale == 1.0 && magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(
        _position,
        clampPosition(position: _position + direction * 100.0),
      );
    }
  }

  void onDragUpdate(DragUpdateDetails details) {
    // final Offset delta = details.localPosition - _normalizedPosition!;

    shiftOffset += details.delta;

    updateScaleStateFromNewScale(scale);

    // controller.position = Offset(position.dx, shiftOffset.dy);

    updateDrag(
      positionY: shiftOffset.dy,
      deltaY: details.delta.dy,
      backgroundOpacity: isOverflow() ? 1 : controller.backgroundOpacity - 0.01,
    );
  }

  void onDragEnd(DragEndDetails details) {
    final deltaY = controller.deltaY;
    final _position = controller.position;

    animatePosition(
      _position,
      clampPosition(position: _position),
    );

    updateDrag(
      positionY: 0,
      deltaY: 1,
      backgroundOpacity: 1,
    );

    // animatePosition(
    //   shiftOffset,
    //   clampPosition(
    //     position: shiftOffset * scale,
    //     scale: minScale,
    //   ),
    // );

    shiftOffset = Offset(0, 0);
  }

  // onVerticalDragUpdate: (details) => dragController.dragged(
  //                     details.delta.dy,
  //                     context.size!.height,
  //                   ),
  // onVerticalDragEnd: (details) {
  //   // if (value.deltaY < 0.75) {
  //   //   context.pop();
  //   // } else {
  //   //   dragController.reset();
  //   // }
  // },

  // void dragged(double shift, double height) {
  //   final double deltaY = 1 - (value.shift.abs() / height);
  //   _setState(
  //     DragState(
  //       shift: shift + value.shift,
  //       animationDuration: Duration.zero,
  //       opacity: deltaY < 0.3 ? 0.3 : deltaY,
  //       deltaY: deltaY,
  //     ),
  //   );
  // }

  //  Try to check is horizontal or vertical drag
  //  void _onScaleUpdate(ScaleUpdateDetails details) {
  //   if (initialFocalPoint == null) return;
    
  //   Offset delta = details.focalPoint - initialFocalPoint!;
  //   initialFocalPoint = details.focalPoint;

  //   if (isHorizontal == null) {
  //     // Определяем направление после первого значимого движения
  //     if (delta.distance > 10) { // Порог чувствительности
  //       isHorizontal = delta.dx.abs() > delta.dy.abs();
  //     }
  //   }

  //   if (isHorizontal == true) {
  //     // Обрабатываем горизонтальное перетаскивание
  //     setState(() {
  //       offset = Offset(offset.dx + delta.dx, offset.dy);
  //     });
  //   } else if (isHorizontal == false) {
  //     // Обрабатываем вертикальное перетаскивание
  //     setState(() {
  //       offset = Offset(offset.dx, offset.dy + delta.dy);
  //     });
  //   }

  //   // Обрабатываем масштабирование
  //   if (details.scale != 1.0) {
  //     setState(() {
  //       scale = initialScale * details.scale;
  //     });
  //   }
  // }

  void onDoubleTap() {
    nextScaleState();
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateRotation(double from, double to) {
    _rotationAnimation = Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      onAnimationStatusCompleted();
    }
  }

  /// Check if scale is equal to initial after scale animation update
  void onAnimationStatusCompleted() {
    if (stateController.scaleState != MediaViewerState.initial &&
        scale == scaleBoundaries.initialScale) {
      stateController.setInvisibly(MediaViewerState.initial);
    }
  }

  @override
  void initState() {
    super.initState();
    initDelegate();
    addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);

    cachedScaleBoundaries = widget.scaleBoundaries;

    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation)
      ..addStatusListener(onAnimationStatus);
    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, Offset.zero);
    animateRotation(controller.rotation, 0.0);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void onTapUp(TapUpDetails details) {
    widget.onTapUp?.call(context, details, controller.value);
  }

  void onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(context, details, controller.value);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }

    return StreamBuilder(
      stream: controller.outputStateStream,
      initialData: controller.prevValue,
      builder: (
        BuildContext context,
        AsyncSnapshot<MediaViewerControllerValue> snapshot,
      ) {
        if (snapshot.hasData) {
          final MediaViewerControllerValue value = snapshot.data!;
          final useImageScale = widget.filterQuality != FilterQuality.none;

          final computedScale = useImageScale ? 1.0 : scale;

          final matrix = Matrix4.identity()
            ..translate(value.position.dx, value.position.dy)
            ..scale(computedScale)
            ..rotateZ(value.rotation);

          final Widget customChildLayout = CustomSingleChildLayout(
            delegate: _CenterWithOriginalSizeDelegate(
              scaleBoundaries.childSize,
              basePosition,
              useImageScale,
            ),
            child: _buildHero(),
          );

          final child = Container(
            constraints: widget.tightMode
                ? BoxConstraints.tight(scaleBoundaries.childSize * scale)
                : null,
            child: Center(
              child: Transform(
                child: customChildLayout,
                transform: matrix,
                alignment: basePosition,
              ),
            ),
            // decoration: widget.backgroundDecoration ?? _defaultDecoration,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, value.backgroundOpacity),
            ),
          );

          if (widget.disableGestures) {
            return child;
          }

          return MediaViewerGestureDetector(
            child: child,
            onDoubleTap: nextScaleState,
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            onScaleEnd: onScaleEnd,
            hitDetector: this,
            onTapUp: widget.onTapUp != null
                ? (details) => widget.onTapUp!(context, details, value)
                : null,
            onTapDown: widget.onTapDown != null
                ? (details) => widget.onTapDown!(context, details, value)
                : null,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes!.tag,
            createRectTween: heroAttributes!.createRectTween,
            flightShuttleBuilder: heroAttributes!.flightShuttleBuilder,
            placeholderBuilder: heroAttributes!.placeholderBuilder,
            transitionOnUserGestures: heroAttributes!.transitionOnUserGestures,
            child: _buildChild(),
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.hasCustomChild
        ? widget.customChild!
        : Image(
            image: widget.imageProvider!,
            semanticLabel: widget.semanticLabel,
            gaplessPlayback: widget.gaplessPlayback ?? false,
            filterQuality: widget.filterQuality,
            width: scaleBoundaries.childSize.width * scale,
            fit: BoxFit.contain,
          );
  }
}

@immutable
class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final double offsetX = halfWidth * (basePosition.x + 1);
    final double offsetY = halfHeight * (basePosition.y + 1);

    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return useImageScale
        ? const BoxConstraints()
        : BoxConstraints.tight(subjectSize);
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CenterWithOriginalSizeDelegate &&
          runtimeType == other.runtimeType &&
          subjectSize == other.subjectSize &&
          basePosition == other.basePosition &&
          useImageScale == other.useImageScale;

  @override
  int get hashCode =>
      subjectSize.hashCode ^ basePosition.hashCode ^ useImageScale.hashCode;
}
