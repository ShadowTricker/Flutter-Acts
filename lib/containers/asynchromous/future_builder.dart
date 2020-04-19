import 'package:flutter/material.dart';

class FutureBuilderPage extends StatelessWidget {

  final String title;
  FutureBuilderPage({ this.title });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
      future: generateFuture(),
      builder: (context, snapshot) {
        return Center(
          child: _showText(snapshot)
        );
      }
    );
  }

  Future<String> generateFuture() async {
    final String text = await Future.delayed(Duration(seconds: 5), () => 'Future Completed');
    return text;
  }

  Widget _showText(AsyncSnapshot snapshot) {
    print(snapshot.connectionState);
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.hasError
        ? Text('Error: ${snapshot.error}')
        : Text('Content: ${snapshot.data}');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Waiting: Fetching...'),
          SizedBox(height: 30.0),
          CircularProgressIndicator()
        ],
      );
    } else {
      return null;
    }
  }

}