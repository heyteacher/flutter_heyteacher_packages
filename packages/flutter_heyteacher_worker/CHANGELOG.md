# Changelog

All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

## [flutter_heyteacher_worker-2.0.8+141] - 2026-04-28

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.8+141]

- Corrected `cliff.toml` ([284d73e](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/284d73e85e51d80e70a89af71d3fbf6c12c99b59))

### 🛠️ Build - [flutter_heyteacher_worker-2.0.8+141]

- Add `fastlane/cliff.toml`  enhanced and customizable for generate change log ([e25bf19](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/e25bf19ac3f5c1513c5575807c51c0a29e3603d3))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.8+141]

- Add link to commit changes in `CHANGELOG.md` ([da93ee5](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/da93ee58101ac0fa3c07a7a9587a271d95e9b0aa))
- *(cliff)* Skip `build(deps)` commits in `CHANGELOG.md` ([61a7b40](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/61a7b4010ca79b155d173f9fb76b22ab0ee25f44))
- *(cliff)* Skip `build(deps)` commits in `CHANGELOG.md` ([cac40bb](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/cac40bbca52c8c2c4cec0a3373acf04eae77a41b))

### ⚙️ Miscellaneous Tasks - [flutter_heyteacher_worker-2.0.8+141]

- *(release)* New version 2.0.8+141 which closes ([#158](https://codeberg.org/heyteacher/flutter_heyteacher_packages/issues/158)) ([e707cb6](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/e707cb696a339e8ab5adcd4f1e426e4f763dd5cd))

## [flutter_heyteacher_worker-2.0.7+140] - 2026-04-14

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.7+140]

- Pubspec metadata corrected ([9d12311](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/9d123112056192eda6e6437517ec735a29ef7564))
- Remove version from `flutter_heyteacher_*` dependency packages inside `monorepo` ([f3ec1e3](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/f3ec1e350160b31e382ca9419332e1ab6b1fe61e))
- Compatible with dependency constraint lower bounds ([722abd8](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/722abd838293cbc3df225e1d6b4f6c4ddbe4ea84))
- Remove `debugPrint`  when  execute in main thread, not in Isolate ([ab5169f](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/ab5169fd95b2d9f2c71d26d1deeffd429855edf6))

### 🛠️ Build - [flutter_heyteacher_worker-2.0.7+140]

- *(flutter_heyteacher_worker)* Update version to 2.0.7+140 which closes ([#99](https://codeberg.org/heyteacher/flutter_heyteacher_packages/issues/99)) ([1f000b8](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/1f000b833b6e808970665b8d4405e2e7fb4bb638))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.7+140]

- *(flutter_heyteacher_worker)* Update `CHANGELOG.md` with flutter_heyteacher_worker-2.0.7+140 ([acbd097](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/acbd097f5a0e64d7ae1fa50496c9f0263b26c5c0))

## [flutter_heyteacher_worker-2.0.6+138] - 2026-03-24

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.6+138]

- Corrected logging message ([a0b4536](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/a0b45367d565b4372480bbc74e860bc053cf488b))

### 🚜 Refactor - [flutter_heyteacher_worker-2.0.6+138]

- `lib/flutter_heyteacher_*.dart` must match the name of package ([a9e3636](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/a9e36362446a2112603802a996bfb0e126919b36))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.6+138]

- Add metadata `repository`, `licence`, `issue_tracker', `homepage`, `documentation` and `topics` ([ddfa4a1](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/ddfa4a1b115e63fa8d1152ee55725e49b724c93e))
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.6+138 ([dbb3381](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/dbb3381d4630392e75b4c615cf871219315cb4ee))

## [flutter_heyteacher_worker-2.0.5+136] - 2026-03-13

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.5+136]

- Remove export of `WorkerIsolate` and renamed in `_WorkerIsolate` ([ebe5571](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/ebe557104aa90f5f53098662b17478a3d80841e4))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.5+136]

- Add documentation in `README.md` ([44fd2c0](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/44fd2c02a6806b8f2e4758682a773939e2d2e057))
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.5+136 ([850047d](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/850047df2112305e7004b8dc7a71ab29e3668963))

## [flutter_heyteacher_worker-2.0.4+134] - 2026-03-12

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.4+134]

- Replace `logger.finest` with `depubPrint` if web  or flutter test ([550bb5c](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/550bb5c65c0976fa0cbce548f90bff53b323e7f2))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.4+134]

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.4+134 ([fe9ae99](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/fe9ae996f64ffb9d9b518226e8941fac9ad8b72e))

## [flutter_heyteacher_worker-2.0.3+132] - 2026-03-09

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.3+132]

- *(worker)* In `initialize` end `execute` run in isolate if not web and not unit test ([a47502e](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/a47502e4f28f6a98fcf0a2c7b48d14fb86ba0c92))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.3+132]

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.3+132 ([2f715be](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/2f715bee43a06a52f43e51f2a3353195a3dd7f3d))

## [flutter_heyteacher_worker-2.0.2+130] - 2026-03-09

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.2+130]

- *(worker)* In `initialize` if plaftorm is `FLUTTER_TEST` don't spawn  new isolate ([728f085](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/728f085a56a23bfe33e08ab9bc52aae482ec5b35))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.2+130]

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.2+130 ([6e9a3b2](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/6e9a3b2e4e0e968a79dd102f3ece267fedaf360d))

## [flutter_heyteacher_worker-2.0.1+128] - 2026-03-08

### 🐛 Bug Fixes - [flutter_heyteacher_worker-2.0.1+128]

- *(worker)* Remove `flutter_heyteacher_firebase` and `flutter_heyteacher_platform` dependencies and remove unused `execWorkerInIsolate` parameters ([44860eb](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/44860eb3b6240c314e2b2b4bac143a751fdcc60a))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.1+128]

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.1+128 ([5d029dc](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/5d029dcc08d2b8c081d19377d0b689509ca8a09f))

## [flutter_heyteacher_worker-2.0.0+126] - 2026-03-06

### 🚀 Features - [flutter_heyteacher_worker-2.0.0+126]

- *(packages)* [**breaking**] Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker` ([4bd4514](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/4bd4514f7c15aeeac3e41e44967aaf989065483e))

### 📚 Documentation - [flutter_heyteacher_worker-2.0.0+126]

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_worker-2.0.0+126 ([6467ba1](https://codeberg.org/heyteacher/flutter_heyteacher_packages/commit/6467ba17e53419efe2f3f642e1a41935a9093192))
