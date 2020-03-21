import 'package:flutter/material.dart';

class SharedContextWidget extends InheritedWidget {

  final Widget child;
  final BuildContext originContext;

  SharedContextWidget({
    @required this.child,
    @required this.originContext
  }): super(child: child);

  @override
  bool updateShouldNotify(SharedContextWidget old) {
    return false;
  }

  static SharedContextWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

}