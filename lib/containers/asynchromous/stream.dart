import 'package:flutter/material.dart';

class StreamPage extends StatelessWidget {

  final String title;

  StreamPage({ this.title });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title)
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Text('Stream'),
    );
  }

}
