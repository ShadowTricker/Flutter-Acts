import 'package:flutter/material.dart';
import 'package:flutter_act/containers/asynchromous/counter_bloc.dart';

class BlocProvider extends InheritedWidget {

  final CounterBloc bloc = CounterBloc();

  BlocProvider({ Key key, Widget child }): super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static CounterBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlocProvider>().bloc;
  }

}