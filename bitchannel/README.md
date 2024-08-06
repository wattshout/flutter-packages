# bitchannel
A mix between an event-oriented package and a communication infrastructure package based on channels and bits of information.

## Installation
Run the following command to add the package to your Flutter project:
```bash
flutter pub add bitchannel
```

## Usage
Import the package in your Dart code:
```dart
import 'package:bitchannel/bitchannel.dart';
```

### Creating a Bit
A Bit is a piece of information sent over a channel. You can create your own Bit by extending the Bit class:

```dart
final class TestBit extends Bit {
  @override
  String get bitChannel => "test";

  @override
  Map<String, dynamic> get data => {
        "something": "in the way",
      };
}
```

### Joining a Channel
To start listening to a channel, you can use the `BitChannel.join` method. Here's an example with a receiver:
```dart
class MyBitReceiver with BitService {
  MyBitReceiver() {
    BitChannel.join("testChannel", from: this);
  }

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        TestBit: (bit) => print("Received a TestBit!"),
      };
}

void main() {
  MyBitReceiver();
}
```

### Sending a Bit
To send a Bit, simply create an instance of your Bit class.
Here's an example with the `TestBit` class you created before:
```dart
void main() {
  TestBit();  // This will automatically be sent to the "testChannel"
}
```

### Changing Log Level
You can change the log level to control the verbosity of the logs:
```dart
void main() {
  Bit.logLevel = LogLevel.trace;
}
```

### Setting Global Data
You can set global data that will be included with all bits:
```dart
void main() {
  Bit.globals = {
    "hello": "world",
  };
}
```

### Handling Bits in Widgets
You can handle bits in stateful and stateless widgets by mixing in the appropriate mixins:

#### Stateful Widget
```dart
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> with BitState {
  bool _debug = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BitChannel Example"),
      ),
      body: Center(
        child: Text("Debug mode is ${_debug ? "ON" : "OFF"}"),
      ),
    );
  }

  @override
  String get bitChannel => "testChannel";

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        TestBit: (bit) {
          setState(() {
            _debug = !_debug;
          });
        },
      };
}
```

#### Stateless Widget
```dart
class MyStatelessWidget extends StatelessWidget with OnBit<TestBit> {
  MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BitChannel Example"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () => TestBit(),
          child: Text("Send TestBit"),
        ),
      ),
    );
  }

  @override
  String get bitChannel => "testChannel";
}
```

## Examples
Here's a complete example of a Flutter app using BitChannel:
```dart
import 'package:bitchannel/bitchannel.dart';
import 'package:flutter/material.dart';

void main() {
  Bit.logLevel = LogLevel.debug;
  runApp(const MyApp());
  test();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with BitState {
  bool _debug = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("BitChannel Example"),
        ),
        body: Center(
          child: Text("Debug mode is ${_debug ? "ON" : "OFF"}"),
        ),
      ),
    );
  }

  @override
  String get bitChannel => "testChannel";

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        TestBit: (bit) {
          setState(() {
            _debug = !_debug;
          });
        },
      };
}

class TestBit extends Bit {
  @override
  String get bitChannel => "testChannel";

  @override
  Map<String, dynamic> get data => {
        "something": "in the way",
      };
}

void test() {
  TestBit();
}
```

## Additional Information
For more details, check out the `example/main.dart` for an illustration of the feature set.

## About this package
This package is the result of many iterations and ideas inspired by a great [article](https://itnext.io/mvvm-in-flutter-from-scratch-17757b6433eb) from [Martin Nowosad](https://github.com/MrIceman).