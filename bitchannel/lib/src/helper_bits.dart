import 'bit.dart';

final class Log extends ReceivableBit {
  @override
  final String qualifier;

  @override
  final Map<String, dynamic> data;

  Log(this.qualifier, {Map<String, dynamic>? data}) : data = data ?? {};
}

final class Dev extends Log {
  Dev(super.qualifier, {super.data});
}

base class RequestBit extends Bit {
  @override
  final String bitChannel;

  RequestBit({required this.bitChannel});
}

base class ResponseBit extends Bit {
  final RequestBit requestBit;

  @override
  final String bitChannel;

  ResponseBit({
    required this.requestBit,
    required this.bitChannel,
  });

  @override
  String get qualifier =>
      "New ResponseBit $runtimeType to RequestBit ${requestBit.runtimeType}";

  @override
  Map<String, dynamic> get data => {
        "request_bit": requestBit,
      };
}

final class RequestFailed extends ResponseBit {
  final dynamic error;
  final StackTrace stackTrace;

  RequestFailed(
    dynamic e,
    StackTrace s, {
    required super.requestBit,
    required super.bitChannel,
  })  : error = e,
        stackTrace = s;

  @override
  get data => {
        "error": error,
        "error_type": error.runtimeType,
        "stack_trace": stackTrace,
      };
}
