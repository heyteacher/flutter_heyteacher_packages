import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// An abstract base class for creating views with a table-like layout.
///
/// Provides a set of protected helper methods for creating consistently
/// styled text widgets and dividers, intended for use within a [Table]
/// or similar layout.
abstract class TableView extends StatelessWidget {
  /// Creates a [TableView].
  const TableView({super.key});

  @protected
  /// Creates a styled [Text] widget for labels within the table.
  Widget labelText(
    String text, {
    TextAlign textAlign = TextAlign.right,
    TextStyle? style,
    Widget? tooltip,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Wrap(
      alignment: textAlign == TextAlign.right
          ? WrapAlignment.end
          : WrapAlignment.start,
      children: [
        if (tooltip != null && textAlign == TextAlign.right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: tooltip,
          ),
        Text(text, textAlign: textAlign, style: style),
        if (tooltip != null && textAlign == TextAlign.left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: tooltip,
          ),
      ],
    ),
  );

  @protected
  /// Creates a value [Text] widget with a blue color.
  Widget valueTextBlue(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) => valueText(
    context,
    text,
    color: ThemeViewModel.instance.blueColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with an orange color.
  Widget valueTextOrange(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) => valueText(
    context,
    text,
    color: ThemeViewModel.instance.orangeColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a red color.
  Widget valueTextRed(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) => valueText(
    context,
    text,
    color: ThemeViewModel.instance.redColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a yellow color.
  Widget valueTextYellow(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) => valueText(
    context,
    text,
    color: ThemeViewModel.instance.yellowColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a green color.
  Widget valueTextGreen(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) => valueText(
    context,
    text,
    color: ThemeViewModel.instance.greenColor,
    textAlign: textAlign,
  );

  /// A private helper to create a styled [Text] widget for displaying values.
  @protected
  Widget valueText(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.left,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.only(left: 4, right: 4),
    child: Text(text, textAlign: textAlign, style: _textStyle(context, color)),
  );

  /// Returns a [TextStyle] for value widgets, based on the current theme.
  TextStyle _textStyle(BuildContext context, Color? color) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(color: color);

  @protected
  /// Builds a table row with the given cells.
  TableRow buildTableRow({
    required BuildContext context,
    Iterable<TableCellData> cells = const [
      TableCellData(),
      TableCellData(),
    ],
  }) => TableRow(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: labelText(
              cells.elementAt(0).label,
              tooltip: cells.elementAt(0).tooltip,
            ),
          ),
          if (cells.elementAt(0).iconData != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Icon(
                  cells.elementAt(0).iconData,
                  color: cells.elementAt(0).color,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
      if (cells.elementAt(0).valueWidget != null)
        cells.elementAt(0).valueWidget!
      else
        valueText(
          context,
          cells.elementAt(0).value,
          color: cells.elementAt(0).color,
        ),
      if (cells.length > 1)
        if (cells.elementAt(1).valueWidget != null)
          cells.elementAt(1).valueWidget!
        else
          valueText(
            context,
            cells.elementAt(1).value,
            textAlign: TextAlign.right,
            color: cells.elementAt(1).color,
          ),
      if (cells.length > 1)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cells.elementAt(1).iconData != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Icon(
                    cells.elementAt(1).iconData,
                    color: cells.elementAt(1).color,
                    size: 14,
                  ),
                ),
              ),
            Expanded(
              child: labelText(
                cells.elementAt(1).label,
                textAlign: TextAlign.left,
                tooltip: cells.elementAt(1).tooltip,
              ),
            ),
          ],
        ),
    ],
  );
}

/// A table cell data used to build table rows with [TableView.buildTableRow].
class TableCellData {
  /// Creates a [TableCellData].
  const TableCellData({
    this.label = '',
    this.value = '',
    this.valueWidget,
    this.color,
    this.iconData,
    this.tooltip,
  });

  /// The label for the table cell.
  final String label;

  /// The value for the table cell.
  final String value;

  /// The widget for the table cell.
  final Widget? valueWidget;

  /// The color for the table cell.
  final Color? color;

  /// The icon data for the table cell.
  final IconData? iconData;

  /// The tooltip for the table cell.
  final Widget? tooltip;
}
