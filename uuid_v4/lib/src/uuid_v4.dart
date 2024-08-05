import 'dart:math';

/// A class representing a UUID of version 4.
///
/// [UUIDv4] is a 128-bit identifier used to uniquely identify information in
/// computer systems. It is randomly generated.
final class UUIDv4 {
  final String _value;

  /// Constructs a [UUIDv4] instance by parsing the given [value].
  ///
  /// Throws an [AssertionError] if the given [value] is not a valid [UUIDv4]
  /// string.
  UUIDv4.parse(String value)
      : assert(
          value.trim().isNotEmpty,
          'The UUID string cannot be empty.',
        ),
        assert(
          RegExp(r"^[0-9a-f]{8}\b(-[0-9a-f]{4}\b){3}-[0-9a-f]{12}$")
              .hasMatch(value),
          'Invalid UUID v4 format.',
        ),
        _value = value;

  /// Constructs a new randomly generated [UUIDv4] instance.
  UUIDv4() : _value = _generate();

  /// Constructs an empty [UUIDv4] instance with all zeros.
  const UUIDv4.empty() : _value = "00000000-0000-0000-0000-000000000000";

  /// Returns the string representation of this [UUIDv4].
  @override
  String toString() => _value;

  /// Checks if this [UUIDv4] is equal to another [UUIDv4].
  ///
  /// Returns `true` if the given [other] object is also a [UUIDv4] and has the
  /// same value as this [UUIDv4].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UUIDv4) return false;
    return _value == other._value;
  }

  /// Returns the hash code of this [UUIDv4].
  @override
  int get hashCode => _value.hashCode;

  /// Generates a new random [UUIDv4] string.
  static String _generate() {
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set the version (4) and the variant (10xxxxxx)
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10xxxxxx

    final List<String> characters =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).toList();

    String uuid = characters.sublist(0, 4).join();
    uuid += "-${characters.sublist(4, 6).join()}";
    uuid += "-${characters.sublist(6, 8).join()}";
    uuid += "-${characters.sublist(8, 10).join()}";
    uuid += "-${characters.sublist(10).join()}";
    return uuid;
  }

  /// Tries to parse the given [value] as a [UUIDv4] instance.
  ///
  /// Returns a [UUIDv4] instance if the [value] is valid, otherwise returns
  /// `null`.
  static UUIDv4? tryParse(String value) {
    if (!RegExp(r"^[0-9a-f]{8}\b(-[0-9a-f]{4}\b){3}-[0-9a-f]{12}$")
        .hasMatch(value)) {
      return null;
    }
    return UUIDv4.parse(value);
  }
}
