import 'package:appbar_test/context_extension.dart';
import 'package:flutter/material.dart';

abstract interface class AppBarController {
  Size get contentSize;

  double get contentOpacity;

  double get contentScaleFactor;

  Stream<ScrollNotification>? scrollNotificationStream;

  ScrollController get scrollController;

  void setSize(Size contentSize);

  void setContentOpacity(double contentOpacity);

  void setContentScaleFactor(double contentScaleFactor);

  void setScrollNotificationStream(Stream<ScrollNotification> scrollNotificationStream);
}

class AppBarScope extends StatefulWidget {
  const AppBarScope({
    super.key,
    required this.child,
  });

  final Widget child;

  static AppBarController of(BuildContext context, {bool listen = true}) =>
      context.inhOf<_AppBarInherited>(listen: listen).controller;

  @override
  State<AppBarScope> createState() => AppBarScopeState();
}

class AppBarScopeState extends State<AppBarScope> implements AppBarController {
  Size _contentSize = Size.zero;

  final _scrollController = ScrollController();

  double _contentOpacity = 1;
  double _contentScaleFactor = 1;

  @override
  Stream<ScrollNotification>? scrollNotificationStream;

  @override
  ScrollController get scrollController => _scrollController;

  @override
  Size get contentSize => _contentSize;

  @override
  double get contentOpacity => _contentOpacity;

  @override
  double get contentScaleFactor => _contentScaleFactor;

  @override
  void setSize(Size newSize) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _contentSize = newSize;
      });
    });
  }

  @override
  void setScrollNotificationStream(Stream<ScrollNotification> scrollNotificationStream) {
    // scrollNotificationStream.listen(_onScrollUpdated);
  }

  @override
  void setContentOpacity(double newContentOpacity) {
    _contentOpacity = newContentOpacity;
  }

  @override
  void setContentScaleFactor(double newContentScaleFactor) {
    _contentScaleFactor = newContentScaleFactor;
  }

  @override
  Widget build(BuildContext context) => _AppBarInherited(
        controller: this,
        child: widget.child,
        contentSize: _contentSize,
        contentOpacity: _contentOpacity,
        contentScaleFactor: _contentScaleFactor,
      );
}

class _AppBarInherited extends InheritedWidget {
  const _AppBarInherited({
    required super.child,
    required this.controller,
    required this.contentSize,
    required this.contentOpacity,
    required this.contentScaleFactor,
  });

  final AppBarController controller;

  final Size contentSize;
  final double contentOpacity;
  final double contentScaleFactor;

  @override
  bool updateShouldNotify(_AppBarInherited oldWidget) =>
      contentSize != oldWidget.contentSize ||
      contentOpacity != oldWidget.contentOpacity ||
      contentScaleFactor != oldWidget.contentScaleFactor;
}
