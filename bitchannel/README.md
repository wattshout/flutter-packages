# bitchannel
A mix between an event-oriented package and a communication infrastructure package based on channels and bits of information.

## Installation
Run the following command:
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
You can join a channel using the BitChannel class:

```dart
void main() {
  BitChannel.join("test_channel", from: MyBitReceiver());
}
```

### Log Level
You can change the log level:

```dart
void main() {
  Bit.logLevel = LogLevel.trace;
}
```

### Global Data
Set global data to be included with all bits:

```dart
void main() {
  Bit.globals = {
    "hello": "world",
  };
}
```

## Additional Information
For more details, check out the example/main.dart for an illustration of the feature set.

## About this package
This package is the result of many iterations and ideas inspired by a great [article](https://itnext.io/mvvm-in-flutter-from-scratch-17757b6433eb) from [Martin Nowosad](https://github.com/MrIceman).