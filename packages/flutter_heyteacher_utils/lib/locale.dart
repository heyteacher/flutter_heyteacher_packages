/// Manages application-wide localization settings, including locale selection UI,
/// locale persistence, and dynamic locale updates.
///
/// This library provides:
/// - [LocaleListTile]: A widget for users to select their preferred language
///   from the list of supported locales.
/// - [LocaleModel]: A singleton class responsible for holding the current locale state,
///   persisting user preferences, and broadcasting locale changes.
/// - [FlutterHeyteacherUtilsLocalizations] 
library;

export 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart'
    show FlutterHeyteacherUtilsLocalizations;

export 'package:flutter_heyteacher_utils/src/locale.dart'
    show LocaleViewModel, LocaleCard, LocaleCardState;
