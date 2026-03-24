## [flutter_heyteacher_views-2.1.2+140] - 2026-03-24

### 🚀 Features

- Add examples to dart workspace and add metadata `repository`, `licence`, `issue_tracker', `homepage`, `documentation` and `topics`

### 💼 Other

- *(deps)* Bump deps to 2.1.2+140

### 🚜 Refactor

- `lib/flutter_heyteacher_*.dart` must match the name of package

### 📚 Documentation

- Add metadata `repository`, `licence`, `issue_tracker', `homepage`, `documentation` and `topics`
## [flutter_heyteacher_views-2.1.1+138] - 2026-03-21

### 🐛 Bug Fixes

- Pass `AppBar` and `persistentFooter` parameters to `AdaptiveScaffold`

### 💼 Other

- *(deps)* Bump deps to 2.1.1+138

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.1.1+138
## [flutter_heyteacher_views-2.1.0+136] - 2026-03-21

### 🚀 Features

- Add `ThemeModeButton` and rename `ThemeCard` in `ThemeModeCard`

### 💼 Other

- *(deps)* Bump deps to 2.1.0+136

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.1.0+136
## [flutter_heyteacher_views-2.0.4+134] - 2026-03-19

### 💼 Other

- *(deps)* Upgrade major versions
- *(deps)* Upgrade major versions
- *(deps)* Bump deps to 2.0.4+134

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.4+134

### 🎨 Styling

- Enhange light theme managing colors based on mode
## [flutter_heyteacher_views-2.0.3+132] - 2026-03-16

### 🐛 Bug Fixes

- Move `AuthRouterName` and `GoAuthRoute` to `flutter_heyteacher_auth` from `flutter_heyteacher_views` and remove unused dependencies in `flutter_heyteacher_views`
- `ScaffoldNavigationShell` become concrete adding implementation `onTapInitialLocation` to false
- Add  `crossAxisCount` and `screenSize` params to `bodyForLargeBuilder` and `bodyForSmallBuilder` functions in `AdaptiveScaffold`
- Corrected signature of `bodyForLargeBuilder`  and `bodyForSmallBuilder`
- Use the parent size to calculate the width and height
- On scroll down wait a little bit in order to rebuild UI and avoid extends limit twice and load unnecessary data
- Remove `BlinkingTextState` from export and become private (`_BlinkingTextState`)
- Add `title` parameter to `ErrorView`
- Add `forceRestart` parameter to `TutorialViewModel.start`
- Remove `TutorialItemContent` export and become private renaming in `_TutorialItemContent'
- `ThemeData` configuration  enhanced
- Remove `dividerColor` in `TabBarThemeData`
- Set text color to `white` in order to by visibile in dark and light theme
- Lighing `disabled` color on default light theme
- Move `PagingSliverAnimatedState` and `AnimationScreen` into the separated folder `animations`

### 💼 Other

- *(deps)* Bump deps to 2.0.3+132

### 📚 Documentation

- Add `example` app
- Add documentation to `README.md`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.3+132
## [flutter_heyteacher_views-2.0.2+130] - 2026-03-11

### 🐛 Bug Fixes

- *(views)* Remove `FHURemoteConfigKeys` and `FlutterHeyteacherUtilsSharedPreferencesKeys` import

### 💼 Other

- *(deps)* Bump deps to 2.0.2+130

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.1+128
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.2+130
## [flutter_heyteacher_views-2.0.1+128] - 2026-03-06

### 🐛 Bug Fixes

- *(views)* Move generic localized strings to `flutter_heyteacher_locale`

### 💼 Other

- *(deps)* Bump deps to 2.0.1+128

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.1+128
## [flutter_heyteacher_views-2.0.0+126] - 2026-03-06

### 🚀 Features

- *(packages)* [**breaking**] Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_views-2.0.0+126
