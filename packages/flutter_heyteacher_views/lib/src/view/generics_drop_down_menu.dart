import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// a Generics implementation of [DropdownMenu].
class GenericsDropDownMenu<T> extends StatefulWidget {
  /// Creates a generic dropdown menu.
  const GenericsDropDownMenu({
    required String label,
    required void Function(T?, {int? index}) onSelected,
    required List<({Icon? icon, String label, T value})> values,
    super.key,
    List<String> deniedValues = const [],
    T? initialSelection,
    bool enableFilter = true,
    bool enableSearch = false,
    void Function(String, {int? index})? addCallback,
    int? index,
    bool isDense = false,
    double height = 40,
    double? width,
    double menuHeight = 300,
    IconData trailingIcon = Icons.filter_list,
  }) : _onSelected = onSelected,
       _values = values,
       _initialSelection = initialSelection,
       _enableFilter = enableFilter,
       _enableSearch = enableSearch,
       _addCallback = addCallback,
       _index = index,
       _isDense = isDense,
       _height = height,
       _width = width,
       _menuHeight = menuHeight,
       _deniedValues = deniedValues,
       _trailingIcon = trailingIcon,
       _label = label;
  final String _label;

  /// The callback that is called when a new item is selected.
  final void Function(T?, {int? index}) _onSelected;

  /// The list of items to display in the dropdown menu.
  final List<({String label, T value, Icon? icon})> _values;

  /// The initially selected value.
  final T? _initialSelection;

  /// Whether to enable filtering of the dropdown menu entries.
  final bool _enableFilter;

  /// Whether to enable searching of the dropdown menu entries.
  final bool _enableSearch;

  /// A callback to add a new item to the dropdown menu.
  final void Function(String, {int? index})? _addCallback;

  /// An optional index to pass to the [_onSelected] and [_addCallback]
  /// callbacks.
  final int? _index;

  /// Whether the dropdown menu is dense.
  final bool _isDense;

  /// The height of the dropdown menu.
  final double _height;

  /// The width of the dropdown menu.
  final double? _width;

  /// The height of the dropdown menu's list of entries.
  final double _menuHeight;

  /// A list of values that are not allowed to be added.
  final List<String> _deniedValues;

  /// The icon to display on the right side of the dropdown menu.
  final IconData _trailingIcon;

  @override
  State<GenericsDropDownMenu<T>> createState() =>
      _GenericsDropDownMenuState<T>();
}

class _GenericsDropDownMenuState<T> extends State<GenericsDropDownMenu<T>> {
  bool _enableAddTag = false;
  String? _filter;
  String? _querySearch;
  final FocusNode _focusNode = FocusNode();
  List<DropdownMenuEntry<T?>>? _lastFilteredEntries;

  ({String? label, T? value, Icon? icon})? _value;

  @override
  void initState() {
    super.initState();
    _value = widget._values.firstWhereOrNull(
      (record) => record.value == widget._initialSelection,
    );
  }

  @override
  Widget build(BuildContext context) => DropdownMenu<T?>(
    focusNode: _focusNode,
    label: Text(widget._label, style: const TextStyle(fontSize: 11)),
    initialSelection: widget._initialSelection,
    onSelected: _preOnSelected,
    enableSearch: widget._enableSearch,
    searchCallback: widget._enableSearch ? _searchCallback : null,
    requestFocusOnTap: widget._enableFilter || widget._enableSearch,
    enableFilter: widget._enableFilter,
    filterCallback: widget._enableFilter ? _filterCallback : null,
    leadingIcon: widget._addCallback != null && _enableAddTag
        ? IconButton(onPressed: _preAddCallback, icon: const Icon(Icons.add))
        : null,
    trailingIcon: Icon(widget._trailingIcon, applyTextScaling: true),
    textStyle: Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: _value?.icon?.color),
    width: widget._width,
    menuHeight: widget._menuHeight,
    dropdownMenuEntries: [
      DropdownMenuEntry<T?>(value: null, label: ''),
      ...widget._values.map(
        (record) => DropdownMenuEntry<T?>(
          label: record.label,
          value: record.value,
          leadingIcon: record.icon,
        ),
      ),
    ],
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.only(left: 2),
      isDense: widget._isDense,
      isCollapsed: widget._isDense,
      constraints: BoxConstraints.tight(Size.fromHeight(widget._height)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Future<void> _preAddCallback() async {
    if (_filter != null || _querySearch != null) {
      final newValue = _filter ?? _querySearch;
      if (widget._deniedValues.contains(newValue)) {
        showSnackBar(
          context: context,
          message: 'cannot add denied value $newValue ',
          error: true,
        );
      } else {
        widget._addCallback?.call(newValue!, index: widget._index);
      }
      _focusNode.unfocus();
      setState(() {
        _enableAddTag = false;
      });
    }
  }

  void _preOnSelected(T? value) {
    _value = widget._values.firstWhereOrNull((record) => record.value == value);
    widget._onSelected(value, index: widget._index);
    _focusNode.unfocus();
  }

  List<DropdownMenuEntry<T?>> _filterCallback(
    List<DropdownMenuEntry<T?>> entries,
    String filter,
  ) {
    _filter = filter;
    final filteredEntries = [
      DropdownMenuEntry<T?>(value: null, label: ''),
      ...entries.where(
        (entry) =>
            entry.value != null &&
            entry.value!.toString().toLowerCase().contains(
              _filter!.toLowerCase(),
            ),
      ),
    ];
    if ((_filter?.isNotEmpty ?? false) &&
        _lastFilteredEntries?.length != filteredEntries.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _enableAddTag =
              (_filter?.isNotEmpty ?? false) && filteredEntries.length == 1;
        }),
      );
    }
    _lastFilteredEntries = filteredEntries;
    return filteredEntries;
  }

  int? _searchCallback(List<DropdownMenuEntry<T?>> entries, String query) {
    _querySearch = query;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry.value != null &&
          (_querySearch?.isNotEmpty ?? false) &&
          entry.value!.toString().toLowerCase().contains(
            _querySearch!.toLowerCase(),
          )) {
        if (mounted) {
          _enableAddTag = false;
        }
        return i;
      }
    }
    if (_querySearch?.isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _enableAddTag = true;
        }),
      );
    }
    return null;
  }
}
