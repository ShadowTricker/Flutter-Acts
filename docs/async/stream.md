# Stream  
### 1\. 生成器/迭代器（Generator/Iterator）  
`Dart` 语言中提供了两种生成器函数，`同步（Sync`）的生成器返回一个 `可迭代对象（Iterable Object）`，而 `异步（Async`）的生成器返回一个 `流（Stream`）。如下例：  
```dart
// A synchronous generator function generates an Iterator Object
Iterable<int> naturalsTo(int n) sync* {
  int k = 0;
  while (k < n) yield k++;
}

// An asynchronous generator function generates a Stream
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

---

### 2\. 单订阅流与多播流（Single-Subscription & Broadcast）  
Dart 中的流有两种，一种是单订阅流，一种是多播流。  
#### 1). 单订阅流（Single-Subscription Stream）  
**单订阅流在它整个生命周期中只允许被一个监听者监听一次**。在没有监听者监听时，它并不产生值，只有在被监听后，才会产出值。当监听者取消监听后，停止产生值，哪怕依然存在可以产出的值。  
监听同一个单订阅流两次以上是不被允许的，哪怕在前一个监听者取消监听后再去监听也是不允许的。如：  
```dart
  final Stream<String> testStream = Stream.periodic(
    Duration(seconds: 1),
    (int i) => 'event$i'
  );

  final StreamSubscription<String> testSubscription1 = testStream.listen(print);
  StreamSubscription<String> testSubscription2;

  Future.delayed(Duration(seconds: 2), () {
    testSubscription1.cancel();
    testSubscription2 = testStream.listen(print);
  });

  Future.delayed(Duration(seconds: 4), () {
    testSubscription2.cancel();
  });

  // output
  // event0
  // event1
  // Uncaught Error: Bad state: Stream has already been listened to.
  // Uncaught Error: NoSuchMethodError: method not found: 'cancel$0' on null
```
上例中，在取消了第一次监听打算开始第二次监听时，会报错说 `流已经被监听了`，而在 `4s` 时，因为第二次没有监听成功，所以会报出 `onCancel` 在 `null` 上不存在的错误。  
单订阅流一般用于大模块数据的传输，比如 `file` 系统的 `I/O`。

#### 2). 多播流（Broadcast Stream）  
多播流准许任意数量的监听者，且无论是否有监听者，它都能产生值。如果在流已经被监听的途中加入另外一个监听者，那么新加入的监听者只能接收到该流后续没有产出的值。  
```dart
  final Stream<String> testStream = Stream.periodic(Duration(seconds: 1), (int i) => 'event $i').asBroadcastStream();

  final StreamSubscription<String> testSubscription1 = testStream.listen((value) => print('listener1: $value'));

  StreamSubscription<String> testSubscription2;

  Future.delayed(Duration(seconds: 4), () {
    testSubscription2 = testStream.listen((value) => print('listener2: $value'));
  });

  Future.delayed(Duration(seconds: 8), () {
    testSubscription1.cancel();
    testSubscription2.cancel();
  });

  // output
  // listener1: event 0
  // listener1: event 1
  // listener1: event 2
  // listener1: event 3
  // listener1: event 4
  // listener2: event 4
  // listener1: event 5
  // listener2: event 5
  // listener1: event 6
  // listener2: event 6
  // listener1: event 7
  // listener2: event 7
```
第二个监听者在 `4s` 时开始监听，所以此时它收到第一个值是从 `4` 开始的。  
在上例中，使用了 asBroadcastStream() 方法，它可以将单订阅流转成多播流。  
每个监听者对于多播流的监听都可以看做对一个新流的监听（当然已经产出的值除外），因为每一个监听者对流的控制都是独立的，不会相互影响的。  
比如，两个监听者同时监听了一个多播流，其中的一个监听者对该流进行了 `暂停（Pause）` 操作，但是另一个监听者的监听行为依然在继续着。
```dart
  final Stream<String> testStream = Stream.periodic(Duration(seconds: 1), (int i) => 'event $i').asBroadcastStream();

  final StreamSubscription<String> testSubscription1 = testStream.listen((value) => print('listener1: $value'));

  final StreamSubscription<String> testSubscription2 = testStream.listen((value) => print('listener2: $value'));

  Future.delayed(Duration(seconds: 4), () => testSubscription2.pause());

  Future.delayed(Duration(seconds: 6), () => testSubscription2.resume());

  Future.delayed(Duration(seconds: 8), () {
    testSubscription1.cancel();
    testSubscription2.cancel();
  });

  // output
  // listener1: event 0
  // listener2: event 0
  // listener1: event 1
  // listener2: event 1
  // listener1: event 2
  // listener2: event 2
  // listener1: event 3
  // listener2: event 3
  // listener1: event 4
  // listener1: event 5
  // listener2: event 4
  // listener2: event 5
  // listener1: event 6
  // listener2: event 6
  // listener1: event 7
  // listener2: event 7
```
`4s` 时，`listener2` 暂停了对流的监听，此时它所监听的流的值开始进入缓冲，而 `listener1` 并没有受到影响，依然继续接收值。  
`6s` 时，`listnener2` 恢复了对流的监听，此时缓冲区的值瞬间被监听者接收，在控制台打印日志，而后面则跟 `listener1` 一起接收后面的值。  

当 `流（Stream）` 完成了所有的值得产出后，会发出 `done` 事件，然后结束该流，流就没有监听者了。在流结束后依然可以监听流，只不过会立刻接收到 `done` 事件而已。

如果要在 `Stream` 类上继承多播流，记得重写 `isBroadcast` 属性，因为默认的值是 `false`。

---

### 3\. 创建流（Create Stream）  
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
创建一个产出单个值的单订阅流，当值被产出时，这个流也宣告结束（Completed）。  
```dart
  Stream<String>.value('test').listen(print);       // test
```
- `Stream<T>.periodic(Duration period, [T computation(int computationCount)])`  
创建一个根据周期自动产出值的单订阅流。值是通过传入的回调函数的返回值产出的，而回调函数的参数是从 `0` 开始的 `int` 类型值。如果不传入回调的话，会一直返回 `null`。
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
创建一个通过传入的可迭代对象产出值的单订阅流。该流在被监听时开始产出值，在被取消监听，或者可迭代对象的 `Iterator.moveNext()` 方法返回 `false` 甚至报错时，停止执行。可以通过 `StreamSubscription` 对象的 `pause` 方法，挂起产出的执行。  
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
通过一组 `future` 来创建一个单订阅流。该流根据 `future` 的完成顺序（即变为 `Completed` 状态，`value` 或者 `error`）来产出值。当所有 `future` 都完成时，流也变为 `Completed` 并关闭。如果 `futures` 是空的，则流立即关闭。
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

#### 3). StreamController 创建流  
Dart 提供了 StreamController 来创建流，使用 StreamController 创建的流可以自己来控制数据产出的时机。  
```dart
  final StreamController<int> testStreamController = StreamController();

  final subscription = testStreamController.stream.listen(print);   // 1, 2

  testStreamController.add(1);
  testStreamController.add(2);
```
如上例，通过调用 `StreamController` 提供的 `add` 方法，可以更新 `流的值`。  
此处可以看出，`Dart` 中的流具有 `事件机制（观察者模式）`，当触发事件时，`监听者可以更新自身的状态`。`Flutter` 状态管理库 `Bloc`，底层的实现机制就是利用流的事件机制。  

> StreamController 的构造方法  
```dart
  StreamController({
    void onListen(),
    void onPause(),
    void onResume(),
    void onCancel(),
    bool sync: false
  })
```
- `StreamController`：创建一个单订阅流，只能被一个监听者监听。  
- `onListen`：当有监听者监听该流时被调用。  
- `onCancel`：监听者取消监听该流时被调用。  
- `onPause`：监听者暂停对流的监听时被调用。  
- `onResume`：监听者恢复流的暂停状态时被调用。  
- `sync`：流是否是同步的，默认为 `false`。  

```dart
  StreamController.broadcast({
    void onListen(),
    void onCancel(),
    bool sync: false
  })
```
在多播流中，每一个监听者的订阅都是独立运行的，比如对该流的一个订阅者使用 cancel 方法，取消的只是当前的订阅，而其他的订阅则不会受到影响。  
```dart
  // create a broadcast stream
  final StreamController<int> testStreamController = StreamController.broadcast();

  // subscribe the stream
  final test1 = testStreamController.stream.listen((value) {
    print('test1');
    print(value);
  });
  final test2 = testStreamController.stream.listen((value) {
    print('test2');
    print(value);
  });
  StreamSubscription test3;

  Future.delayed(Duration(seconds: 1), () => testStreamController.add(1));
  Future.delayed(Duration(seconds: 2), () => testStreamController.add(2));
  Future.delayed(Duration(seconds: 2), () {
    test1.cancel();
    test3 = testStreamController.stream.listen((value) {
      print('test3');
      print(value);
    });
  });
  Future.delayed(Duration(seconds: 3), () => testStreamController.add(3));
  Future.delayed(Duration(seconds: 4), () => testStreamController.add(4));
  Future.delayed(Duration(seconds: 5), () {
    test2.cancel();
    test3.cancel();
    testStreamController.close();
  });

  // output
  // test1
  // 1
  // test2
  // 1
  // test1
  // 2
  // test2
  // 2
  // test2
  // 3
  // test3
  // 3
  // test2
  // 4
  // test3
  // 4
```
如上例，在一开始 `test1` 和 `test2` 对 `testStreamController` 中的 `stream` 进行订阅，两秒后，`test1` 取消了对 `stream` 的订阅，`test3` 则在此时对 `stream` 进行了订阅。而此时 `test2` 依然对 `stream` `正常的进行着监听。test3` 因为在 `2s` 后才对 `stream` 进行监听，所以它只能接收到 `2s` 以后 `stream` 中发出的值。  

> StreamController 常用的属性和方法  
- `StreamController.stream`  
`stream` 是只读属性，它返回这个 `controller` 所控制的 `stream。`  
- `StreamController.add(T event)`  
发送一个 `data` 事件，监听者将在下一个 `微任务（MicroTask）`收到这个事件。  
- `StreamController.close()`  
发送一个 `done` 事件，并关闭该 `stream。`


---

