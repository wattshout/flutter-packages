import 'bit.dart';

/// A bit that logs information.
final class LogBit extends ReceivableBit {
  /// Constructs a new [LogBit] with the specified [qualifier] and optional
  /// [data].
  LogBit(this.qualifier, {Json? data}) : data = data ?? {};

  @override
  final String qualifier;

  @override
  final Json data;
}

/// Abstract base class for request bits.
abstract base class RequestBit extends Bit {
  @override
  String get qualifier => "New RequestBit '$runtimeType'";
}

/// Abstract base class for response bits.
abstract base class ResponseBit extends Bit {
  /// Constructs a new [ResponseBit] with the specified [requestBit].
  ResponseBit({required this.requestBit});

  @override
  String get qualifier => "New ResponseBit '$runtimeType'";

  @override
  String get bitChannel => requestBit.bitChannel;

  /// The request bit associated with this response.
  final RequestBit requestBit;
}

/// Represents a request failure bit.
final class RequestFailed extends ResponseBit {
  /// Constructs a new [RequestFailed] with the specified [requestBit], [error],
  /// and [stackTrace].
  RequestFailed({
    required super.requestBit,
    required this.error,
    required this.stackTrace,
  });

  @override
  String get qualifier => "Request '${requestBit.runtimeType}' failed: $error";

  @override
  get data => {
        ...super.data,
        "error": error,
        "error_type": error.runtimeType,
        "stack_trace": stackTrace,
      };

  /// The error that caused the request to fail.
  final dynamic error;

  /// The stack trace of the error.
  final StackTrace stackTrace;
}

/// Represents a successful response without data.
final class ResponseOK extends ResponseBit {
  /// Constructs a new [ResponseOK] with the specified [requestBit].
  ResponseOK({required super.requestBit});

  @override
  String get qualifier => "Response from '${requestBit.runtimeType}' OK";
}

/// Represents a response with a value.
final class ResponseValue<T> extends ResponseBit {
  /// Constructs a new [ResponseValue] with the specified [requestBit] and [value].
  ResponseValue({
    required super.requestBit,
    required this.value,
  });

  @override
  String get qualifier => "Response from '${requestBit.runtimeType}': $value";

  @override
  Map<String, dynamic> get data => {...super.data, "value": value};

  /// The value of the response.
  final T value;

  @override
  String toString() => value.toString();
}
