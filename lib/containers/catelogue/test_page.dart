import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Test Page'),
      ),
      body: Center(
        child: Text('Route Test'),
      )
    );
  }

}