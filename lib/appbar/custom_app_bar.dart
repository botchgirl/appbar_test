import 'package:appbar_test/appbar/app_bar_scope.dart';
import 'package:appbar_test/appbar/widgets/app_bar_background.dart';
import 'package:appbar_test/appbar/widgets/app_bar_content.dart';
import 'package:appbar_test/appbar/widgets/app_bar_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CustomAppBar extends StatefulWidget {
  final Widget content;
  final GlobalKey contentKey;

  const CustomAppBar({
    super.key,
    required this.content,
    required this.contentKey,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    Size? contentSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          widget.contentKey.currentContext?.findRenderObject() as RenderBox;

      AppBarScope.of(context).setSize(renderBox.size);
    });

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        final RenderBox renderBox =
            widget.contentKey.currentContext?.findRenderObject() as RenderBox;

        AppBarScope.of(context).setSize(renderBox.size);

        return true;
      },
      child: SliverStack(children: [
        const AppBarBackground(),
        MultiSliver(
          children: [
            const AppBarTitle(),
            CupertinoSliverRefreshControl(
              onRefresh: () async {},
            ),
            AppBarContent(
              content: widget.content,
            ),
          ],
        ),
      ]),
    );
  }
}
