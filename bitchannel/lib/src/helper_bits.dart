import 'bit.dart';

/// Represents a log bit.
final class Log extends ReceivableBit {
  @override
  final String qualifier;

  @override
  final Map<String, dynamic> data;

  Log(this.qualifier, {Map<String, dynamic>? data}) : data = data ?? {};
}

/// Represents a development log bit.
final class Dev extends Log {
  Dev(super.qualifier, {super.data});
}

/// Represents a request bit.
base class RequestBit extends Bit {
  @override
  final String bitChannel;

  RequestBit({required this.bitChannel});

  @override
  String get qualifier => "New request '$runtimeType'";
}

/// Represents a response bit to a request bit.
base class ResponseBit extends Bit {
  final RequestBit requestBit;

  @override
  final String bitChannel;

  ResponseBit({required this.requestBit}) : bitChannel = requestBit.bitChannel;

  @override
  String get qualifier =>
      "New response '$runtimeType' to request '${requestBit.runtimeType}'";

  @override
  Map<String, dynamic> get data => {...super.data, "request_bit": requestBit};
}

/// Represents a request failure bit.
final class RequestFailed extends ResponseBit {
  final dynamic error;
  final StackTrace stackTrace;

  RequestFailed(dynamic e, StackTrace s, {required super.requestBit})
      : error = e,
        stackTrace = s;

  @override
  String get qualifier => "Request '${requestBit.runtimeType}' failed: $error";

  @override
  get data => {
        ...super.data,
        "error": error,
        "error_type": error.runtimeType,
        "stack_trace": stackTrace,
      };
}
