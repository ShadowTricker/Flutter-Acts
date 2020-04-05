import 'package:flutter/material.dart';
import 'package:flutter_act/containers/asynchromous/async_catelogue.dart';
import 'package:flutter_act/containers/asynchromous/event_loop.dart';
import 'package:flutter_act/containers/asynchromous/future.dart';
import 'package:flutter_act/containers/asynchromous/future_builder.dart';

Map<String, WidgetBuilder> asyncRoutes(BuildContext context) {
  return {
    '/catelogue': (context) => AsyncCatelogue(),
    '/event-loop': (context) => EventLoopPage(),
    '/future': (context) => FuturePage(),
    '/future-builder': (context) => FutureBuilderPage(),
  };
}