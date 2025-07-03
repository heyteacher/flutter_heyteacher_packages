/// Provides utilities for retrieving device and application package information,
/// and a widget to display this information along with a support request option.
///
/// This library includes:
/// - [DevicePackageInfoCard]: A [Card] widget that displays formatted
///   device and package version information, and a button to initiate a support email.
/// - [InfoDevicePackageModel]: A singleton class that fetches detailed device
///   information (OS, model, browser) and package information (version, build number).
library;
export 'src/info_device_package.dart' show DevicePackageInfoCard, InfoDevicePackageModelView;
