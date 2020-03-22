import 'dart:async';

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
              // onPressed: eventLoopSequenceDifficult
              onPressed: test
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

  void eventLoopSequenceSimple() {
    print('start');
    Future.delayed(Duration(seconds: 0), () => print('Delay Future'));
    final Future<void> testFuture1 = Future(() => print('Future1'));
    testFuture1.then(print).then(print);
    final Future<void> testFuture2 = Future(() => print('Future2'));
    testFuture2.then(print).then(print);
    Timer(Duration(seconds: 0), () => print('Delay Timer'));
    scheduleMicrotask(() => print('Micro Task'));
    print('end');
  }

  void eventLoopSequenceDifficult() {
    print('start');
    Future(() => 'Future1').then(print).then(print);
    Future.delayed(Duration(seconds: 0), () => print('Future Delay1'));
    scheduleMicrotask(() => print('Micro Task1'));
    scheduleMicrotask(() {
      print('Micro Task2');
      Future(() => 'Future2').then(print).then(print);
    });
    scheduleMicrotask(() {
      print('Micro Task3');
      Future(() => 'Future3').then((value) {
        print(value);
        scheduleMicrotask(() => print('Micro Task4'));
      }).then(print);
    });
    Future(() {
      print('Future4');
      scheduleMicrotask(() => print('Micro Task5'));
    }).then(print);
    Future.delayed(Duration(seconds: 0), () {
      print('Future Delay2');
      Future(() => 'Future5').then(print).then(print);
    });
    print('end');
  }

  void test() {
    print('start');
    scheduleMicrotask(() {
      print(1);
      Future(() => 'Future2').then(print).then(print);
      scheduleMicrotask(() {
        print(2);
        Future(() => 'Future1').then(print).then(print);
      });
    });
    print('end');
  }

}