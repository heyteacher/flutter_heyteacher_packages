/// Provides utilities for retrieving device and application package 
/// information,
/// and a widget to display this information along with a support request 
/// option.
///
/// This library includes:
/// - [DevicePackageInfoCard]: A [Card] widget that displays formatted
///   device and package version information, and a button to initiate a 
///   support email.
/// - [InfoDevicePackageViewModel]: A singleton class that fetches detailed 
///   device information (OS, model, browser) and package information 
///   (version, build number).
library;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/info_device_package.dart';
export 'src/info_device_package.dart' show DevicePackageInfoCard, InfoDevicePackageViewModel;
