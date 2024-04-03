import 'dart:async';

import 'package:appbar_test/appbar/app_bar_scope.dart';
import 'package:appbar_test/appbar/custom_app_bar.dart';
import 'package:appbar_test/appbar/providers/scroll_info_provider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _appBarContentKey = GlobalKey();

  final StreamController<ScrollNotification> _scrollStreamController =
      StreamController<ScrollNotification>.broadcast();

  @override
  Widget build(BuildContext context) {
    AppBarScope.of(context)
        .setScrollNotificationStream(_scrollStreamController.stream);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          _scrollStreamController.add(notification);
        }

        return true;
      },
      child: StreamBuilder<ScrollNotification>(
          stream: _scrollStreamController.stream,
          builder: (context, snapshot) {
            return ScrollInfoProvider(
              scrollInfo: snapshot.data,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                controller: AppBarScope.of(context).scrollController,
                slivers: [
                  CustomAppBar(
                    content: Column(
                      key: _appBarContentKey,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: ColoredBox(color: Colors.red),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: ColoredBox(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 50,
                                child: ColoredBox(color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 50,
                                child: ColoredBox(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    contentKey: _appBarContentKey,
                  ),
                  SliverList.builder(
                      itemCount: 100,
                      itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.amber,
                              height: 20,
                            ),
                          ))
                ],
              ),
            );
          }),
    );
  }
}
