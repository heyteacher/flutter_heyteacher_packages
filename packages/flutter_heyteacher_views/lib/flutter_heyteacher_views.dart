/// A collection of reusable Flutter widgets and utility functions,
/// likely intended to streamline UI development within the Flutter application.
///
/// * Dialoges
///   * [showSnackBar] function: displays a SnackBar
///   * [showConfirmCancelDialog] function: displays a
///     standard `AlertDialog` to ask the user for confirmation or cancellation
///     of an action.
///
/// * [ErrorView] widget: displays different error states to the user.
///
/// * [FloatingActionTextIconButtom]: floating action button for performing an
///   action with text and icon.
///
/// * adaptive layouts:
///   * [AdaptiveScaffold] widget: for layout in adaptive way.
///   * [AdaptiveWrap] widget: for layout in adaptive way.
///   * [SliverAdaptiveWrap] widget: for layout in adaptive way.
///   * [AbstractAdaptiveState]: abstract state for adaptive layout.
///   * [AdaptiveState]: state for adaptive layout.
///
/// * animations:
///   * [DismissibleWidget]: widget that can be dismissed by swiping.
///   * [AnimateText]: widget that can animate text.
///   * [BlinkingText]: widget that can blink text.
///   * [PagingSliverAnimatedState]: state that can animate a page.
///
/// * [FutureStreamBuilder] builder: cleverly combines a [FutureBuilder] with
///   a [StreamBuilder].
///
/// * [ScaffoldNavigationShell]: router shell for displaying the current
///
/// * [GenericsDropDownMenu]: dropdown menu for selecting an item from a list.
///
/// * progress indicatiors:
///   * [ProgressIndicatorView]: widget that displays a progress indicator.
///   * [ProgressIndicatorWidget]: widget that displays a progress indicator.
///
/// * theme utilities:
///   * [ThemeModeButton]: button for selecting the theme mode.
///   * [ThemeModeListTile]: list tile for selecting the theme mode.
///   * [ThemeModeListTileState]: state for the theme mode list tile.
///
/// * [PropertyEditorListTile]: list tile for editing a property value.
///
/// * table
///   * [TableView] widget: for displays a table with [TableCellData].
///
///   * [TutorialViewModel] class: provides access to the current tutorial and
///    tutorial mode.
///
/// * [TooltipIconButton] widget: displays a tooltip when the button is
///   pressed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

export 'src/adaptive_layout/adaptive_layout_data.dart' show ScreenSize;
export 'src/adaptive_layout/adaptive_layout_view.dart'
    show AbstractAdaptiveState, AdaptiveState;
export 'src/adaptive_layout/adaptive_scaffold.dart' show AdaptiveScaffold;
export 'src/adaptive_layout/adaptive_wrap.dart'
    show AdaptiveWrap, SliverAdaptiveWrap;
export 'src/animations.dart'
    show
        AnimateText,
        BlinkingText,
        DeleteCallback,
        DismissibleWidget,
        MessageCallback,
        PagingSliverAnimatedState;
export 'src/color_to_int32_extension.dart' show ColorEx;
export 'src/router.dart' show ScaffoldNavigationShell;
export 'src/theme/theme_view.dart'
    show ThemeModeButton, ThemeModeListTile, ThemeModeListTileState;
export 'src/theme/theme_view_model.dart' show ThemeViewModel;
export 'src/tutorial.dart' show TutorialContentAlignment, TutorialViewModel;
export 'src/view/dialogs.dart' show showConfirmCancelDialog, showSnackBar;
export 'src/view/error_view.dart' show ErrorView;
export 'src/view/floating_action_text_icon_buttom.dart'
    show FloatingActionTextIconButtom;
export 'src/view/future_stream_builder.dart' show FutureStreamBuilder;
export 'src/view/generics_drop_down_menu.dart' show GenericsDropDownMenu;
export 'src/view/progress_indicator.dart'
    show ProgressIndicatorView, ProgressIndicatorWidget;
export 'src/view/property_editor_list_tile.dart' show PropertyEditorListTile;
export 'src/view/table.dart' show TableCellData, TableView;
export 'src/view/tooltip_icon_button.dart' show TooltipIconButton;
