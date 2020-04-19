import 'package:flutter/material.dart';
import 'package:flutter_act/containers/asynchromous/async_catelogue.dart';
import 'package:flutter_act/containers/asynchromous/event_loop.dart';
import 'package:flutter_act/containers/asynchromous/future.dart';
import 'package:flutter_act/containers/asynchromous/future_builder.dart';
import 'package:flutter_act/containers/asynchromous/rx_page.dart';
import 'package:flutter_act/containers/asynchromous/stream.dart';
import 'package:flutter_act/containers/asynchromous/stream_builder.dart';

Map<String, WidgetBuilder> asyncRoutes(BuildContext context) {
  return {
    '/catelogue': (context) => AsyncCatelogue(),
    '/event-loop': (context) => EventLoopPage(
      title: ModalRoute.of(context).settings.arguments
    ),
    '/future': (context) => FuturePage(
      title: ModalRoute.of(context).settings.arguments
    ),
    '/future-builder': (context) => FutureBuilderPage(
      title: ModalRoute.of(context).settings.arguments
    ),
    '/stream': (context) => StreamPage(
      title: ModalRoute.of(context).settings.arguments
    ),
    '/rx-dart': (context) => ReactiveXPage(
      title: ModalRoute.of(context).settings.arguments
    ),
    '/stream-builder': (context) => StreamBuilderPage(
      title: ModalRoute.of(context).settings.arguments
    )
  };
}