# Stream  
### 1\. 生成器/迭代器（Generator/Iterator）  
`Dart` 语言中提供了两种生成器函数，`同步（Sync`）的生成器返回一个 `可迭代对象（Iterable Object）`，而 `异步（Async`）的生成器返回一个 `流（Stream`）。如下例：  
```dart
// A synchronous generator function generates Iterator Object
Iterable<int> naturalsTo(int n) sync* {
  int k = 0;
  while (k < n) yield k++;
}

// A asynchronous generator function generates Stream
Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 0;
  while (k < n) yield k++;
}
```
如上例所示，生成器的区别在于 `返回的类型` 以及 `函数体前的同步异步（sync*/async*）`。  
同步的生成器返回一个 `Iterable` 对象，该对象拥有 `Iterator` 属性，当对这个 `Iterable` 对象进行迭代时，其内部属性 `Iterator` 会调用 `moveNext()` 方法移动指针到下一个元素，并使用 `current` 属性获取当前指针所对应的值。例：  
```dart
  Iterable<int> natureTo(int n) sync* {
    int k = 0;
    while (k < n) yield k++;
  }

  final a = natureTo(3).iterator;
  print(a.moveNext());      // true
  print(a.current);         // 0
  print(a.moveNext());      // true
  print(a.current);         // 1
  print(a.moveNext());      // true
  print(a.current);         // 2
  print(a.moveNext());      // false
  print(a.current);         // null
```
当下一指针存在时，`moveNext` 返回 `true`，否则返回 `false`。 `current` 返回当前指针的值，否则返回 `null`。  
> `Javascript` 中也存在 `Generator`函数，它没有同步异步之说，返回的不是 `Iterable` 对象，而是 `Iterator`。  
`Iterator` 的 `next()` 方法可以传值，配合 `yield` 关键字 与 `Promise` ，可以简化 JS 中的异步流程， 也就是 JS 中 `async/await` 语法糖的前身。  

异步的生成器返回一个 `流（Stream）`。  
流是一种抽象的概念，它是一系列的数据的集合。**它可以被监听转换**。  
举个形象的例子，蒸馏水的生产流程：  
- `流（data）`是流入水管中的水。
- 当经过 `滤器（filter）`时，`过滤` 掉大部分杂质。
- 经过蒸馏装置（map）时，水从液态 `转化` 成气态。
- 经过`冷凝器（merge）`时，蒸汽从气态 `凝结` 成液态。
- 流出管道`（listen）`。  

在 `Dart` 语言中，流可以接收多个异步操作的结果，常用于会多次读取数据的异步任务场景，如网络内容下载、文件读写等。  
```dart
  Stream<int> natureTo(int n) async* {
    int k = 0;
    while (k < n) yield k++;
  }

  final a = natureTo(3);

  Future<void> printStream(Stream<int> intStream) async {
    await for(var i in intStream) {
      print(i);     // 0, 1, 2
    }
  }

  printStream(a);
```

### 2\. 创建流（Create Stream）  
创建流有三种方法，分别是创建 `async*/yield/yield* 函数`， `Stream 的构造方法`， `StreamController`。  

#### 1). `async* yield/yield* 函数`  
使用 async* 函数创建流，如下所示：  
```dart
  Stream<int> natureToThree() async* {
    yield 1;
    yield 2;
    yield 3;
  }

  final a = natureToThree();
  a.listen(print);      // 1, 2, 3
```
上例中，在函数体前加上关键字 `async*`，在函数体内部则使用关键字 `yield` 返回每一个需要返回的值，然后执行这个函数，函数就会返回一个流。**而这个流在被监听前都没有执行**，只有在被监听时，这个流才开始执行。  
`yield*` 关键字允许在流中执行另外的一个流（当然在同步迭代器函数中执行的是一个可迭代对象）：  
```dart
  Stream<int> natureFourToFive() async* {
    yield 4;
    yield 5;
  }

  Stream<int> natureToFive() async* {
    yield 1;
    yield 2;
    yield 3;
    yield* natureFourToFive();
  }

  final a = natureToFive();
  a.listen(print);      // 1, 2, 3, 4, 5

  Iterable<int> natureTo() sync* {
    yield 1;
    yield 2;
    yield 3;
    yield* [4, 5, 6];
  }

  final b = natureTo();
  b.forEach(print);     // 1, 2, 3, 4, 5, 6
```

#### 2). Stream 的构造方法  
Stream 有很多构造方法，这里仅列出几种常用的：  
- `Stream<T>.value(T value)`  
创建一个产出单个值的单播流，当值被产出时，这个流也宣告结束（Completed）。  
```dart
  Stream<String>.value('test').listen(print);       // test
```
- `Stream<T>.periodic(Duration period, [T computation(int computationCount)])`  
创建一个根据周期自动产出值的单播流。值是通过传入的回调函数的返回值产出的，而回调函数的参数是从 `0` 开始的 `int` 类型值。如果不传入回调的话，会一直返回 `null`。
```dart
  Stream<String>.periodic(
    Duration(seconds: 1),
    (value) {
      print(value.runtimeType);     // init, init, ...
      return value.toString();      // 0, 1, ...
    }
  ).listen(print);
```
- `Stream<T>.fromIterable(Iterable<T> elements)`  
创建一个通过传入的可迭代对象产出值的单播流。该流在被监听时开始产出值，在被取消监听，或者可迭代对象的 `Iterator.moveNext()` 方法返回 `false` 甚至报错时，停止执行。可以通过 `StreamSubscription` 对象的 `pause` 方法，挂起产出的执行。  
```dart
  final testStream = Stream<String>.fromIterable(['Just', 'A', 'Test']);
  testStream.listen(print);     // Just, A, Test
```
- `Stream<T>.fromFuture(Future<T> future)`  
创建一个根据传入的 `future` 产出值的流。当 `future` 变为 `Completed` 状态时，该流则产出这个值（不管是 `Completed(Value)` 还是 `Completed(Error)`），然后该流结束。  
```dart
  final testStream = Stream<String>.fromFuture(
      Future.delayed(Duration(seconds: 2), () => 'future')
  );
  testStream.listen(print);     // future
```
- `Stream<T>.fromFutures(Iterable<Future<T>> futures)`  
通过一组 `future` 来创建一个单播流。该流根据 `future` 的完成顺序（即变为 `Completed` 状态，`value` 或者 `error`）来产出值。当所有 `future` 都完成时，流也变为 `Completed` 并关闭。如果 `futures` 是空的，则流立即关闭。
```dart
  final testStream = Stream<String>.fromFutures([
    Future.delayed(Duration(seconds: 1), () => 'future1'),
    Future.delayed(Duration(seconds: 3), () => 'future2'),
    Future.delayed(Duration(seconds: 2), () => 'future3'),
    Future.delayed(Duration(seconds: 4), () => 'future4'),
    Future.value('future5'),
    Future.value('future6')
  ]);
  testStream.listen(print);     // future5, future6, future1, future3, future2, future4
```

3). StreamController 创建流  
