import 'package:flutter/material.dart';

class EventLoopPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Loop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildIconButton(
              context: context,
              label: 'Event Loop Simple',
              onPressed: eventLoopSequenceSimple
            ),
            SizedBox(height: 20.0),
            _buildIconButton(
              context: context,
              label: 'Event Loop Difficult',
              onPressed: eventLoopSequenceDifficult
            ),
          ],
        )
      )
    );
  }

  Widget _buildIconButton({ BuildContext context, String label, Function() onPressed }) {
    return Container(
      width: 220,
      child: FlatButton.icon(
        icon: Icon(Icons.widgets),
        label: Text(label),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: onPressed
      ),
    );
  }

  void eventLoopSequenceSimple() async {
    print('start');
    final Future<String> testFuture = Future(() => 'Future');
    Future.delayed(Duration(seconds: 0), () => print('Delay'));
    testFuture.then(print);
    print('end');
  }

  void eventLoopSequenceDifficult() async {
    print('start');
    final Future<String> testFuture1 = Future(() => 'Future1');
    final Future<String> testFuture2 = Future(() => 'Future2');
    final Future<String> testFuture3 = Future(() => 'Future3');
    final Future<String> testFuture4 = Future(() => 'Future4');
    Future.delayed(Duration(seconds: 0), () => print('Delay1'));
    testFuture1
      .then((value) {
        print(value);
        return testFuture2;
      })
      .then((value) {
        print(value);
        return testFuture3;
      })
      .then((value) {
        print(value);
        Future.delayed(Duration(seconds: 0), () => print('Delay2'));
        print('test');
        return testFuture4;
      })
      .then(print);
    print('end');
  }

}