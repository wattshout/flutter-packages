# CHANGELOG

## 2.0.0

### Major Changes
- **Revamped Bit and Channel Infrastructure**: Complete overhaul of the core `Bit` and `BitChannel` architecture to improve flexibility and performance.
- **Improved Type Safety**: Enhanced type safety across the package to reduce runtime errors and improve developer experience.
- **Asynchronous Handling**: Introduced asynchronous handling for all bit transmissions, ensuring better performance and responsiveness.

### New Features
- **New Bit Classes**: Added `LogBit`, `RequestBit`, `ResponseBit`, `RequestFailed`, and `ResponseOK` classes to cover more use cases out of the box.
- **Mixin for Core Functionality**: Introduced a `Core` mixin to provide shared functionality for bits.
- **Enhanced Logging**: Improved logging capabilities, including debug, info, and trace levels, to aid in development and troubleshooting.
- **Global Data Handling**: Improved mechanism for handling global data that is included with all bits.
- **BitService, BitState, and OnBit Mixins**: Added mixins for services and widgets that receive bits, simplifying the integration with `BitChannel`.

### Breaking Changes
- **Channel Joining**: The method for joining channels has been updated. Ensure that all instances of `BitChannel.join` are updated to the new format.
- **Qualifier Changes**: The `qualifier` property has been standardized across all bit types, potentially affecting any custom implementations relying on previous formats.
- **Data Getter**: Custom `data` getters must now explicitly call `super.data` if they need to include data from the parent class.
- **Abstract Class Updates**: `Bit` and `ReceivableBit` are now abstract base classes, which may affect existing implementations.

### Bug Fixes
- **Handler Call Timing**: Fixed an issue where responses could be triggered before the request was fully processed by ensuring handlers are called within a `Future`.
- **Logging Crash Fix**: Resolved an issue that caused crashes when using `BitReceiver` subclasses with high log levels.
- **Super Data Inclusion**: Ensured that `super.data` is included in all overridden `data` getters in `ResponseBit` and `RequestFailed` classes.

### Miscellaneous
- **Code Clean-up**: Refactored various parts of the code for improved readability and maintainability.
- **Documentation Updates**: Expanded and improved documentation throughout the package to aid developers in understanding and utilizing the new features and changes.

---

## 1.0.3

### Bug Fixes
- **Data Getter Update**: Added call to `super.data` in `data` getters for `ResponseBit` and `RequestFailed`.
- **Handler Call Timing**: Added `Future()` to handler call in `_onBitBuilder` to prevent responses from being triggered before the request itself.
- **Channel Specification Removal**: Removed the need to specify `bitChannel` in `ResponseBit`.

### Miscellaneous
- **Code Refinement**: Some code lifting in `helper_bits.dart`.

---

## 1.0.2

### Bug Fixes
- **Logging Crash Fix**: Fixed an issue that caused the app to crash when using `BitReceiver` subclasses (`BitService`, `BitState`, `OnBit`) and `Bit.logLevel` higher than `LogLevel.info`.

---

## 1.0.1

### Miscellaneous
- **Metadata Update**: Fixed repository URL.

---

## 1.0.0

### Documentation
- **Package Documentation**: Improved overall package documentation (code and metadata).

---

## 0.0.2

### Miscellaneous
- **Metadata Update**: Improved package description, fixed repository URL, and issue tracker URL.
- **README Fix**: Fixed package import in the Getting Started section of the README file.

---

## 0.0.1

### Initial Release
- **Initial Release**: Initial release of the package.
