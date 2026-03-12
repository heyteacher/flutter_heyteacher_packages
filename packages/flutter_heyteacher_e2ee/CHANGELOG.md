## [flutter_heyteacher_e2ee-2.0.2+130] - 2026-03-12

### 🐛 Bug Fixes

- If `firebase` is not configured, instantiate a `MockFirebaseAuth`
- Remove `MockFirebaseAuth` initialization

### 💼 Other

- *(deps)* Bump deps to 2.0.2+130
## [flutter_heyteacher_e2ee-2.0.1+128] - 2026-03-10

### 🐛 Bug Fixes

- *(e2ee)* Remove `flutter_heyteacher_firebase` dependency and add `initializeDebug`,  `masterSecretKeyJwk' setter and `MissingMasterSecretKeyJwkException`
- *(e2ee)* Change signature of `setAAD`, if value is null, generate and set it, and replace `initializeDebug` whit `debugSecretKeyJWK` setter and remove unused `_debugPassword`
- *(e2ee)* Made `E2EESecretKeyCard` constructor `const`

### 💼 Other

- *(deps)* Bump deps to 2.0.1+128

### 📚 Documentation

- *(e2ee)* Add `example` app
- *(e2ee)* Add documentation in `README.md`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_e2ee-2.0.1+128
## [flutter_heyteacher_e2ee-2.0.0+126] - 2026-03-06

### 🚀 Features

- *(packages)* [**breaking**] Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_e2ee-2.0.0+126
