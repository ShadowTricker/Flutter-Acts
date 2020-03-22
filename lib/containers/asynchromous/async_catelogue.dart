import 'package:flutter/material.dart';

class AsyncCatelogue extends StatelessWidget {

  final Map<String, String> catelogue =  {
    'event-loop': 'Event Loop', 'future': 'Future', 'future-builder': 'FutureBuilder',
    'stream': 'Stream & RxDart Extensions', 'stream-builder': 'StreamBuilder'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Async Catelogue'),
      ),
      body: _buildCatelogue(context)
    );
  }

  Widget _buildCatelogue(BuildContext context) {
    final keys = List.from(catelogue.keys);
    final values = List.from(catelogue.values);

    return ListView.separated(
      itemCount: catelogue.length,
      itemBuilder: (BuildContext context, int index) {
        final key = keys[index];
        final value = values[index];
        final cateIndex = index + 1;
        return ListTile(
          title: Text('$cateIndex. $value'),
          trailing: Icon(Icons.keyboard_arrow_right),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
          onTap: () {
            Navigator.of(context).pushNamed('/$key');
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: .5,
        color: Colors.black12
      ),
    );
  }

}