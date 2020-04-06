# Future  
`Dart` 中的 `Future` 与 `Javascript` 中的 `Promise` 使用方法基本一致。  
### 1\. Future 的状态  
Future 有两种状态：`Completed`， `Uncompleted`。  
执行完毕之后，状态是固定的，无法改变。  
当 `Future` 执行时，状态由 `Uncompleted => Completed`， 当状态变为 `Completed` 之后，`Future` 的状态就不会再改变了， 所以 `Future` 中的值在此之后无论何时都是一定的。  
`Completed` 也有两种状态： `Completed(Value)`， `Completed(Error)`，此状态由 Future 执行异步函数时是否发生错误来确定。  
> Javascript 中的 Promise 状态有三种，其实就是把 value 和 error 的状态拆分开，变为 pending（执行中），fulfilled（执行成功），reject（执行错误）。  
```dart
    /// future with completed(value) status
    final Future<int> futureSuccess = Future(() {
      return 123;
    });
    futureSuccess.then(print);
    futureSuccess.then(print);

    /* output: */
    // 123
    // 123

    /// future with completed(error) status
    final Future<dynamic> futureFailure = Future(() {
      throw Exception('execute failed');
    });

    futureFailure
      .then(print)
      .catchError(print);

    /* output: */
    // execute failed
```

### 2\. Thenable API  
如果 `Future` 内部成功执行， 则会执行 `then` 方法， 如果执行错误，则会执行 `catchError` 方法，具体如下：  
```dart
  void futureSuccess() {
    final Future<int> futureSuccess = Future(() {
      return 123;
    });
    futureSuccess.then(print);
  }
  /* output: */
  // 123

  void futureFailure() {
    final Future<dynamic> futureFailure = Future(() {
      throw Exception('execute failed');
    });

    futureFailure.then(print).catchError(print);
  }
  /* output: */
  // 'execute failed'
```
如上 `futureFailure` 例，如果后面不写 `catchError`，则执行代码时，将会直接报错而中断，而如果使用 `catchError` 则不会。  
  
`Thenable API` 的存在主要为了链式调用，使异步操作更 `流程化` ，并且解决了 `回调地狱` 的问题。
```dart
  void thenableTest() {
    final Future<String> testFuture1 = Future(() => 'Future1');
    final Future<String> testFuture2 = Future(() => 'Future2');
    final Future<String> testFuture3 = Future(() => 'Future3');
    final Future<String> testFutureError = Future(() => throw Exception('Error'));

    testFuture1
      .then((value) {
        print(value);
        return testFuture2;
      })
      .then((value) {
        print(value);
        return testFutureError;
      })
      .catchError((error) {
        print(error);
        return testFuture3;
      })
      .then((value) {
        print(value);
      });
  }
  /* output: */
  // 'Future1', 'Future2', 'Exeception: Error', 'Future3'
```
如上例所示，`then` 方法流程化了异步操作，并且在 `catchError` 后，依然可以继续使用 `then` 方法。`catchError` 方法之前的任意一个 `Future` 执行错误，都会直接调用 `catchError` 方法，所以可以使用它进行错误处理。

> 在使用上，除了有些名字改变了以外，可以完全以 Javascript 的 Promise 方式去写。

### 3\. async/await  
Dart 中支持了 `async/await` 关键字配合来以同步的形式写异步代码，其在 Thenable API 的基础上大大减少了重复代码量，更重要的是它使异步的代码 `更加优雅` 和 `便于理解`。  
下面是配合使用的例子：
```dart
    Future<void> asyncSuccess() async {
        final Future<int> futureSuccess = Future(() {
            return 123;
        });
        // final int num = await futureSuccess;
        // print(num);
        print(await futureSuccess);
    }
```
如上例，在函数体前加上 `async` 可以使函数体内部使用 `await` 关键字，以类似同步的方式来写异步处理。  
**async 和 await 关键字需要配合使用。**  

其实，单独在函数体前加上 `async` 关键字，而**函数体内部不使用 `await` 关键字**的话，函数是完全 **以同步的方式去运行** 的。  
而如果 **内部使用了 `await` 关键字**，函数体执行时，`await` 关键字 **之前是同步执行**的， `await` 之后，就都属于 **异步执行**。函数体执行完毕后 `返回 Future<T>`， 即： `T => Future<T>`。
如下例：  
```dart
    Future<void> withAwait() async {
        print('start');
        final Future<int> futureSuccess = Future(() => 123);
        print(await futureSuccess);
        print('end');
    }
    /* output: */
    // 'start', 123, 'end'

    // use thenable API to translate this
    void withAwait() {
        print('start');
        final Future<int> futureSuccess = Future(() => 123);
        futureSuccess.then((value) {
            print(value);
            print('end');
        });
    }
```  
> 经实测，此结论在 Javascript 中同样适用。Dart 在 async/await 的理念跟 Javascript 是完全一致的。  

关于错误处理，因为通过使用 `async/await` 的方式以同步方式写异步处理，所以错误处理也同样使用同步方式的 `try/catch`。如下例：  
```dart
  Future<void> asyncFailure() async {
    final Future<int> futureError = Future(() => throw Exception('Error'));
    try {
      await futureError;
    } catch(err) {
      print(err);
    }
  }
  /* output: */
  // 'Exception: Error'
```

> `async/await` 关键字在 `Javascript`中是以 `Generate/Iterator（生成器/迭代器）` 配合 `Promise` 而产生的 `语法糖`（重点在 next 方法能传参数），但是在实际书写 `Dart` 代码的过程中，使用了 Dart 的 `Generator` 尝试实现 `async/await` 并没有成功， 因为 Dart 中 `Iterator` 的 `next` 方法并不能传值，所以猜测，Dart 底层实现了 async/await 语法， 而不仅仅是类似 Javascript 的语法糖。


### 4\. Completer  
Completer 是 Dart 中手动控制 Future 状态的方式，以此来决定执行传入 Future 中回调的执行时机。
例：  
```dart
  // ...other code
  Future<dynamic> generateFuture() {
    print('generate');
    return _completer.future;
  }

  testCompleter(dynamic value) {
    print('complete');
    _completer.complete(value);
  }

  // ...other code
  _buildIconButton(
    context: context,
    label: 'Generate Future',
    onPressed: () {
      generateFuture().then(print);
    }
  ),
  _buildIconButton(
    context: context,
    label: 'Complete Future',
    onPressed: () {
      testCompleter(1234);
    }
  ),
```
上例中，两个方法分别被绑定到了两个按钮上。  
当点击第一个按钮时，生成了一个 Future，同时为这个 Future 绑定了 then 方法。  
如果不点击第二个按钮，那么这个 Future 它会一直处于 Uncompleted 状态。只有点击了按钮，这个 Future 才会改变状态。  
本质其实是将 Future 的自主运行回调的时机变为了由自己操作执行时机。  

---