# Stream Transforming & RxDart  
### 1\. 流的转换  
**流可以转换成另外的流**。  
Dart 中提供了一部分转换的函数方法，当然也可以自定义转换流的转换器。  
#### 1). 常用的转换方法  
`Stream<S> map<S>(S convert(T event))`，用于映射值：  
```dart
  final Stream<int> sourceStream = Stream.fromIterable([1, 2, 3]);
  
  final Stream<String> transformedStream = sourceStream.map<String>((int i) => 'event$i');
  
  transformedStream.listen(print);
```

`Stream<T> where(bool test(T event))`，用于过滤值：  
```dart
  final Stream<int> sourceStream = Stream.fromIterable([0, 9, 1, 8, 2, 7, 3, 6, 4, 5]);
  
  final Stream<int> transformedStream = sourceStream.where((int i) => i >= 5);
  
  transformedStream.listen(print);
```

`Stream<T> take(int count)`，取几次值：  
```dart
  final Stream<int> sourceStream = Stream.fromIterable([0, 9, 1, 8, 2, 7, 3, 6, 4, 5]);
  
  final Stream<int> transformedStream = sourceStream.take(4);
  
  transformedStream.listen(print);
```
当然，如果想对流进行多重操作，可以组合操作符，比如：  
```dart
  final Stream<int> sourceStream = Stream.fromIterable([0, 9, 1, 8, 2, 7, 3, 6, 4, 5]);
  
  sourceStream
    .where((int i) => i >= 5)
    .take(3)
    .map<String>((int i) => 'event$i')
    .listen(print);
```

#### 2). 自定义转换方法  
当 Dart 中提供的操作方法无法满足自身的需求时，可以使用 transform 方法传入自己定义的转换器。  
```dart
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) {
    return streamTransformer.bind(this);
  }
```
上面 `transform` 方法的定义中， 传入一个转换器 `StreamTransformer` 实例，该实例在执行方法时，将使用 `T` 类型作为输入类型（通过 `bind(this)`），`S` 类型作为输出类型返回，`tranform` 方法则继续返回该转换器输出的类型 `S`。转换的本质是 **使用输出的流产出一个新的流**。  
`StreamTransformer` 拥有三种构造方法：  
```dart
  StreamTransformer<T, S>(
    StreamSubscription onListen(
      Stream<S> stream,
      bool cancelOnError
    )
  )
```
第一种， StreamTransformer 接收一个 onListen 回调函数，这个回调函数接收需要转换的 Stream 以及遇到错误是否取消监听的 flag，返回一个 新流的 Subscription。如下例：  
```dart
  //// Starts listening to [input] and stringify all non-error events.
  StreamSubscription<String> _onListen(Stream<int> input, bool cancelOnError) {
    StreamSubscription<int> subscription;
    // Create controller that forwards pause, resume and cancel events.
    final controller = new StreamController<String>(
        onPause: () {
          subscription.pause();
        },
        onResume: () {
          subscription.resume();
        },
        onCancel: () => subscription.cancel(),
        sync: true); // "sync" is correct here, since events are forwarded.

    // Listen to the provided stream using `cancelOnError`.
    subscription = input.listen(
      (int data) {
        // stringify the data.
        controller.add('event${ data.toString() }');
      },
      onError: controller.addError,
      onDone: controller.close,
      cancelOnError: cancelOnError
    );

    // Return a new [StreamSubscription] by listening to the controller's
    // stream.
    return controller.stream.listen(null);
  }

// Instantiate a transformer:
  final eventStringParser = StreamTransformer<int, String>(_onListen);

// Use as follows:
  final Stream<int> sourceStream = Stream.fromIterable([0, 9, 1, 8, 2, 7, 3, 6, 4, 5]);
  sourceStream.where((int i) => i >= 5)
    .take(3)
    .transform(eventStringParser)
    .listen(print);
```
分析代码后可以发现，`onListen` 方法内部创建了一个 `StreamController`，然后对输入的流进行监听和值的转化，然后返回新流的 `Subsription`。  

```dart
  StreamTransformer<S, T>.fromHandlers({
    void handleData(
      S data,
      EventSink<T> sink
    ),
    void handleError(
      Object error,
      StackTrace stackTrace,
      EventSink<T> sink
    ),
    void handleDone(
      EventSink<T> sink
    )
  })
```
第二种算是比较常用的方法， 其中 `S` 是输入的类型，`T` 是输出的类型，`handleData`，`handleError`，`handleDone` 则分别对应了流状态的三个方法， `sink` 是新生成的流。  
```dart
  int number = 0;
  final StreamTransformer<int, String> eventStringParser = StreamTransformer<int, String>.fromHandlers(
    handleData: (int value, EventSink<String> sink) {
      number++;
      sink.add('sequence: $number, event${ value.toString() }');
    }
  );

  final Stream<int> sourceStream = Stream.fromIterable([0, 9, 1, 8, 2, 7, 3, 6, 4, 5]).asBroadcastStream();
  sourceStream.where((int i) => i >= 5)
    .take(3)
    .transform(eventStringParser)
    .listen(print);

  sourceStream.where((int i) => i >= 5)
    .take(3)
    .transform(eventStringParser)
    .listen(print);

  // output
  // sequence: 1, event9
  // sequence: 2, event9
  // sequence: 3, event8
  // sequence: 4, event8
  // sequence: 5, event7
  // sequence: 6, event7
```
在创建转换器的时候，多播流是可以共享状态的，如上例中的 `number`，每个流在产出值时都会加1。可以利用这一特性配合 `Dart` 中的闭包，将状态封装在函数内，然后再返回转换器，做一些特殊的操作。  
```dart
  @Since("2.1")
  StreamTransformer<S, T>.fromBind(
    Stream<T> bind(
      Stream<S>
    )
  )
```
通过使用 `bind` 方法，将多个转换器组合到一起生成新的转换器，此方法是 `Dart 2.1` 版本才添加的，使用时要注意版本：  
```dart
  final splitDecoded = StreamTransformer<List<int>, String>.fromBind(
    (stream) => stream.transform(utf8.decoder).transform(LineSplitter())
  );
```

### 2\. RxDart  


