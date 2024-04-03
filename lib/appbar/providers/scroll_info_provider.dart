import 'package:flutter/material.dart';

class ScrollInfoProvider extends InheritedWidget {
  final ScrollNotification? scrollInfo;

  const ScrollInfoProvider({
    Key? key,
    this.scrollInfo,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ScrollInfoProvider oldWidget) {
    return scrollInfo != oldWidget.scrollInfo;
  }

  static ScrollInfoProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScrollInfoProvider>();
  }
}
