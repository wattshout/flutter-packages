# uuid_v4
A Dart package for generating and parsing UUID version 4 (RFC4122) strings. UUIDv4 is a 128-bit identifier used to uniquely identify information in computer systems, generated randomly to ensure uniqueness.

## Features
- Generate random UUIDv4 strings
- Parse and validate UUIDv4 strings
- Support for empty UUIDv4 with all zeros

## Installation
Run the following command:
```bash
flutter pub add uuid_v4
```

## Usage
Import the package:
```dart
import 'package:uuid_v4/uuid_v4.dart';
```

Interface your entity ID instead of importing this package everywhere:
```dart
typedef EntityId = UUIDv4;
final entityId = EntityId(); // Generates a new UUIDv4
```

Generate a new UUIDv4:
```dart
final entityId = UUIDv4();
print(entityId);
```

Parse a UUIDv4 string:
```dart
UUIDv4? uuid = UUIDv4.tryParse('123e4567-e89b-12d3-a456-426614174000');
  if (uuid != null) {
    print(uuid); // Outputs the parsed UUIDv4
  } else {
    print('Invalid UUIDv4 string');
  }
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request on GitHub.