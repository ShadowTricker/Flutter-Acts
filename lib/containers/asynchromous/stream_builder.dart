import 'package:flutter/material.dart';
import 'package:flutter_act/containers/asynchromous/bloc_provider.dart';

class StreamBuilderPage extends StatelessWidget {

  final String title;

  StreamBuilderPage({ this.title });

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    return BlocProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title)
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.today),
          onPressed: () {
            bloc.increment();
          }
        ),
        body: _buildBody(context)
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    final bloc = BlocProvider.of(context);

    return Center(
      child: StreamBuilder(
        stream: bloc.value,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          return Text(snapshot.data.toString());
        },
      )
    );
  }

}