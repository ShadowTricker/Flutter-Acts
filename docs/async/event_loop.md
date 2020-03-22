# Event Loop（事件循环）  
`Dart` 中的事件循环机制原理与 `Javasript` 中的基本一致。  
每一次事件循环都是一个任务队列（`Task Queue`），每个任务队列由 事件队列（`EventQueue`）和 微任务队列（`MicroQueue`）组成。  
不同的是在两种语言中，宏任务和微任务的分类是不同的。  
`Dart` 中的微任务通过 `scheduleMicroTask` 创建，而诸如 `Future` 等都归类于事件任务。
> 在 `Javascript` 中，任务队列分为 宏任务（MacroTask）和 微任务（MicroTask）。  
> 与 `Future` 概念类似的 `Promise` 是属于微任务的范畴，`Promise` 和 `UI更新` 在 Javascript 中是常见的微任务， 但在 Dart 中则不是。  

执行的顺序是，每一次事件循环，**都先执行队列中的** `微任务`，当微任务完成时，执行`宏任务`。  
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
`2. 执行 Future.delay，添加 Delay Future 到下一次事件循环`  
`3. 创建 Future，添加 Future 到下一次事件循环`  
`4. 执行 Timer， 添加 Delay Timer 到下一次事件循环`  
`5. 创建 ScheduleMicroTask 微任务， 添加 Micro Task 到下一次事件循环`  
`6. 输出 End`  
此时，因为 **微任务总是优先执行**，所以最终第二次事件循环的对列为：  
`1. 输出 'Micro Task'`  
`2. 输出 'Delay Future'`  
`3. 输出 'Future'`  
`4. 输出 null`  
`5. 输出 'Delay Timer'`  

所以最终的表现结果为：  
`start`， `end`， `Micro Task`， `Delay Future`， `Future`， `null`， `Delay Timer`；  

重点在输出 `Future` 之后， 执行了 `then` 方法输出了 `null` 而不是输出 `Delay Timer`， 这是与 `Javascript` 所区别的地方。  
附 JS 代码：  
```ts
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



---
