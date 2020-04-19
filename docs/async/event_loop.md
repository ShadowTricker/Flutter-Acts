# Event Loop（事件循环）  
`Dart` 中的事件循环机制原理与 `Javasript` 中的基本一致。  
Dart 中每一次事件循环都是一个任务队列（`Task Queue`），任务队列由 事件队列（`EventQueue`）和 微任务队列（`MicroQueue`）组成。  
Javascript 中，则是由 宏任务队列（`MacroTaskQueue`）与 微任务队列（`MicroTaskQueue`）。  
`Dart` 中的微任务通过 `scheduleMicroTask` 创建，而诸如 `Future` 等都归类于事件任务。  

首先，这里有几个特殊的点（未找到官方明确说明，个人测试推导之后的结论）：  
1\. `Future` 的 `value`，`error`，`sync`，`microtask` 等方法，如果传入的值是原始值，则 Future 会立即执行；如果传入的 Future，则会等待 Future 执行完毕之后再执行。  
```dart
  final Future<String> future1 = Future(() => 'Future1');
  future1.then(print);
  final Future<String> future2 = Future.value(Future(() => 'Future2'));
  future2.then(print);
  final Future<String> future3 = Future.value('Future3');
  future3.then(print);

  // output
  // Future3
  // Future1
  // Future2
```
2\. `Future` 的 `then` 方法可以考虑成是以 `微任务形式` 执行的。  
3\. 每一次事件循环，`都先执行队列中的微任务`，事件任务一旦产生 `微任务`，下一个事件执行前都 `先执行并清空微任务`；一次事件循环可以执行多个微任务，但只执行一个事件任务。  
4\. 微任务产生微任务，按照 `层级顺序` 执行。  
```dart
  scheduleMicrotask(() {
    print('1');

    scheduleMicrotask(() {
      print('2');
      print('3');
    });

    scheduleMicrotask(() {
      print('4');

      scheduleMicrotask(() {
        print('5');
      });
    });
  });

  scheduleMicrotask(() {
    print('6');

    scheduleMicrotask(() {
      print('7');
      print('8');
    });

    scheduleMicrotask(() {
      print('9');

      scheduleMicrotask(() {
        print('10');
      });
    });
  });

  // output: 1 6 2 3 4 7 8 9 5 10
```

> 在 `Javascript` 中，任务队列分为 宏任务（MacroTask）和 微任务（MicroTask）。  
> `Promise 的 thenable` 和 `UI更新` 在 Javascript 中是常见的微任务。  

创建 Future（Promise）本身是同步任务，快慢取决于返回结果的时机，thenable API 的执行是微任务。  
例：  
```dart
  void eventLoopSequenceSimple() {
    print('start');
    Future.delayed(Duration(seconds: 0), () => print('Delay Future'));
    final Future<void> testFuture = Future(() => print('Future'));
    testFuture.then(print);
    Timer(Duration(seconds: 0), () => print('Delay Timer'));
    scheduleMicrotask(() => print('Micro Task'));
    print('end');
  }
```
由上例分析：  
第一次事件循环的队列为（第一次皆为EventTask）：  
`1. 输出 Start`  
`2. 执行 Future.delay，添加 Delay Future 到下一次 EventQueue`  
`3. 创建 Future，添加 Future 到下一次 EventQueue`  
`4. 执行 Timer， 添加 Delay Timer 到下一次 EventQueue`  
`5. 创建 ScheduleMicroTask 微任务， 添加 Micro Task 到下一次 MicroQueue`  
`6. 输出 End`  
此时，因为 **微任务总是优先执行**，所以最终第二次事件循环的队列为：  
`1. 输出 'Micro Task'`  
`2. 输出 'Delay Future'`  
`3. 输出 'Future'`  
`4. 输出 null`  
`5. 输出 'Delay Timer'`  

所以最终的表现结果为：  
`start`， `end`， `Micro Task`， `Delay Future`， `Future`， `null`， `Delay Timer`；  
附 JS 代码：  
```ts
  function test() {
    console.log('start');
    const testPromise1 = new Promise((resolve) => {
        setTimeout(() => {
            resolve(1);
        }, 0);
    });
    const testPromise2 =  new Promise((resolve) => {
        resolve(2);
    });
    const testPromise3 = new Promise((resolve) => {
        setTimeout(() => {
            resolve(3);
        }, 0);
    });
    testPromise3.then(console.log);
    testPromise1.then(console.log);
    testPromise2.then(console.log);
    console.log('end');
  }

  function testAsync() {
    console.log('start');
    setTimeout(() => {
      console.log('timer');
    }, 0);
    Promise.resolve().then(() => {
      console.log('promise1-1');
    }).then(value => {
      console.log('promise1-2');
    });

    Promise.resolve().then(() => {
      console.log('promise2-1');
    }).then(value => {
      console.log('promise2-2');
    });

    console.log('end');
  }

  /* output: */
  // 'start'
  // 'end'
  // 'promise1-1'
  // 'promise2-1'
  // 'promise1-2'
  // 'promise2-2'
  // 'timer'
```

另外一个非常复杂的例子：  
```dart
  void eventLoopSequenceDifficult() {
    print('start');
    Future.delayed(Duration(seconds: 0), () => print('f1'));

    scheduleMicrotask(() => print('f2'));

    Future(() {
      print('f3');
      scheduleMicrotask(() {
        print('f4');
        Future(() {
          print('f5');
          return 'f6';
        }).then(print);
      });
    }).then((_) {
      print('f7');
      Future(() => 'f8').then(print);
      scheduleMicrotask(() => print('f9'));
    });

    Future.value(Future(() => 'f10')).then(print);

    Future(() {
      print('f11');
      return 'f12';
    }).then(print);

    scheduleMicrotask(() {
      print('f13');
      Future(() {
        print('f14');
      });
    });

    Future.value('f15').then(print);

    Future.value(Future(() => 'f16')).then(print);

    Future.error('f17').then(print).catchError(print);

    Future.sync(() => 'f18').then(print);

    Future.microtask(() => 'f19').then(print);

    scheduleMicrotask(() => print('f20'));
    print('end');
  }
```
结果如下：  
```dart
start end
f2 f13 f15 f17 f18 f19 f20
f1 f3 f7
f4 f9
f10 f11 f12 f16 f14 f8 f5 f6
```

---
