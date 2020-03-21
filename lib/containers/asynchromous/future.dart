import 'package:flutter/material.dart';

class FuturePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Future'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildIconButton(
              context: context,
              label: 'Future Success',
              onPressed: futureSuccess
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'Future Failure',
              onPressed: futureFailure
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'Thenable API',
              onPressed: thenableTest
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'Async Success',
              onPressed: asyncSuccess
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'Async Failure',
              onPressed: asyncFailure
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'With Await',
              onPressed: withAwait
            ),
          ],
        ),
      )
    );
  }

  Widget _buildIconButton({ BuildContext context, String label, Function() onPressed }) {
    return Container(
      width: 180,
      child: FlatButton.icon(
        icon: Icon(Icons.widgets),
        label: Text(label),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: onPressed
      ),
    );
  }

  void futureSuccess() {
    final Future<int> futureSuccess = Future(() {
      return 123;
    });
    futureSuccess.then(print);
    futureSuccess.then(print);
  }

  void futureFailure() {
    final Future<dynamic> futureFailure = Future(() {
      throw Exception('execute failed');
    });

    futureFailure.then(print).catchError(print);
  }

  void thenableTest() {
    final Future<String> testFuture1 = Future(() => 'Future1');
    final Future<String> testFuture2 = Future(() => 'Future2');
    final Future<String> testFuture3 = Future(() => 'Future3');
    final Future<String> testFutureError = Future(() => throw Exception('Error'));

    testFuture1
      .then((value) {
        print(value);
        return testFuture2;
      })
      .then((value) {
        print(value);
        return testFutureError;
      })
      .catchError((error) {
        print(error);
        return testFuture3;
      })
      .then((value) {
        print(value);
      });
  }

  Future<void> asyncSuccess() async {
    final Future<int> futureSuccess = Future(() {
      return 123;
    });
    // final int num = await futureSuccess;
    // print(num);
    print(await futureSuccess);
  }

  Future<void> asyncFailure() async {
    final Future<int> futureError = Future(() => throw Exception('Error'));
    try {
      await futureError;
    } catch(err) {
      print(err);
    }
  }

  Future<void> withAwait() async {
    print('start');
    final Future<int> futureSuccess = Future(() {
      return 123;
    });
    print(await futureSuccess);
    print('end');
  }

}