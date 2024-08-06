import 'package:bitchannel/bitchannel.dart';
import 'package:flutter/material.dart';

void main() {
  Bit.logLevel = LogLevel.debug;
  runApp(const MyApp());
  test();
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
      home: const MyWeirdScaffolds(),
    );
  }

  @override
  String get bitChannel => "testChannel";

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

class MyWeirdScaffolds extends StatefulWidget {
  const MyWeirdScaffolds({
    super.key,
  });

  @override
  State<MyWeirdScaffolds> createState() => _MyWeirdScaffoldsState();
}

class _MyWeirdScaffoldsState extends State<MyWeirdScaffolds> with BitState {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Scaffold(
            body: _requestBit != null
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text("Nothing")),
            appBar: AppBar(
              actions: [
                if (_requestBit != null)
                  IconButton(
                    onPressed: () => ResponseOK(requestBit: _requestBit!),
                    icon: const Icon(Icons.anchor_sharp),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: MyScaffold()),
      ],
    );
  }

  @override
  String get bitChannel => "testChannel";

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        TestBit: _onTestBit,
        TestRequest: _onTestRequest,
        ResponseOK: _onResponseOK,
      };

  bool _debug = false;

  _onTestBit(Bit bit) {
    if (bit is! TestBit) return;
    setState(() {
      _debug = !_debug;
    });
  }

  RequestBit? _requestBit;

  _onTestRequest(Bit bit) {
    if (bit is! TestRequest) return;
    setState(() {
      _requestBit = bit;
    });
  }

  _onResponseOK(Bit bit) {
    if (bit is! ResponseOK) return;
    if (bit.requestBit != _requestBit) return;
    setState(() {
      _requestBit = null;
    });
    final SnackBar snackBar = SnackBar(content: Text(bit.qualifier));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

final class TestBit extends Bit {
  @override
  String get bitChannel => "testChannel";
}

test() {
  Bit.logLevel = LogLevel.user;
  TestService();
  TestBit();
}

final class TestService with BitService {
  TestService() {
    BitChannel.join("testChannel", from: this);
  }

  @override
  Map<Type, Function(Bit bit)> get bitMap => {
        // ignore: avoid_print
        TestBit: (bit) => print("WOW"),
      };
}

class MyScaffold extends StatelessWidget with OnBit<TestBit> {
  MyScaffold({
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
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => TestRequest(),
            icon: const Icon(Icons.textsms),
          ),
        ],
      ),
    );
  }

  @override
  get bitChannel => "testChannel";
}

final class TestRequest extends RequestBit {
  @override
  String get bitChannel => "testChannel";
}
