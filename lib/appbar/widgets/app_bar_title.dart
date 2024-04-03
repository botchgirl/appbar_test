import 'package:appbar_test/appbar/widgets/app_bar_background.dart';
import 'package:flutter/material.dart';

class AppBarTitle extends StatefulWidget {
  const AppBarTitle({
    super.key,
  });

  @override
  State<AppBarTitle> createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 67,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topRight,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 67,
              child: ClipRect(
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: BackgroundPaint(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        screenHeight: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      title: Center(
        child: Container(
          width: 150,
          height: 20,
          color: Colors.grey,
        ),
      ),
    );
  }
}
