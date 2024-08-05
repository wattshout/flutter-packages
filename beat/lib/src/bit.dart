import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'helper_bits.dart';

enum LogLevel {
  user,
  info,
  debug,
  trace;
}

// ██████  ██ ████████
// ██   ██ ██    ██
// ██████  ██    ██
// ██   ██ ██    ██
// ██████  ██    ██

abstract base class Bit extends ReceivableBit {
  Bit() {
    BitChannel.join(bitChannel, from: this);
  }

  String get bitChannel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bit && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  Map<String, dynamic> get data => {"bit_channel": bitChannel};

  @override
  String get qualifier => "New Bit $runtimeType";

  static LogLevel logLevel = LogLevel.info;
  static final Map<String, dynamic> globals = {};
}

// ██████  ██ ████████      ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██
// ██████  ██    ██        ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██
// ██████  ██    ██         ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████

final class BitChannel extends ReceivableBit {
  BitChannel._(this._name);

  final String _name;

  final List<BitReceiver> _list = [];

  @override
  String get qualifier => "New BitChannel #$_name";

  static join(String channel, {required Core from}) {
    if (!_map.containsKey(channel)) _map[channel] = BitChannel._(channel);
    final bitChannel = _map[channel]!;

    switch (from) {
      case Bit bit:
        for (final BitReceiver r in List.unmodifiable(bitChannel._list)) {
          r._onBit(bit);
        }

      case BitReceiver _:
        if (bitChannel._list.contains(from)) {
          throw Exception("${from.runtimeType} has joined #$channel already");
        }
        bitChannel._list.add(from);
        if (kDebugMode) print(from._toJson());
        Log("${from.runtimeType} has joined #$channel");
    }

    return bitChannel;
  }

  static leave(String channel, {required Core from}) {
    final bitChannel = _map[channel]!;
    if (!bitChannel._list.contains(from)) {
      throw Exception("${from.runtimeType} has left #${bitChannel._name}");
    }
    bitChannel._list.remove(from);
    Log("${from.runtimeType} has left #${bitChannel._name}");
  }
  // static leave({required Core from}) {
  //   final BitChannel bitChannel =
  //       _map.values.singleWhere((e) => e._list.contains(from));
  //   if (!bitChannel._list.contains(from)) {
  //     throw Exception("${from.runtimeType} has left #${bitChannel._name}");
  //   }
  //   bitChannel._list.remove(from);
  //   Log("${from.runtimeType} has left #${bitChannel._name}");
  // }

  static final Map<String, BitChannel> _map = {};
}

// ██████  ██ ████████     ██████  ███████  ██████ ███████ ██ ██    ██ ███████ ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██ ██    ██ ██      ██   ██
// ██████  ██    ██        ██████  █████   ██      █████   ██ ██    ██ █████   ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██  ██  ██  ██      ██   ██
// ██████  ██    ██        ██   ██ ███████  ██████ ███████ ██   ████   ███████ ██   ██

mixin BitReceiver implements Core {
  Map<Type, Function(Bit bit)> get bitMap;

  _onBit(Bit bit);

  @override
  String get qualifier => "New BitReceiver $runtimeType";

  static _onBitBuilder(BitReceiver r) => (Bit bit) {
        if (!r.bitMap.containsKey(bit.runtimeType)) {
          // Dev("Receiver doesn't handle bit", data: {
          //   "receiver": r.runtimeType,
          //   "bit": bit._toJson(),
          // });
          return;
        }
        r.bitMap[bit.runtimeType]!(bit);
      };

  static _toJsonBuilder(BitReceiver r) => ([bool ignoreLogLevel = false]) => {
        "qualifier": r.qualifier,
        // LogLevel.info
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.info).isNegative) ...{
          "runtime_type": r.runtimeType,
          if (Bit.globals.isNotEmpty) "globals": Bit.globals,
        },
        // LogLevel.debug
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.debug).isNegative) ...{
          "id": r._id,
          "timestamp": r._timestamp,
        },
        // LogLevel.trace
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.trace).isNegative) ...{
          "stack_trace": r._stackTrace,
        },
      };
}

mixin BitService implements BitReceiver {
  @override
  _onBit(Bit bit) => BitReceiver._onBitBuilder(this)(bit);

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) =>
      BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

  @override
  String get qualifier => "New BitService $runtimeType";
}

mixin BitState<T extends StatefulWidget> on State<T> implements BitReceiver {
  get bitChannel;

  @override
  _onBit(Bit bit) => BitReceiver._onBitBuilder(this)(bit);

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) =>
      BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

  @override
  void initState() {
    BitChannel.join(bitChannel, from: this);
    super.initState();
  }

  @override
  void dispose() {
    BitChannel.leave(bitChannel, from: this);
    super.dispose();
  }

  rebuildOn<B>(Bit bit) {
    if (bit is! B) return;
    setState(() {});
  }

  @override
  String get qualifier => "New BitState $runtimeType";
}

mixin OnBit<B extends Bit> on StatelessWidget implements BitReceiver {
  get bitChannel;

  @override
  StatelessElement createElement() {
    BitChannel.join(bitChannel, from: this);
    return _map[this] = super.createElement();
  }

  @override
  get bitMap => {};

  @override
  _onBit(Bit bit) {
    if (bit is! B) return;

    if (!_map[this]!.mounted) {
      BitChannel.leave(bitChannel, from: this);
      _map.remove(this);
      return;
    }

    _map[this]!.markNeedsBuild();
  }

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) =>
      BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

  @override
  get qualifier => "New OnBit $runtimeType";

  static final Map<OnBit, Element> _map = {};
}

// ██████  ███████  ██████ ███████ ██ ██    ██  █████  ██████  ██      ███████     ██████  ██ ████████
// ██   ██ ██      ██      ██      ██ ██    ██ ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██████  █████   ██      █████   ██ ██    ██ ███████ ██████  ██      █████       ██████  ██    ██
// ██   ██ ██      ██      ██      ██  ██  ██  ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██   ██ ███████  ██████ ███████ ██   ████   ██   ██ ██████  ███████ ███████     ██████  ██    ██

abstract base class ReceivableBit with Core {
  ReceivableBit() {
    if (kDebugMode) print(_toJson());
  }

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) => {
        ...super._toJson(ignoreLogLevel),
        if (data.isNotEmpty) "data": data,
      };

  Map<String, dynamic> get data => {};

  @override
  String get qualifier => "New ReceivableBit $runtimeType";
}

//  ██████  ██████  ██████  ███████
// ██      ██    ██ ██   ██ ██
// ██      ██    ██ ██████  █████
// ██      ██    ██ ██   ██ ██
//  ██████  ██████  ██   ██ ███████

mixin Core {
  final int _id = _idCounter++;
  final DateTime _timestamp = DateTime.timestamp();
  final StackTrace _stackTrace = StackTrace.current;

  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) => {
        "qualifier": qualifier,
        // LogLevel.info
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.info).isNegative) ...{
          "runtime_type": runtimeType,
          if (Bit.globals.isNotEmpty) "globals": Bit.globals,
        },
        // LogLevel.debug
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.debug).isNegative) ...{
          "id": _id,
          "timestamp": _timestamp,
        },
        // LogLevel.trace
        if (ignoreLogLevel ||
            !Enum.compareByIndex(Bit.logLevel, LogLevel.trace).isNegative) ...{
          "stack_trace": _stackTrace,
        },
      };

  String get qualifier => "New Core $runtimeType";

  static int _idCounter = 0;
}
