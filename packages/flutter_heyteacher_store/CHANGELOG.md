## [flutter_heyteacher_store-2.0.0+1030] - 2026-03-30

### 🐛 Bug Fixes

- [**breaking**] Add `AggregationType` (`sum` or `average`)  to `aggregateFields` items

### 💼 Other

- Update version to 1.29.20+1028 which closes #4
- Update version to 2.0.0+1030 which closes #4

### 📚 Documentation

- Update changelog generated for flutter_heyteacher_store-1.29.20+1028
## [flutter_heyteacher_store-1.29.19+1026] - 2026-03-30

### 💼 Other

- *(deps)* Tight dependencies versions
- Update version to 1.29.19+1026 which closes #2

### 📚 Documentation

- *(store)* Add `example` app
- Change link of example to `example` app directory
- Update changelog generated for flutter_heyteacher_store-1.29.19+1026
## [flutter_heyteacher_store-1.29.18+1024] - 2026-03-26

### 🐛 Bug Fixes

- Remove version for `flutter_heyteacher_*` dependency

### 💼 Other

- *(deps)* Bump deps to 1.29.18+1024

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.18+1024
## [flutter_heyteacher_store-1.29.17+1022] - 2026-03-25

### 💼 Other

- *(deps)* Upgrade `fake_cloud_firestore` with fix of incompatibility with `cloud_firestore 6.2.0`
- *(deps)* Bump deps to 1.29.17+1022

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.17+1022
## [flutter_heyteacher_store-1.29.16+1020] - 2026-03-24

### 🐛 Bug Fixes

- Update `fake_cloud_firestore` to git repo in order to get latest fixes
- Use a branch where is fixes the incompatibility with `cloud_firestore-6-2-0`

### 💼 Other

- *(deps)* Upgrade major versions
- *(deps)* Bump deps to 1.29.15+1018
- *(deps)* Bump deps to 1.29.16+1020

### 🚜 Refactor

- `flutter_heyteacher_*` published on `pub.dev`

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.16+1020
## [flutter_heyteacher_store-1.29.14+1016] - 2026-03-12

### 🐛 Bug Fixes

- Remove `firebase_auth_mocks` dependency

### 💼 Other

- *(deps)* Bump deps to 1.29.14+1016

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.14+1016
## [flutter_heyteacher_store-1.29.13+1014] - 2026-03-12

### 🐛 Bug Fixes

- `MockFirebaseAuth` is instantiante inside `flutter_heyteacher_auth` if `FirebaseException` is  raised

### 💼 Other

- *(deps)* Bump deps to 1.29.12+1012
- *(deps)* Bump deps to 1.29.13+1014

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.13+1014

### 🧪 Testing

- *(store)* Changed signature of `E2EEViewModel.setAAD`
## [flutter_heyteacher_store-1.29.11+1010] - 2026-03-06

### 💼 Other

- *(deps)* Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`
- *(deps)* Bump deps to 1.29.11+1010

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.11+1010
## [flutter_heyteacher_store-1.29.10+1008] - 2026-03-05

### 🚀 Features

- Add caching mechanism for detailed data in Store class
- Implement caching in exists method and optimize cache update in batch operation
- Implement caching mechanism using shared_preferences in Store class
- Add cache reset functionality in Store class
- Implement StoreCache with syncronized package
- Add filter by document id via constant `Filter.documentId`

### 🐛 Bug Fixes

- Update flutter_heyteacher_utils dependency from path to git reference
- Remove duplicate clock package from dev_dependencies
- Improve cache retrieval logic in Store class
- Enhance cache logging with runtime type and hash code
- Enhance logging to include runtime type in Store class
- Add synchronized package to dependencies
- Enhance logging in StoreCache to include runtime type in log messages
- Update synchronized calls in StoreCache methods to support async operations
- Update StoreCache methods to use Lock for synchronized operations
- Simplify StoreCache methods by removing unnecessary locking
- Refactor StoreCache to support multiple data types and improve cache management
- Refactor StoreCache to use periodic stream for cache clearing and remove listener
- Update setAAD method call to use named parameter
- Update intl dependency version to ^0.20.2
- Rename initAggregatesStream to _initAggregatesStream and call it during initialization
- Update flutter_heyteacher_utils dependency to use local path
- Correct arrayContains filter assignment in ValueStoreFilter
- Handle FirebaseException for unavailable errors in Store class
- Correct logical filter string representation in toString method
- Apply order by only if `limit` != 1
- `batch` parameter of `delete`, `update` and `set` become `dynamic` to avoid add firestore dependencies
- Remove `webcrypto` from dependencies
- Upgrade `webcrypto` to git reps to fix 16 KB issue on release app in production
- `storeFilter` logging in`Store.listDetails`
- Remove `*.lock` ignored
- Remove skip on order by if `limit` is 1
- Corrected `groupBy` entries ordering by key and corrected `Direction`
- Re-apply filters in unit tests accidentally removed during refactor

### 💼 Other

- Bump flutter_heyteacher_utils version to  1.45.0+260206123
- *(deps)* Bump versions
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.28.0+260214153
- *(deps)* Bump deps version to 1.29.0+260215114
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.1+260220154
- *(deps)* Bump deps version to 1.29.2+260221102
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.3+260225090
- *(deps)* Bump deps version to 1.29.4+260225162
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.5+260226125
- *(deps)* Bump deps version to 1.29.6+260226194
- *(deps)* Update 'flutter_heyteacher_meta` and start `buildNumber` as counter
- *(deps)* Bump deps to 1.29.7+1001
- *(deps)* Bump deps to 1.29.8+1003
- *(deps)* Bump deps to 1.29.9+1005
- *(deps)* Bump deps to 1.29.10+1008

### 🚜 Refactor

- Rename Auth to AuthModel + create RemoteConfigMode +  update references across the codebase
- Update stream return type to Iterable<LightDataType> for improved data handling
- Change log level from fine to finest for detailed logging in Store class
- Improve logging messages in cache retrieval and data fetching methods
- Enhance exists method to handle document retrieval exceptions
- Change detailsData type to dynamic in detailed data cache
- Format code for better readability in _getCached and _updateCache methods
- Streamline cache key generation in _getCached, _updateCache, and _removeCache methods
- Improve cache management and logging in Store class
- Remove UserStore implementation and related tests
- Update cache handling to use private fields for cache and offline settings
- Streamline aggregate initialization and update notification logic
- Simplify StoreCache class by removing unused LightDataType and renaming methods for clarity
- Rename logger variable for consistency in StoreCache class and add $runtimeType. in each log in order to indentify store name
- Rename *ModelView to *ViewModel
- Standardize string quotes and simplify method implementations in store filters
- Rename `flutter_heyteacher_fastlane` into `flutter_heyteacher_meta`

### 📚 Documentation

- Update documentation to include cache functionality in Store class
- Update CHANGELOG.md with release 1.28.0+260214153
- Update CHANGELOG.md with release 1.29.1+260220154
- Update CHANGELOG.md with release 1.29.2+260221102
- Update CHANGELOG.md with release 1.29.3+260225090
- Update CHANGELOG.md with release 1.29.4+260225162
- Update CHANGELOG.md with release 1.29.6+260226194
- Update CHANGELOG.md with release v1.29.7+1001
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.8+1003
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.8+1004
- Add `README.md` and update dart doc in `Store`, move in separated dart file `TrackStore` in unit tests
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.9+1005
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.10+1008

### 🧪 Testing

- Initialize SharedPreferences in tests and disable cache in TrackStore

### ⚙️ Miscellaneous Tasks

- Add shared_preferences_platform_interface to dev_dependencies
- Update gem dependencies to latest versions
- Update version and add package_info_plus dependency
- Update aws-sdk and faraday dependencies to latest versions
- Use `flutter_heyteacher_meta` from pub cache
- *(store)* Add local dependency to `flutter_heyteacher_text_to_speech`
