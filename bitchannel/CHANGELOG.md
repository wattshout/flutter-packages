# CHANGELOG

## 1.0.3

* Fixed small typo in `CHANGELOG.md`
* Added call to `super.data` in `data` getters for `ResponseBit` and `RequestFailed`
* Added `Future()` to handler call in `_onBitBuilder` to prevent responses to be triggered before the request itself
* Removed need to specify bitChannel in `ResponseBit`
* Some code lifting in `helper_bits.dart`

## 1.0.2

* Fixed an issue that would lead app to crash when using `BitReceiver` sub-classes (`BitService`, `BitState`, `OnBit`) and `Bit.logLevel` higher than `LogLevel.info`

## 1.0.1

* Fixed repository URL

## 1.0.0

* Improved overall package documentation (code and metadata)

## 0.0.2

* Improved package description
* Fixed repository URL
* Fixed issue tracker URL
* Fixed package import in Getting started section from the README file

## 0.0.1

* Initial release