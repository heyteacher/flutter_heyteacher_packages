## [flutter_heyteacher_worker-2.0.4+134] - 2026-03-12

### 🐛 Bug Fixes

- Replace `logger.finest` with `depubPrint` if web  or flutter test

### 💼 Other

- *(deps)* Bump deps to 2.0.4+134
## [flutter_heyteacher_worker-2.0.3+132] - 2026-03-09

### 🐛 Bug Fixes

- *(worker)* In `initialize` end `execute` run in isolate if not web and not unit test

### 💼 Other

- *(deps)* Bump deps to 2.0.3+132

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.3+132
## [flutter_heyteacher_worker-2.0.2+130] - 2026-03-09

### 🐛 Bug Fixes

- *(worker)* In `initialize` if plaftorm is `FLUTTER_TEST` don't spawn  new isolate

### 💼 Other

- *(deps)* Bump deps to 2.0.2+130

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.2+130
## [flutter_heyteacher_worker-2.0.1+128] - 2026-03-08

### 🐛 Bug Fixes

- *(worker)* Remove `flutter_heyteacher_firebase` and `flutter_heyteacher_platform` dependencies and remove unused `execWorkerInIsolate` parameters

### 💼 Other

- *(deps)* Bump deps to 2.0.1+128

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.1+128
## [flutter_heyteacher_worker-2.0.0+126] - 2026-03-06

### 🚀 Features

- *(packages)* [**breaking**] Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.0+126
