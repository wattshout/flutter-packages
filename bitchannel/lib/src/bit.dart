import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid_v4/uuid_v4.dart';

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
  /// Constructs a new Bit and joins the [BitChannel] [bitChannel] to be
  /// broadcasted to its members.
  Bit() {
    BitChannel.join(bitChannel, from: this);
  }

  @override
  String get qualifier => "New Bit $runtimeType";
  @override
  Map<String, dynamic> get data => {"bit_channel": bitChannel};
  @override
  int get hashCode => _id.hashCode;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bit && other._id == _id;
  }

  /// The channel this bit belongs to.
  String get bitChannel;

  /// Log level for bits.
  static LogLevel logLevel = LogLevel.trace;

  /// Global data shared accross all bits.
  static final Map<String, dynamic> globals = {};

  /// Creates a new [LogBit] with the given [qualifier] and optional [data].
  static LogBit log(String qualifier, {Json? data}) =>
      LogBit(qualifier, data: data);
}

// ██████  ██ ████████      ██████ ██   ██  █████  ███    ██ ███    ██ ███████ ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ████   ██ ████   ██ ██      ██
// ██████  ██    ██        ██      ███████ ███████ ██ ██  ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██        ██      ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██
// ██████  ██    ██         ██████ ██   ██ ██   ██ ██   ████ ██   ████ ███████ ███████

/// Represents a communication channel for bits.
final class BitChannel extends ReceivableBit {
  /// Constructs a new [BitChannel] with the give [_name].
  BitChannel._(this._name);

  @override
  String get qualifier => "New BitChannel #$_name";

  /// The name of the channel.
  final String _name;

  /// List of receivers subscribed to this channel.
  final List<_BitReceiver> _list = [];

  /// Joins a channel with the specified [channel] name and [from] source.
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
        Bit.log("${from.runtimeType} has joined #$channel");
    }

    return bitChannel;
  }

  /// Leaves a channel with the specified [channel] name and [from] source.
  static leave(String channel, {required Core from}) {
    final bitChannel = _map[channel]!;
    if (!bitChannel._list.contains(from)) {
      throw Exception("${from.runtimeType} has left #${bitChannel._name}");
    }
    bitChannel._list.remove(from);
    Bit.log("${from.runtimeType} has left #${bitChannel._name}");
  }

  /// Map of channel names to their corresponding [BitChannel] instances.
  static final Map<String, BitChannel> _map = {};
}

// ██████  ██ ████████     ██████  ███████  ██████ ███████ ██ ██    ██ ███████ ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██ ██    ██ ██      ██   ██
// ██████  ██    ██        ██████  █████   ██      █████   ██ ██    ██ █████   ██████
// ██   ██ ██    ██        ██   ██ ██      ██      ██      ██  ██  ██  ██      ██   ██
// ██████  ██    ██        ██   ██ ███████  ██████ ███████ ██   ████   ███████ ██   ██

/// Mixin for services that receive bits.
mixin BitService implements _BitReceiver {
  @override
  String get qualifier => "New BitService '$runtimeType'";
  @override
  late final int _id = Core.nextId;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;
  @override
  Json _toJson([bool ignoreLogLevel = false]) =>
      Core._toJsonBuilder(this)(ignoreLogLevel);
  @override
  _onBit(Bit bit) => _BitReceiver._onBitBuilder(this)(bit);
}

/// Mixin for stateful widgets that receive bits.
mixin BitState<T extends StatefulWidget> on State<T> implements _BitReceiver {
  @override
  String get qualifier => "New BitState<$T> '$runtimeType'";
  @override
  late final int _id = Core.nextId;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;
  @override
  Json _toJson([bool ignoreLogLevel = false]) =>
      Core._toJsonBuilder(this)(ignoreLogLevel);
  @override
  _onBit(Bit bit) => _BitReceiver._onBitBuilder(this)(bit);

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

  /// The channel this widget listens to.
  String get bitChannel;

  /// Rebuilds the widget when a bit of type [B] is received.
  rebuildOn<B>(Bit bit) {
    if (bit is! B) return;
    setState(() {});
  }
}

/// Mixin for stateless widgets that receive bits.
mixin OnBit<B extends Bit> on StatelessWidget implements _BitReceiver {
  @override
  String get qualifier => "New OnBit<$B> '$runtimeType'";
  @override
  late final int _id = Core.nextId;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;
  @override
  Json _toJson([bool ignoreLogLevel = false]) =>
      Core._toJsonBuilder(this)(ignoreLogLevel);
  @override
  Map<Type, Function(Bit bit)> get bitMap => {};
  @override
  _onBit(Bit bit) {
    if (bit is! B || !_map.containsKey(this)) return;
    if (_map[this]!.mounted) return _map[this]!.markNeedsBuild();
    BitChannel.leave(bitChannel, from: this);
    _map.remove(this);
  }

  @override
  StatelessElement createElement() {
    BitChannel.join(bitChannel, from: this);
    return _map[this] = super.createElement();
  }

  /// The channel this widget listens to.
  String get bitChannel;

  /// Map of [OnBit] instances to their corresponding elements.
  static final Map<OnBit, Element> _map = {};
}

/// Mixin for receiving bits.
mixin _BitReceiver implements Core {
  /// Map of bit types to their handlers.
  Map<Type, Function(Bit bit)> get bitMap;

  /// Handles received bits.
  _onBit(Bit bit);

  /// Builder function for handling received bits.
  static _onBitBuilder(_BitReceiver r) => (Bit bit) {
        if (!r.bitMap.containsKey(bit.runtimeType)) {
          return;
        }
        Future(() => r.bitMap[bit.runtimeType]!(bit));
      };
}

// ██████  ███████  ██████ ███████ ██ ██    ██  █████  ██████  ██      ███████     ██████  ██ ████████
// ██   ██ ██      ██      ██      ██ ██    ██ ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██████  █████   ██      █████   ██ ██    ██ ███████ ██████  ██      █████       ██████  ██    ██
// ██   ██ ██      ██      ██      ██  ██  ██  ██   ██ ██   ██ ██      ██          ██   ██ ██    ██
// ██   ██ ███████  ██████ ███████ ██   ████   ██   ██ ██████  ███████ ███████     ██████  ██    ██

/// Abstract base class for bits taht can be received.
abstract base class ReceivableBit with Core {
  /// Constructs a new [ReceivableBit] and prints its [Json] representation if
  /// in debug mode.
  ReceivableBit() {
    if (kDebugMode) print(_toJson());
  }

  @override
  String get qualifier => "New ReceivableBit '$runtimeType'";
  @override
  final int _id = Core.nextId;
  @override
  final DateTime _timestamp = DateTime.timestamp();
  @override
  final StackTrace _stackTrace = StackTrace.current;
  @override
  Json _toJson([bool ignoreLogLevel = false]) =>
      Core._toJsonBuilder(this)(ignoreLogLevel);

  /// The data contained in the bit.
  Map<String, dynamic> get data => {};
}

//  ██████  ██████  ██████  ███████
// ██      ██    ██ ██   ██ ██
// ██      ██    ██ ██████  █████
// ██      ██    ██ ██   ██ ██
//  ██████  ██████  ██   ██ ███████

/// [Core] mixin allows both [Bit] and [_BitReceiver] to join a [BitChannel].
mixin Core {
  /// A unique identifier for the core object.
  String get qualifier;

  /// The unique ID of the core object.
  int get _id;

  /// The timestamp when the core object was created.
  DateTime get _timestamp;

  /// The stack trace when the core object was created.
  StackTrace get _stackTrace;

  /// Converts the core object to a [Json] representation.
  Json _toJson();

  /// Builder function for converting a [Core] object to [Json].
  static Json Function([bool]) _toJsonBuilder(Core core) {
    return ([bool ignoreLogLevel = false]) => {
          "qualifier": core.qualifier,
          if (core is ReceivableBit && core.data.isNotEmpty) "data": core.data,
          // LogLevel.info
          if (ignoreLogLevel ||
              !Enum.compareByIndex(Bit.logLevel, LogLevel.info).isNegative) ...{
            "runtime_type": core.runtimeType,
            if (Bit.globals.isNotEmpty) "globals": Bit.globals,
          },
          // LogLevel.debug
          if (ignoreLogLevel ||
              !Enum.compareByIndex(Bit.logLevel, LogLevel.debug)
                  .isNegative) ...{
            "session_id": _sessionId,
            "id": core._id,
            "timestamp": core._timestamp,
          },
          // LogLevel.trace
          if (ignoreLogLevel ||
              !Enum.compareByIndex(Bit.logLevel, LogLevel.trace)
                  .isNegative) ...{
            "stack_trace": core._stackTrace,
          },
        };
  }

  /// [_idCounter] is the global counter to identify anything.
  static int _idCounter = 0;

  /// Returns the next unique ID.
  static int get nextId => _idCounter++;

  /// [_sessionId] is the session id.
  static final UUIDv4 _sessionId = UUIDv4();
}

/// Alias for JSON maps.
typedef Json = Map<String, dynamic>;
