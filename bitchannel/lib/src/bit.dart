import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'helper_bits.dart';

// ██       ██████   ██████      ██      ███████ ██    ██ ███████ ██
// ██      ██    ██ ██           ██      ██      ██    ██ ██      ██
// ██      ██    ██ ██   ███     ██      █████   ██    ██ █████   ██
// ██      ██    ██ ██    ██     ██      ██       ██  ██  ██      ██
// ███████  ██████   ██████      ███████ ███████   ████   ███████ ███████

/// Defines the log levels for bit operations.
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

/// Abstract base class representing a bit of information.
abstract base class Bit extends ReceivableBit {
  Bit() {
    BitChannel.join(bitChannel, from: this);
  }

  /// The channel this bit belongs to.
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

  /// Log level for bits.
  static LogLevel logLevel = LogLevel.info;

  /// Global data shared accross all bits.
  static final Map<String, dynamic> globals = {};
}

// ██████  ██ ████████      ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██
// ██████  ██    ██        ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██
// ██████  ██    ██         ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████

/// Represents a communication channel for bits.
final class BitChannel extends ReceivableBit {
  BitChannel._(this._name);

  final String _name;

  final List<_BitReceiver> _list = [];

  @override
  String get qualifier => "New BitChannel #$_name";

  /// Joins a channel.
  static join(String channel, {required Core from}) {
    if (!_map.containsKey(channel)) _map[channel] = BitChannel._(channel);
    final bitChannel = _map[channel]!;

    switch (from) {
      case Bit bit:
        for (final _BitReceiver r in List.unmodifiable(bitChannel._list)) {
          r._onBit(bit);
        }

      case _BitReceiver _:
        if (bitChannel._list.contains(from)) {
          throw Exception("${from.runtimeType} has joined #$channel already");
        }
        bitChannel._list.add(from);
        if (kDebugMode) print(from._toJson());
        Log("${from.runtimeType} has joined #$channel");
    }

    return bitChannel;
  }

  /// Leaves a channel.
  static leave(String channel, {required Core from}) {
    final bitChannel = _map[channel]!;
    if (!bitChannel._list.contains(from)) {
      throw Exception("${from.runtimeType} has left #${bitChannel._name}");
    }
    bitChannel._list.remove(from);
    Log("${from.runtimeType} has left #${bitChannel._name}");
  }

  static final Map<String, BitChannel> _map = {};
}

// ██████  ██ ████████     ██████  ███████  ██████ ███████ ██ ██    ██ ███████ ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██ ██    ██ ██      ██   ██
// ██████  ██    ██        ██████  █████   ██      █████   ██ ██    ██ █████   ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██  ██  ██  ██      ██   ██
// ██████  ██    ██        ██   ██ ███████  ██████ ███████ ██   ████   ███████ ██   ██

/// Mixin for receiving bits.
mixin _BitReceiver implements Core {
  /// Map of bit types to their handlers.
  Map<Type, Function(Bit bit)> get bitMap;

  /// Handles received bits.
  _onBit(Bit bit);

  @override
  String get qualifier => "New BitReceiver $runtimeType";

  static _onBitBuilder(_BitReceiver r) => (Bit bit) {
        if (!r.bitMap.containsKey(bit.runtimeType)) {
          return;
        }
        Future(() => r.bitMap[bit.runtimeType]!(bit));
      };

  static Map<String, dynamic> Function(
      [bool]) _toJsonBuilder(_BitReceiver r) => (
          [bool ignoreLogLevel = false]) =>
      {
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

/// Mixin for services that receive bits.
mixin BitService implements _BitReceiver {
  @override
  final int _id = Core._idCounter++;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;

  @override
  _onBit(Bit bit) => _BitReceiver._onBitBuilder(this)(bit);

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) =>
      _BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

  @override
  String get qualifier => "New BitService $runtimeType";
}

/// Mixin for stateful widgets that receive bits.
mixin BitState<T extends StatefulWidget> on State<T> implements _BitReceiver {
  @override
  final int _id = Core._idCounter++;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;

  String get bitChannel;

  @override
  _onBit(Bit bit) => _BitReceiver._onBitBuilder(this)(bit);

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) =>
      _BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

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

  /// Rebuilds the widget when a bit of type [B] is received.
  rebuildOn<B>(Bit bit) {
    if (bit is! B) return;
    setState(() {});
  }

  @override
  String get qualifier => "New BitState $runtimeType";
}

/// Mixin for stateless widgets that receive bits.
mixin OnBit<B extends Bit> on StatelessWidget implements _BitReceiver {
  @override
  final int _id = Core._idCounter++;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;

  /// The channel this widget listens to.
  String get bitChannel;

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
      _BitReceiver._toJsonBuilder(this)(ignoreLogLevel);

  @override
  get qualifier => "New OnBit $runtimeType";

  static final Map<OnBit, Element> _map = {};
}

// ██████  ███████  ██████ ███████ ██ ██    ██  █████  ██████  ██      ███████     ██████  ██ ████████
// ██   ██ ██      ██      ██      ██ ██    ██ ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██████  █████   ██      █████   ██ ██    ██ ███████ ██████  ██      █████       ██████  ██    ██
// ██   ██ ██      ██      ██      ██  ██  ██  ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██   ██ ███████  ██████ ███████ ██   ████   ██   ██ ██████  ███████ ███████     ██████  ██    ██

/// Abstract base class for bits taht can be received.
abstract base class ReceivableBit with Core {
  ReceivableBit() {
    if (kDebugMode) print(_toJson());
  }

  @override
  Map<String, dynamic> _toJson([bool ignoreLogLevel = false]) => {
        ...super._toJson(ignoreLogLevel),
        if (data.isNotEmpty) "data": data,
      };

  /// The data contained in the bit.
  Map<String, dynamic> get data => {};

  @override
  String get qualifier => "New ReceivableBit $runtimeType";
}

//  ██████  ██████  ██████  ███████
// ██      ██    ██ ██   ██ ██
// ██      ██    ██ ██████  █████
// ██      ██    ██ ██   ██ ██
//  ██████  ██████  ██   ██ ███████

/// Mixin providing core functionality for bits.
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
