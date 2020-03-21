import 'package:flutter/material.dart';
import 'package:flutter_act/router/async_route.dart';
import 'package:flutter_act/utils/shared_context.dart';

class AsyncApp extends StatelessWidget {

  final BuildContext originContext;

  AsyncApp({ this.originContext });

  @override
  Widget build(BuildContext context) {
    return SharedContextWidget(
      originContext: originContext,
      child: MaterialApp(
        title: 'Async App',
        initialRoute: '/catelogue',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green
        ),
        routes: asyncRoutes(context),
      )
    );
  }

}