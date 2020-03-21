import 'package:flutter/material.dart';
import 'package:flutter_act/containers/asynchromous/async_app.dart';
import 'package:flutter_act/containers/catelogue/main_catelogue.dart';
import 'package:flutter_act/containers/catelogue/test_page.dart';

Map<String, WidgetBuilder> mainRoutes(BuildContext context) {
  return {
    '/main-catelogue': (context) => MainCateloguePage(),
    '/test': (context) => TestPage(),
    '/async': (context) => AsyncApp(
      originContext: ModalRoute.of(context).settings.arguments,
    ),
  };
}