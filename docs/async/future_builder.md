# FutureBuilder
`FutureBuilder` 是一个依赖于 `Future` 的组件，它会根据 `Future` 的状态，动态的构建自身。它的构造器是这样的：  
```dart
FutureBuilder({
    this.key,
    this.future,
    this.initialData,
    @required this.builder
})
```
- `future`：`FutureBuilder` 所依赖的 `future`  
- `initialData`： 初始数据，用户设置的 `默认数据`  
- `builder`：返回一个 `Widget`，在 `Future` 的不同阶段被调用，构建器如下：  
```dart
    Function (BuildContext context, AsyncSnapshot snapshot)
```
`snapshot` 会包含当前异步任务的状态信息及结果信息。  
比如我们可以通过 `snapshot.connectionState` 获取异步任务的状态信息、通过  `snapshot.hasError` 判断异步任务是否有错误等等，完整的定义可以参照 `AsyncSnapshot` 类定义。  

例：  
```dart
import 'package:flutter/material.dart';

class FutureBuilderPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Future Builder'),
      ),
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
      future: generateFuture(),
      builder: (context, snapshot) {
        return Center(
          child: _showText(snapshot)
        );
      }
    );
  }

  Future<String> generateFuture() async {
    final String text = await Future.delayed(
        Duration(seconds: 5), 
        () => 'Future Completed'
    );
    return text;
  }

  Widget _showText(AsyncSnapshot snapshot) {
    print(snapshot.connectionState);
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.hasError
        ? Text('Error: ${snapshot.error}')
        : Text('Content: ${snapshot.data}');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Waiting: Fetching...'),
          SizedBox(height: 30.0),
          CircularProgressIndicator()
        ],
      );
    } else {
      return null;
    }
  }
}
```
上例中，当页面渲染时，`FutureBuilder` 中的 `future` 由于处于 `Uncompleted` 状态，所以此时使用 `initialState` 中的值。   
当 `5s` 过后，`Future` 的状态改变为 `Completed(Value)`，此时 `FutureBuilder` 使用 `future` 的新值重新渲染。