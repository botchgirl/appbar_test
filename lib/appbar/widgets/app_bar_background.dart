import 'dart:math';

import 'package:appbar_test/appbar/app_bar_scope.dart';
import 'package:appbar_test/appbar/providers/scroll_info_provider.dart';
import 'package:flutter/material.dart';

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size currentSize = AppBarScope.of(context).contentSize;
    final maxHeight =
        (currentSize.height == 0 ? 67 : currentSize.height + 67 + 16) +
            MediaQuery.paddingOf(context).top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 67 + MediaQuery.paddingOf(context).top,
        // maxHeight: maxHeight * max(1, scale),
        maxHeight: maxHeight,
        child: const ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scrollInfo = ScrollInfoProvider.of(context)?.scrollInfo;

    double scale = 0;

    if (scrollInfo != null && scrollInfo.metrics.axis == Axis.vertical) {
      if (scrollInfo.metrics.outOfRange && scrollInfo.metrics.pixels < 0.0) {
        scale = 1 + ((scrollInfo.metrics.pixels / maxHeight).abs());
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.topRight,
          children: [
            ClipPath(
              clipper: BackgroundClipper(
                isExpanding: scale > 1 ? true : false,
                shape: RoundedRectangleBorder(),
                clipHeight: maxHeight * max(1, scale),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constraints.maxHeight,
                child: CustomPaint(
                  painter: BackgroundPaint(
                    width: MediaQuery.of(context).size.width,
                    height: constraints.maxHeight,
                    screenHeight: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  final double clipHeight;
  final bool isExpanding;

  static const double radius = 12;

  BackgroundClipper({
    required this.shape,
    required this.isExpanding,
    required this.clipHeight,
  });

  final ShapeBorder shape;

  @override
  Path getClip(Size size) {
    if (isExpanding) {
      return Path()
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, clipHeight - radius)
        ..lineTo(0, clipHeight - radius)
        ..lineTo(0, 0)
        ..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              0,
              0,
              size.width,
              clipHeight,
            ),
            bottomLeft: const Radius.circular(radius),
            bottomRight: const Radius.circular(radius),
          ),
        );
    } else {
      return Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              0,
              0,
              size.width,
              size.height,
            ),
            bottomLeft: const Radius.circular(radius),
            bottomRight: const Radius.circular(radius),
          ),
        );
    }
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class BackgroundPaint extends CustomPainter {
  final double width;
  final double height;

  final double screenHeight;

  BackgroundPaint({
    required this.width,
    required this.height,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const LinearGradient bgGradient = LinearGradient(
      colors: [
        Colors.lightGreen,
        Colors.blueGrey,
        Colors.blue,
        Colors.amber,
      ],
      stops: [0, 0.4, 0.6, 0.8],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    final bgRect = Rect.fromLTWH(0, 0, width, screenHeight);
    final bgRRect = RRect.fromRectAndCorners(
      bgRect,
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );
    final bgPaint = Paint()..shader = bgGradient.createShader(bgRect);

    canvas.drawRRect(bgRRect, bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
