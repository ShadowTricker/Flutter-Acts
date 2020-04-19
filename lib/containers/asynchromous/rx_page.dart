import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ReactiveXPage extends StatefulWidget {

  final String title;

  ReactiveXPage({ this.title });

  @override
  ReactiveXPageState createState() => ReactiveXPageState();

}

class ReactiveXPageState extends State<ReactiveXPage> {

  final Stream<int> concatedSource = ConcatStream([
    Stream.fromIterable([1, 2, 3, 4]),
    Stream.fromIterable([5, 6, 7, 8])
  ]);

  final ReplaySubject<int> replaySubject = ReplaySubject(maxSize: 3);

  StreamSubscription concatedSubscrition;
  StreamSubscription firstSubscription;
  StreamSubscription secondSubscription;

  @override
  void initState() {
    super.initState();
    concatedSource.doOnDone(() {
      concatedSubscrition.cancel();
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstSubscription.cancel();
    secondSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title)
      ),
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildIconButton(
            context: context,
            label: 'Listen Concat Stream',
            onPressed: _listenConcatStream
          ),
          SizedBox(height: 20.0),
          _buildIconButton(
            context: context,
            label: 'Listen Extended Stream',
            onPressed: _listenExtendedStream
          ),
          SizedBox(height: 20.0),
          _buildIconButton(
            context: context,
            label: 'Add Events',
            onPressed: _addEvents
          ),
          SizedBox(height: 20.0),
          _buildIconButton(
            context: context,
            label: 'Add Listener',
            onPressed: _addSecondListener
          ),
        ],
      )
    );
  }

  Widget _buildIconButton({ BuildContext context, String label, Function() onPressed }) {
    return Container(
      width: 240,
      child: FlatButton.icon(
        icon: Icon(Icons.widgets),
        label: Text(label),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: onPressed
      ),
    );
  }

  void _listenConcatStream() {
    concatedSubscrition = concatedSource.listen(print);
  }

  void _listenExtendedStream() {
    concatedSubscrition = concatedSource.startWith(0).delay(Duration(seconds: 3)).listen(print);
  }

  void _addEvents() {
    firstSubscription = replaySubject.listen((int event) => print('ListenerA: $event'));
    replaySubject.add(1);
    replaySubject.add(2);
    replaySubject.add(3);
    replaySubject.add(4);
    replaySubject.add(5);
  }

  void _addSecondListener() {
    secondSubscription = replaySubject.listen((int event) => print('ListenerB: $event'));
  }
}