import 'package:appbar_test/media_viewer/media_viewer.dart';
import 'package:appbar_test/media_viewer/src/core/media_viewer_core.dart';
import 'package:appbar_test/media_viewer/src/media_viewer_default_wigets.dart';
import 'package:appbar_test/media_viewer/src/utils/media_viewer_utils.dart';
import 'package:flutter/widgets.dart';

class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    Key? key,
    required this.imageProvider,
    required this.loadingBuilder,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.scaleStateChangedCallback,
    required this.enableRotation,
    required this.controller,
    required this.stateController,
    required this.maxScale,
    required this.minScale,
    required this.initialScale,
    required this.basePosition,
    required this.scaleStateCycle,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.outerSize,
    required this.gestureDetectorBehavior,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.errorBuilder,
    required this.enablePanAlways,
    required this.strictScale,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final LoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final BoxDecoration backgroundDecoration;
  final String? semanticLabel;
  final bool gaplessPlayback;
  final MediaViewerHeroAttributes? heroAttributes;
  final ValueChanged<MediaViewerState>? scaleStateChangedCallback;
  final bool enableRotation;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final MediaViewerControllerBase controller;
  final MediaViewerStateController stateController;
  final Alignment? basePosition;
  final StateCycle? scaleStateCycle;
  final MediaViewerImageTapUpCallback? onTapUp;
  final MediaViewerImageTapDownCallback? onTapDown;
  final MediaViewerImageScaleEndCallback? onScaleEnd;
  final Size outerSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool? tightMode;
  final FilterQuality? filterQuality;
  final bool? disableGestures;
  final bool? enablePanAlways;
  final bool? strictScale;

  @override
  _ImageWrapperState createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  ImageStreamListener? _imageStreamListener;
  ImageStream? _imageStream;
  ImageChunkEvent? _loadingProgress;
  ImageInfo? _imageInfo;
  bool _loading = true;
  Size? _imageSize;
  Object? _lastException;
  StackTrace? _lastStack;

  @override
  void dispose() {
    super.dispose();
    _stopImageStream();
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _resolveImage();
    }
  }

  // retrieve image from the provider
  void _resolveImage() {
    final ImageStream newStream = widget.imageProvider.resolve(
      const ImageConfiguration(),
    );
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getOrCreateListener() {
    void handleImageChunk(ImageChunkEvent event) {
      setState(() {
        _loadingProgress = event;
        _lastException = null;
      });
    }

    void handleImageFrame(ImageInfo info, bool synchronousCall) {
      final setupCB = () {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        _loading = false;
        _imageInfo = _imageInfo;

        _loadingProgress = null;
        _lastException = null;
        _lastStack = null;
      };
      synchronousCall ? setupCB() : setState(setupCB);
    }

    void handleError(dynamic error, StackTrace? stackTrace) {
      setState(() {
        _loading = false;
        _lastException = error;
        _lastStack = stackTrace;
      });
      assert(() {
        if (widget.errorBuilder == null) {
          throw error;
        }
        return true;
      }());
    }

    _imageStreamListener = ImageStreamListener(
      handleImageFrame,
      onChunk: handleImageChunk,
      onError: handleError,
    );

    return _imageStreamListener!;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) {
      return;
    }
    _imageStream?.removeListener(_imageStreamListener!);
    _imageStream = newStream;
    _imageStream!.addListener(_getOrCreateListener());
  }

  void _stopImageStream() {
    _imageStream?.removeListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading(context);
    }

    if (_lastException != null) {
      return _buildError(context);
    }

    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? MediaViewerComputedScale.contained,
      widget.outerSize,
      _imageSize!,
    );

    return MediaViewerCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      semanticLabel: widget.semanticLabel,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      heroAttributes: widget.heroAttributes,
      basePosition: widget.basePosition ?? Alignment.center,
      controller: widget.controller,
      stateController: widget.stateController,
      stateCycle: widget.scaleStateCycle ?? defaultStateCycle,
      strictScale: widget.strictScale ?? false,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      onScaleEnd: widget.onScaleEnd,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
      disableGestures: widget.disableGestures ?? false,
      enablePanAlways: widget.enablePanAlways ?? false,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _loadingProgress);
    }

    return MediaViewerDefaultLoading(
      event: _loadingProgress,
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _lastException!, _lastStack);
    }
    return MediaViewerDefaultError(
      decoration: widget.backgroundDecoration,
    );
  }
}

class CustomChildWrapper extends StatelessWidget {
  const CustomChildWrapper({
    Key? key,
    this.child,
    required this.childSize,
    required this.backgroundDecoration,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    required this.enableRotation,
    required this.controller,
    required this.stateController,
    required this.maxScale,
    required this.minScale,
    required this.initialScale,
    required this.basePosition,
    required this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    required this.outerSize,
    this.gestureDetectorBehavior,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  }) : super(key: key);

  final Widget? child;
  final Size? childSize;
  final Decoration backgroundDecoration;
  final MediaViewerHeroAttributes? heroAttributes;
  final ValueChanged<MediaViewerState>? scaleStateChangedCallback;
  final bool enableRotation;

  final MediaViewerControllerBase controller;
  final MediaViewerStateController stateController;

  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;

  final Alignment? basePosition;
  final StateCycle? scaleStateCycle;
  final MediaViewerImageTapUpCallback? onTapUp;
  final MediaViewerImageTapDownCallback? onTapDown;
  final MediaViewerImageScaleEndCallback? onScaleEnd;
  final Size outerSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool? tightMode;
  final FilterQuality? filterQuality;
  final bool? disableGestures;
  final bool? enablePanAlways;
  final bool? strictScale;

  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      minScale ?? 0.0,
      maxScale ?? double.infinity,
      initialScale ?? MediaViewerComputedScale.contained,
      outerSize,
      childSize ?? outerSize,
    );

    return MediaViewerCore.customChild(
      customChild: child,
      backgroundDecoration: backgroundDecoration,
      enableRotation: enableRotation,
      heroAttributes: heroAttributes,
      controller: controller,
      stateController: stateController,
      stateCycle: scaleStateCycle ?? defaultStateCycle,
      basePosition: basePosition ?? Alignment.center,
      scaleBoundaries: scaleBoundaries,
      strictScale: strictScale ?? false,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onScaleEnd: onScaleEnd,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode ?? false,
      filterQuality: filterQuality ?? FilterQuality.none,
      disableGestures: disableGestures ?? false,
      enablePanAlways: enablePanAlways ?? false,
    );
  }
}
