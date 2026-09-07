import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_views/src/view/generics_drop_down_menu.dart';

/// A dropdown list tile that provides a dropdown menu to set a [T] property.
class PropertyEditorListTile<T> extends StatefulWidget {
  /// Creates a [PropertyEditorListTile].
  ///
  /// [label] is the label of the property.
  /// [values] is the list of values to choose from.
  /// [labels] is the list of labels to be displayed in the dropdown menu.
  /// [onSelected] is the callback to be called when a value is selected.
  /// [setValue] is the function that returns the value to be set.
  /// [icon] is the icon to be displayed.
  const PropertyEditorListTile({
    required String label,
    required List<T> values,
    required void Function(T?, {int? index}) onSelected,
    List<String>? labels,
    Future<T?> Function()? setValue,
    T? defaultValue,
    Icon? icon,
    super.key,
  }) : _onSelected = onSelected,
       _labels = labels,
       _values = values,
       _label = label,
       _setValue = setValue,
       _icon = icon,
       _defaultValue = defaultValue;

  final String _label;
  final Future<T?> Function()? _setValue;
  final List<T> _values;
  final List<String>? _labels;
  final T? _defaultValue;
  final Icon? _icon;
  final void Function(T?, {int? index}) _onSelected;

  @override
  State<PropertyEditorListTile<T>> createState() =>
      _PropertyEditorListTileState<T>();
}

class _PropertyEditorListTileState<T> extends State<PropertyEditorListTile<T>> {
  T? _value;

  String? _defaultValueLabel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init([_]) async {
    _value = await widget._setValue?.call() ?? widget._defaultValue;
    if (widget._defaultValue != null) {
      final index = widget._values.indexOf(widget._defaultValue as T);
      if (index != -1) {
        _defaultValueLabel =
            widget._labels?.elementAt(index) ?? widget._defaultValue.toString();
      } else {
        throw Exception(
          'Default value ${widget._defaultValue} not found in values '
          '${widget._values}',
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: widget._icon,
    title: Text(widget._label),
    subtitle: Text(
      FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
        widget._defaultValue is bool
            ? FlutterHeyteacherLocaleLocalizations.of(
                context,
              )!.booleanValue(widget._defaultValue!.toString())
            : _defaultValueLabel ?? '',
      ),
    ),
    trailing: widget._values.firstOrNull is bool
        ? Switch(
            value: _value as bool? ?? false,
            onChanged: (value) {
              widget._onSelected(value as T?, index: null);
              _value = value as T?;
              setState(() {});
            },
          )
        : GenericsDropDownMenu<T>(
            width: 120,
            isDense: true,
            onSelected: widget._onSelected,
            values: widget._values
                .mapIndexed(
                  (index, value) => (
                    label: widget._labels?.elementAt(index) ?? value.toString(),
                    value: value,
                    icon: null,
                  ),
                )
                .toList(),
            initialSelection: _value,
          ),
  );
}
