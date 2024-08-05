import 'package:beat/beat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  test();
}

test() {
  Bit.logLevel = LogLevel.user;
  TestService();
  TestBit();
}

final class TestBit extends Bit {
  @override
  String get bitChannel => "test";

  @override
  Map<String, dynamic> get data => {
        "something": "in the way",
      };
}

final class TestService with BitService {
  TestService() {
    BitChannel.join("test", from: this);
  }

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        // TestBit: (bit) => print("WOW"),
      };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with BitState {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: _debug,
      home: const MyScaffold(),
    );
  }

  @override
  get bitChannel => "test";

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        TestBit: _onTestBit,
      };

  bool _debug = false;

  _onTestBit(Bit bit) {
    if (bit is! TestBit) return;
    setState(() {
      _debug = !_debug;
    });
  }
}

class MyScaffold extends StatelessWidget with OnBit<TestBit> {
  const MyScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => TestBit(),
          child: Text(DateTime.now().toString()),
        ),
      ),
    );
  }

  @override
  get bitChannel => "test";
}
