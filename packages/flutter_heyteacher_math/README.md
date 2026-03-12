# flutter_heyteacher_math

A Flutter package containing mathematical utilities and algorithms, designed for the [Flutter HeyTeacher ecosystem](../../).

## Features

- **Moving Average**: Utilities to calculate Simple, Exponential, and Weighted moving averages for data sets.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_math: ^1.0.0
```

## Usage

### Moving Average

The package provides the `MovingAverage` class to calculate different types of moving averages.

#### Simple Moving Average

```dart
import 'package:flutter_heyteacher_math/math.dart';

final data = [10.0, 12.0, 11.0, 15.0, 14.0, 16.0];
final period = 3;

final result = MovingAverage.simple(data, period);
// result: [10.0, 11.0, 11.0, 12.666..., 13.333..., 15.0]
```

#### Exponential Moving Average

```dart
import 'package:flutter_heyteacher_math/math.dart';

final result = MovingAverage.exponential(data, period);
// result: [10.0, 11.0, 11.0, 13.0, 13.5, 14.75]
```

#### Weighted Moving Average

```dart
import 'package:flutter_heyteacher_math/math.dart';

final result = MovingAverage.weighted(data, period);
// result: [10.0, 11.333..., 11.166..., 13.166..., 13.833..., 15.166...]
```
