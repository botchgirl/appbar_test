import 'package:appbar_test/appbar/app_bar_scope.dart';
import 'package:flutter/material.dart';

class AppBarContent extends StatelessWidget {
  final Widget content;

  const AppBarContent({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
      child: SliverAppBar(
        pinned: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: AppBarScope.of(context).contentSize.height,
        titleSpacing: 0,
        title: SizeChangedLayoutNotifier(child: content),
      ),
    );
  }
}
