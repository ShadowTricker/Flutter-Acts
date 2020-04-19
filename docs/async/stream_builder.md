# StreamBuilder  
`StreamBuilder` 正是用于配合 `Stream` 来展示流上事件（数据）变化的 `UI组件` 。  
下面是 `StreamBuilder` 的默认构造函数：  
```dart
  StreamBuilder({
    Key key,
    this.initialData,
    Stream<T> stream,
    @required this.builder,
  })
```
其实跟 `FutureBuilder` 都是一样的，只不过一个接受 `future`，一个接收 `stream`，而且他们的 `Builder` 函数也是一致的。  
```dart
  Function (BuildContext context, AsyncSnapshot snapshot) 
```
下面是 `ConnectionState` 的各种状态:  
```dart
  enum ConnectionState {
    /// 当前没有异步任务，比如[FutureBuilder]的[future]为null时
    none,

    /// 异步任务处于等待状态
    waiting,

    /// Stream处于激活状态（流上已经有数据传递了），对于FutureBuilder没有该状态。
    active,

    /// 异步任务已经终止.
    done,
  }
```

实例：利用 `stream` 和 `InheritedWidget` 实现一个简单 `Bloc` 库，然后用 `StreamBuilder` 去渲染。  

#### 1. 首先使用 stream 创建一个 Bloc 类
```dart
class CounterBloc {

  int _count = 0;
  // StreamController<int> _countController = StreamController.broadcast();
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
```
上例之所以选择 `BehaviorSubject`，是因为在退出页面后页面被注销，但是页面中的 `stream` 还保留退出页面之前的状态。当再次进入该页面时，页面监听了这个流，但是之前的数据已经发出，导致无法接收到之前的状态，所以此时会渲染初始值 `0`。而只有再次点击按钮发出新的数据之后，显示的数值才会变为正常的状态（具体展现请运行代码）。而 `Behavior` 会在订阅时发出最后一次状态。

#### 2. 用 InheritedWidget 创建一个 Provider：  
```dart
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
```
创建一个继承 `InheritedWidget` 的 `Provider` 组件，在其内部初始化 `Bloc`，然后写一个 `of` 静态方法，用来返回这个 `Provider` 中的数据 `bloc`。

#### 3. 书写页面  
```dart
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
```
将页面包裹在 `Provider` 中，在按钮处调用 `bloc` 提供的 `increment` 方法，然后在 `StreamBuilder` 中监听这个流（展现请运行代码）。  

---