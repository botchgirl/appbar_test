library photo_view;

import 'package:appbar_test/media_viewer/src/utils/media_viewer_hero_attributes.dart';
import 'package:appbar_test/media_viewer/src/wrappers/image_wrapper.dart';
import 'package:flutter/material.dart';

import 'package:appbar_test/media_viewer/src/controller/media_viewer_controller.dart';
import 'package:appbar_test/media_viewer/src/controller/media_viewer_state_controller.dart';
import 'package:appbar_test/media_viewer/src/media_viewer_scale_state.dart';

export 'src/controller/media_viewer_controller.dart';
export 'src/controller/media_viewer_state_controller.dart';
export 'src/core/media_viewer_gesture_detector.dart' show MediaViewerGestureDetectorScope;
export 'src/media_viewer_computed_scale.dart';
export 'src/media_viewer_scale_state.dart';
export 'src/utils/media_viewer_hero_attributes.dart';


class MediaViewer extends StatefulWidget {
  MediaViewer({
    Key? key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.semanticLabel,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
    this.enablePanAlways,
    this.strictScale,
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [MediaViewer] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  MediaViewer.customChild({
    Key? key,
    required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.enablePanAlways,
    this.strictScale,
  })  : errorBuilder = null,
        imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        loadingBuilder = null,
        super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider? imageProvider;

  /// While [imageProvider] is not resolved, [loadingBuilder] is called by [MediaViewer]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final LoadingBuilder? loadingBuilder;

  /// Show loadFailedChild when the image failed to load
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Changes the background behind image, defaults to `Colors.black`.
  final BoxDecoration? backgroundDecoration;

  /// This is used to keep the state of an image in the gallery (e.g. scale state).
  /// `false` -> resets the state (default)
  /// `true`  -> keeps the state
  final bool wantKeepAlive;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and VoiceOver on iOS.
  final String? semanticLabel;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Attributes that are going to be passed to [PhotoViewCore]'s
  /// [Hero]. Leave this property undefined if you don't want a hero animation.
  final MediaViewerHeroAttributes? heroAttributes;

  /// Defines the size of the scaling base of the image inside [MediaViewer],
  /// by default it is `MediaQuery.of(context).size`.
  final Size? customSize;

  /// A [Function] to be called whenever the scaleState changes, this happens when the user double taps the content ou start to pinch-in.
  final ValueChanged<MediaViewerState>? scaleStateChangedCallback;

  /// A flag that enables the rotation gesture support
  final bool enableRotation;

  /// The specified custom child to be shown instead of a image
  final Widget? child;

  /// The size of the custom [child]. [MediaViewer] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size? childSize;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// A way to control PhotoView transformation factors externally and listen to its updates
  final MediaViewerControllerBase? controller;

  /// A way to control MediaViewerState value externally and listen to its updates
  final MediaViewerStateController? scaleStateController;

  /// The alignment of the scale origin in relation to the widget size. Default is [Alignment.center]
  final Alignment? basePosition;

  /// Defines de next [MediaViewerState] given the actual one. Default is [defaultScaleStateCycle]
  final StateCycle? scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final MediaViewerImageTapUpCallback? onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final MediaViewerImageTapDownCallback? onTapDown;

  /// A pointer that will trigger a scale has stopped contacting the screen at a
  /// particular location.
  final MediaViewerImageScaleEndCallback? onScaleEnd;

  /// [HitTestBehavior] to be passed to the internal gesture detector.
  final HitTestBehavior? gestureDetectorBehavior;

  /// Enables tight mode, making background container assume the size of the image/child.
  /// Useful when inside a [Dialog]
  final bool? tightMode;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  // Removes gesture detector if `true`.
  // Useful when custom gesture detector is used in child widget.
  final bool? disableGestures;

  /// Enable pan the widget even if it's smaller than the hole parent widget.
  /// Useful when you want to drag a widget without restrictions.
  final bool? enablePanAlways;

  /// Enable strictScale will restrict user scale gesture to the maxScale and minScale values.
  final bool? strictScale;

  bool get _isCustomChild {
    return child != null;
  }

  @override
  State<StatefulWidget> createState() {
    return _MediaViewerState();
  }
}

class _MediaViewerState extends State<MediaViewer> with AutomaticKeepAliveClientMixin {
  // image retrieval

  // controller
  late bool _controlledController;
  late MediaViewerControllerBase _controller;
  late bool _controlledScaleStateController;
  late MediaViewerStateController _scaleStateController;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controlledController = true;
      _controller = MediaViewerController();
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = MediaViewerStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }

    _scaleStateController.outputScaleStateStream.listen(scaleStateListener);
  }

  @override
  void didUpdateWidget(MediaViewer oldWidget) {
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = MediaViewerController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller!;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = MediaViewerStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController.dispose();
    }
    super.dispose();
  }

  void scaleStateListener(MediaViewerState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(_scaleStateController.scaleState);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final computedOuterSize = widget.customSize ?? constraints.biggest;
        final backgroundDecoration =
            widget.backgroundDecoration ?? const BoxDecoration(color: Colors.black);

        return widget._isCustomChild
            ? CustomChildWrapper(
                child: widget.child,
                childSize: widget.childSize,
                backgroundDecoration: backgroundDecoration,
                heroAttributes: widget.heroAttributes,
                scaleStateChangedCallback: widget.scaleStateChangedCallback,
                enableRotation: widget.enableRotation,
                controller: _controller,
                stateController: _scaleStateController,
                maxScale: widget.maxScale,
                minScale: widget.minScale,
                initialScale: widget.initialScale,
                basePosition: widget.basePosition,
                scaleStateCycle: widget.scaleStateCycle,
                onTapUp: widget.onTapUp,
                onTapDown: widget.onTapDown,
                onScaleEnd: widget.onScaleEnd,
                outerSize: computedOuterSize,
                gestureDetectorBehavior: widget.gestureDetectorBehavior,
                tightMode: widget.tightMode,
                filterQuality: widget.filterQuality,
                disableGestures: widget.disableGestures,
                enablePanAlways: widget.enablePanAlways,
                strictScale: widget.strictScale,
              )
            : ImageWrapper(
                imageProvider: widget.imageProvider!,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                semanticLabel: widget.semanticLabel,
                gaplessPlayback: widget.gaplessPlayback,
                heroAttributes: widget.heroAttributes,
                scaleStateChangedCallback: widget.scaleStateChangedCallback,
                enableRotation: widget.enableRotation,
                controller: _controller,
                stateController: _scaleStateController,
                maxScale: widget.maxScale,
                minScale: widget.minScale,
                initialScale: widget.initialScale,
                basePosition: widget.basePosition,
                scaleStateCycle: widget.scaleStateCycle,
                onTapUp: widget.onTapUp,
                onTapDown: widget.onTapDown,
                onScaleEnd: widget.onScaleEnd,
                outerSize: computedOuterSize,
                gestureDetectorBehavior: widget.gestureDetectorBehavior,
                tightMode: widget.tightMode,
                filterQuality: widget.filterQuality,
                disableGestures: widget.disableGestures,
                errorBuilder: widget.errorBuilder,
                enablePanAlways: widget.enablePanAlways,
                strictScale: widget.strictScale,
              );
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

/// The default [ScaleStateCycle]
MediaViewerState defaultStateCycle(MediaViewerState actual) {
  switch (actual) {
    case MediaViewerState.initial:
      return MediaViewerState.covering;
    case MediaViewerState.covering:
      return MediaViewerState.originalSize;
    case MediaViewerState.originalSize:
      return MediaViewerState.initial;
    case MediaViewerState.zoomedIn:
    case MediaViewerState.zoomedOut:
    case MediaViewerState.horizontalDragging:
    case MediaViewerState.verticalDragging:
      return MediaViewerState.initial;
    default:
      return MediaViewerState.initial;
  }
}

/// A type definition for a [Function] that receives the actual [MediaViewerState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [MediaViewer.scaleStateCycle]
typedef StateCycle = MediaViewerState Function(
  MediaViewerState actual,
);

/// A type definition for a callback when the user taps up the photoview region
typedef MediaViewerImageTapUpCallback = Function(
  BuildContext context,
  TapUpDetails details,
  MediaViewerControllerValue controllerValue,
);

/// A type definition for a callback when the user taps down the photoview region
typedef MediaViewerImageTapDownCallback = Function(
  BuildContext context,
  TapDownDetails details,
  MediaViewerControllerValue controllerValue,
);

/// A type definition for a callback when a user finished scale
typedef MediaViewerImageScaleEndCallback = Function(
  BuildContext context,
  ScaleEndDetails details,
  MediaViewerControllerValue controllerValue,
);

/// A type definition for a callback to show a widget while the image is loading, a [ImageChunkEvent] is passed to inform progress
typedef LoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);
