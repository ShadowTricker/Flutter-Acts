import 'dart:async';

import 'package:rxdart/subjects.dart';

class CounterBloc {

  int _count = 0;
  StreamController<int> _countController = BehaviorSubject();

  Stream<int> get value => _countController.stream;

  increment() {
    _countController.add(++_count);
  }

  decrement() {
    _countController.add(_count++);
  }

  dispose() {
    _countController.close();
  }

}