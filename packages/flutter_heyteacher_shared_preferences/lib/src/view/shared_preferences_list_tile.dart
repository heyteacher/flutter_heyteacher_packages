import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_shared_preferences/flutter_heyteacher_shared_preferences.dart'
    show SharedPreferencesViewModel;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// Property editor list tile for bike tracking settings.
class SharedPreferencesListTile<T> extends StatelessWidget {
  /// Creates a new [SharedPreferencesListTile].
  ///
  ///  - [_label]: The label to display for the property.
  ///  - [_sharedPreferencesKey]: The key used to store and retrieve the
  ///    property's value in shared preferences.
  ///  - [_values]: The list of values to choose from.
  ///  - [_labels]: The list of labels corresponding to the [_values].
  ///  - [_icon]: The icon to display for the property.
  ///  - [_width]: The width of the dropdown menu.
  const SharedPreferencesListTile({
    required this._label,
    required this._sharedPreferencesKey,
    required this._values,
    this._labels,
    this._defaultValue,
    this._icon,
    this._width = 120,
    super.key,
  });

  final String _sharedPreferencesKey;
  final List<T> _values;
  final List<String>? _labels;
  final T? _defaultValue;
  final String _label;
  final Icon? _icon;
  final double _width;

  @override
  Widget build(BuildContext context) => PropertyEditorListTile<T>(
    label: _label,
    icon: _icon,
    values: _values,
    labels: _labels,
    defaultValue: _defaultValue,
    width: _width,
    setValue: () async =>
        switch (_values.firstOrNull) {
              String() =>
                await SharedPreferencesViewModel.instance.getString(
                      _sharedPreferencesKey,
                    ) ??
                    _defaultValue,
              int() =>
                await SharedPreferencesViewModel.instance.getInt(
                      _sharedPreferencesKey,
                    ) ??
                    _defaultValue,
              double() =>
                await SharedPreferencesViewModel.instance.getDouble(
                      _sharedPreferencesKey,
                    ) ??
                    _defaultValue,
              bool() =>
                await SharedPreferencesViewModel.instance.getBool(
                      _sharedPreferencesKey,
                    ) ??
                    _defaultValue,
              _ => throw UnsupportedError(
                'Unsupported type ${_values.firstOrNull?.runtimeType}',
              ),
            }
            as T,
    onSelected: (value, {index}) async => await SharedPreferencesViewModel
        .instance
        .setValue(key: _sharedPreferencesKey, value: value),
  );
}
