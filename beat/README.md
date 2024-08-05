# bit

Sort of a mix between an event-oriented package and a communication infrastructure package based on channels and bits of information.

## Getting started

Import the package:
```dart
import 'package:bit/bit.dart';
```

## Usage

See example/main.dart for an illustration of the feature set.

## Additional information

### User data in bits

Each bit accepts json data:
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

### Log level

You can also change the log level:
```dart
void main() {
    Bit.logLevel = LogLevel.trace;
}
```

### Global data

You can set global data that will be pushed with ALL bits:
```dart
void main() {
    Bit.globals = {
        "hello": "world",
    };
}
```

## About this package

This package is the result of many iterations and drifting from a great [article](https://itnext.io/mvvm-in-flutter-from-scratch-17757b6433eb) from [Martin Nowosad](https://github.com/MrIceman).