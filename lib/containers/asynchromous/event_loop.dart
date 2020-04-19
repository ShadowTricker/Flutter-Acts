import 'dart:async';

import 'package:flutter/material.dart';

class EventLoopPage extends StatelessWidget {

  final String title;

  EventLoopPage({ this.title });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
    Future.delayed(Duration(seconds: 0), () => print('f1'));

    scheduleMicrotask(() => print('f2'));

    Future(() {
      print('f3');
      scheduleMicrotask(() {
        print('f4');
        Future(() {
          print('f5');
          return 'f6';
        }).then(print);
      });
    }).then((_) {
      print('f7');
      Future(() => 'f8').then(print);
      scheduleMicrotask(() => print('f9'));
    });

    Future.value(Future(() => 'f10')).then(print);

    Future(() {
      print('f11');
      return 'f12';
    }).then(print);

    scheduleMicrotask(() {
      print('f13');
      Future(() {
        print('f14');
      });
    });

    Future.value('f15').then(print);

    Future.value(Future(() => 'f16')).then(print);

    Future.error('f17').then(print).catchError(print);

    Future.sync(() => 'f18').then(print);

    Future.microtask(() => 'f19').then(print);

    scheduleMicrotask(() => print('f20'));
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