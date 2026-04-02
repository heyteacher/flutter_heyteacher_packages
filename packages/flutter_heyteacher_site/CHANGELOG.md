## [flutter_heyteacher_site-1.10.2+124] - 2026-04-02

### 🐛 Bug Fixes

- *(README.md)* Typo causing broken link
- *(README.md)* Typo causing broken link

### 💼 Other

- *(deps)* Bump dependencies
- *(deps)* Bump rependencies version
- *(flutter_heyteacher_site)* Update version to 1.10.2+124 which closes #tmp

### 📚 Documentation

- Add reference to `Model-View-ViewModel` (`MVVM`) architecture and `Singleton` pattern sections
## [flutter_heyteacher_site-1.10.1+122] - 2026-03-30

### 💼 Other

- Update version to 1.10.1+122 which closes #66

### 🚜 Refactor

- Merge remote-tracking branch 'temp_site/main' into 66
- Use `markdown_widget_flutter_heyteacher`  and `updown_arrow_scroller_flutter_heyteacher` forks published on `pub.dev`
- Move `flutter_heyteacher_site` on `flutter_heyteacher_packages` and publish on `pub.dev`
- Add `flutter_localizations` and `intl` in order to publish on `pub.dev` (validation fails otherwise...)

### 📚 Documentation

- Add BSD 3-Clause License `LICENSE`
- Update changelog generated for flutter_heyteacher_site-1.10.1+122
## [flutter_heyteacher_site-1.10.0+120] - 2026-03-27

### 🚀 Features

- Add `callback` to `CookieConsentBanner` invoked on user choice
- `enable` return `null` is no choice is made

### 🐛 Bug Fixes

- GetItOnGooglePlayButton: move `GetItOnGooglePlay_Badge_Web_color_English.png` into package assets and adapt layout size. LeadingIcon: add`assetIconPath' parameter
- Dispose `AutoScrollController` on `MarkdownView` dispose
- Expose on functionalities from the single dat file `flutter_heyteacher_site.dart`
- Add `GetItOnGooglePlay_Badge_Web_color_English.png` to assets

### 💼 Other

- Update version to 1.10.0+120 which closes #2

### 📚 Documentation

- Add `example` application
- Add `README.md`
- Update changelog generated for flutter_heyteacher_site-1.10.0+120
## [flutter_heyteacher_site-1.9.11+118] - 2026-03-26

### 🐛 Bug Fixes

- Remove version for `flutter_heyteacher_*` dependency
- Now `ThemeViewModel.instance.themeStream` send `ThemeData` and `ThemeMode`

### 💼 Other

- *(deps)* Bump deps to 1.9.11+118

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.11+118
## [flutter_heyteacher_site-1.9.10+116] - 2026-03-24

### 💼 Other

- *(deps)* Bump deps to 1.9.10+116

### 🚜 Refactor

- `flutter_heyteacher_packages` published on `pub.dev`

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.10+116
## [flutter_heyteacher_site-1.9.9+114] - 2026-03-21

### 🐛 Bug Fixes

- Enhance size of `GetItOnGooglePlayButton`

### 💼 Other

- *(deps)* Bump deps to 1.9.9+114

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.9+114
## [flutter_heyteacher_site-1.9.8+112] - 2026-03-21

### 🐛 Bug Fixes

- Manage correctly the `MarkdownConfig` based on theme mode and refresh on theme mode changed

### 💼 Other

- *(deps)* Bump deps to 1.9.8+112

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.8+112
## [flutter_heyteacher_site-1.9.7+110] - 2026-03-16

### 🐛 Bug Fixes

- Add  `crossAxisCount` and `screenSize` params to `bodyForLargeBuilder` and `bodyForSmallBuilder` functions in `AdaptiveScaffold`

### 💼 Other

- *(deps)* Bump deps to 1.9.7+110

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.7+110
## [flutter_heyteacher_site-1.9.6+108] - 2026-03-06

### 💼 Other

- *(site)* Add `.ignore` localizazions dart files
- *(deps)* Bump deps to 1.9.6+108

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.6+108
## [flutter_heyteacher_site-1.9.5+106] - 2026-03-06

### 💼 Other

- *(deps)* Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`
- *(deps)* Bump deps to 1.9.5+106

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.5+106
## [flutter_heyteacher_site-1.9.4+104] - 2026-03-05

### 🚀 Features

- Add logging dependency
- Add `CookieConsentViewModel` witch check if is enabled and logging
- Log event on Google Analytics on press `GetItOnGooglePlayButton`
- Log Google Analytics  custom event `play_video`
- Add `markdownAppendixCallback` to append data to content and fix loading `headerIndexes` used to jump paragraph
- Rename `hero_carousel`  in `slide` and add `SlideSliver` widget

### 🐛 Bug Fixes

- Use always `ThemeViewModel.instance.colorScheme`
- Remove `*.lock` ignored

### 💼 Other

- *(deps)* Bump versions
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump `flutter_heyteacher_utils` to 1.45.4
- *(deps)* Bump deps version to 1.4.2+260209130
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.5.0+260215120
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.6.0+260217110
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.7.0+260217130
- *(deps)* Bump deps version to 1.8.0+260217163
- *(deps)* Bump deps version to 1.9.0+260218160
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.9.1+260225162
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.9.2+260226125
- *(deps)* Update 'flutter_heyteacher_meta` and start `buildNumber` as counter
- *(deps)* Bump deps to 1.9.3+101
- *(deps)* Bump deps to 1.9.4+104

### 🚜 Refactor

- Rename `flutter_heyteacher_fastlane` into `flutter_heyteacher_meta`

### 📚 Documentation

- Update CHANGELOG.md with release 1.4.2+260209130
- Update CHANGELOG.md with release 1.6.0+260217110
- Update CHANGELOG.md with release 1.7.0+260217130
- Update CHANGELOG.md with release 1.8.0+260217163
- Update CHANGELOG.md with release 1.9.0+260218160
- Update CHANGELOG.md with release 1.9.1+260225162
- Update CHANGELOG.md with release v1.9.3+101
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_site-1.9.4+104

### ⚙️ Miscellaneous Tasks

- Use `flutter_heyteacher_meta` from pub cache
- *(site)* Add local dependency to `flutter_heyteacher_utils`
