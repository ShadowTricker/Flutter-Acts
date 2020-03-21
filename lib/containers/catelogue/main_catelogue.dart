import 'package:flutter/material.dart';

class MainCateloguePage extends StatelessWidget {

  final Map<String, String> catelogue = {
    'widgets': 'Widgets', 'state-management': 'State Management', 'router': 'Router',
    'async': 'Asynchronous', 'animation': 'Animation', 'dart-base': 'Dart Base',
    'appendix': 'Appendix'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Catelogue'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.attach_file),
        onPressed: () {
          Navigator.of(context).pushNamed('/test');
        },
      ),
    );
  }

  Widget _buildBody() {
    final keys = List.from(catelogue.keys);
    final values = List.from(catelogue.values);

    return ListView.separated(
      itemCount: catelogue.length,
      itemBuilder: (BuildContext context, int index) {
        final itemKey = keys[index];
        final itemValue = values[index];
        final int cateIndex = index + 1;
        return ListTile(
          title: Text('$cateIndex. $itemValue'),
          trailing: Icon(Icons.keyboard_arrow_right),
          contentPadding: EdgeInsets.symmetric(horizontal: 14),
          onTap: () {
            print(itemKey);
            Navigator.of(context).pushNamed('/$itemKey', arguments: context);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: .5,
        color: Colors.black26
      ),
    );
  }

}