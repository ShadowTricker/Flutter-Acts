import 'package:flutter/material.dart';
import 'package:flutter_act/router/main_route.dart';

class AppMain extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter in Action',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/main-catelogue',
      routes: mainRoutes(context),
    );
  }

}