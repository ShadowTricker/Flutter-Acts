# Event Loop（事件循环）  
`Dart` 中的事件循环机制与 `Javasript` 中的基本一致。  
每一次事件循环都是一个任务队列（`Task Queue`），每个任务队列由 宏任务（`MacroTask`）和 微任务（`MicroTask`）组成。  
微任务常用的有两种 `Future`（JS 的 Promise） 和 `UI 更新`， 除却这两种以外的大部分任务都是宏任务。  
执行的顺序是，每一次事件循环，**都先执行队列中的** `微任务`，当微任务完成时，执行`宏任务`。  
例：  
```dart
    print('start');
    final Future<String> testFuture = Future(() => 'Future');
    Future.delayed(Duration(seconds: 0), () => print('Delay'));
    testFuture.then(print);
    print('end');
```
由上例分析：  
第一次事件循环的队列为：  
`1.输出Start(Macro)`，  `2.创建Future(Macro)`，  `3.创建延迟(Macro)`，  `4.输出End(Macro)`；  
此时，Future 和 延迟 分别创建了一个微任务 和 宏任务，所以第二次事件循环的队列为：   
`1.输出 Delay(Macro)`， `2.输出 Future(Micro)`；  
但由于 **微任务总是先于宏任务执行**， 所以实际的情况是：  
`1.输出 Future(Micro)`， `2.输出 Delay(Macro)`；  
所以最终的表现结果为：  
`start`， `end`， `Future`， `Delay`  

再来个复杂一点的例子：  
```dart
    print('start');
    final Future<String> testFuture1 = Future(() => 'Future1');
    final Future<String> testFuture2 = Future(() => 'Future2');
    final Future<String> testFuture3 = Future(() => 'Future3');
    final Future<String> testFuture4 = Future(() => 'Future4');
    Future.delayed(Duration(seconds: 0), () => print('Delay1'));
    testFuture1
      .then((value) {
        print(value);
        return testFuture2;
      })
      .then((value) {
        print(value);
        return testFuture3;
      })
      .then((value) {
        print(value);
        Future.delayed(Duration(seconds: 0), () => print('Delay2'));
        print('test');
        return testFuture4;
      })
      .then(print);
    print('end');
```
第一次事件循环队列为（**第一次都是宏任务**）：  
`start`， `创建Future1`， `创建Future2`， `创建Future3`， `创建Future4`， `创建 Delay1`，`执行testFuture1`， `end`  
此时第二次事件循环的队列为（**除Delay1外，都是微任务**）：  
`输出 Future1`， `输出 Future2`， `输出 Future3`， `创建 Delay2`， `输出 Future4`， `输出 Delay1(Macro)`，  
由于在 Future 中创建了 Delay2， 所以第三次事件循环有一个单一的宏任务：  
`输出 Delay2(Marco)`  
所以最终结果是：  
`start`, `end`, `Future1`, `Future2`, `Future3`, `test`, `Future4`, `Delay1`, `Delay2`

---
