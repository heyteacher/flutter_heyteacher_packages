## [flutter_heyteacher_store-1.29.13+1014] - 2026-03-12

### 🐛 Bug Fixes

- `MockFirebaseAuth` is instantiante inside `flutter_heyteacher_auth` if `FirebaseException` is  raised

### 💼 Other

- *(deps)* Bump deps to 1.29.12+1012
- *(deps)* Bump deps to 1.29.13+1014

### 🧪 Testing

- *(store)* Changed signature of `E2EEViewModel.setAAD`
## [flutter_heyteacher_store-1.29.11+1010] - 2026-03-06

### 💼 Other

- *(deps)* Split `flutter_heyteacher_utils` in `flutter_heyteacher_auth`, `flutter_heyteacher_connectivity`, `flutter_heyteacher_e2ee`, `flutter_heyteacher_firebase`, `flutter_heyteacher_locale`, `flutter_heyteacher_logger`, `flutter_heyteacher_math`, `flutter_heyteacher_platform`, `flutter_heyteacher_text_to_speech`, `flutter_heyteacher_timer_workflow`, `flutter_heyteacher_views`, `flutter_heyteacher_worker`
- *(deps)* Bump deps to 1.29.11+1010

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.11+1010
## [flutter_heyteacher_store-1.29.10+1008] - 2026-03-05

### 💼 Other

- *(deps)* Bump deps to 1.29.10+1008

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_store-1.29.10+1008

### ⚙️ Miscellaneous Tasks

- *(store)* Add local dependency to `flutter_heyteacher_text_to_speech`
## [1.29.9+1005] - 2026-03-02

### 💼 Other

- *(deps)* Bump deps to 1.29.9+1005

### 📚 Documentation

- Add `README.md` and update dart doc in `Store`, move in separated dart file `TrackStore` in unit tests
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.9+1005
## [1.29.8+1004] - 2026-03-02

### 🐛 Bug Fixes

- Corrected `groupBy` entries ordering by key and corrected `Direction`
- Re-apply filters in unit tests accidentally removed during refactor

### 💼 Other

- *(deps)* Bump deps to 1.29.8+1003

### 📚 Documentation

- Update CHANGELOG.md with release v1.29.7+1001
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.8+1003
- *(CHANGELOG)* Update CHANGELOG.md with release v1.29.8+1004
## [1.29.7+1001] - 2026-02-27

### 💼 Other

- *(deps)* Update 'flutter_heyteacher_meta` and start `buildNumber` as counter
- *(deps)* Bump deps to 1.29.7+1001

### 📚 Documentation

- Update CHANGELOG.md with release 1.29.6+260226194
## [1.29.6+260226194] - 2026-02-26

### 🐛 Bug Fixes

- Remove skip on order by if `limit` is 1

### 💼 Other

- *(deps)* Bump deps version to 1.29.6+260226194
## [1.29.5+260226125] - 2026-02-26

### 🐛 Bug Fixes

- Remove `*.lock` ignored

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.5+260226125

### 📚 Documentation

- Update CHANGELOG.md with release 1.29.4+260225162
## [1.29.4+260225162] - 2026-02-25

### 💼 Other

- *(deps)* Bump deps version to 1.29.4+260225162

### 📚 Documentation

- Update CHANGELOG.md with release 1.29.3+260225090

### ⚙️ Miscellaneous Tasks

- Use `flutter_heyteacher_meta` from pub cache
## [1.29.3+260225090] - 2026-02-25

### 🐛 Bug Fixes

- `storeFilter` logging in`Store.listDetails`

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.3+260225090

### 📚 Documentation

- Update CHANGELOG.md with release 1.29.2+260221102
## [1.29.2+260221102] - 2026-02-21

### 🐛 Bug Fixes

- Remove `webcrypto` from dependencies
- Upgrade `webcrypto` to git reps to fix 16 KB issue on release app in production

### 💼 Other

- *(deps)* Bump deps version to 1.29.2+260221102

### 📚 Documentation

- Update CHANGELOG.md with release 1.29.1+260220154
## [1.29.1+260220154] - 2026-02-20

### 🐛 Bug Fixes

- `batch` parameter of `delete`, `update` and `set` become `dynamic` to avoid add firestore dependencies

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.29.1+260220154
## [1.29.0+260215114] - 2026-02-15

### 💼 Other

- *(deps)* Bump deps version to 1.29.0+260215114

### 🚜 Refactor

- Rename `flutter_heyteacher_fastlane` into `flutter_heyteacher_meta`

### 📚 Documentation

- Update CHANGELOG.md with release 1.28.0+260214153
## [1.28.0+260214153] - 2026-02-14

### 🚀 Features

- Add filter by document id via constant `Filter.documentId`

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 1.28.0+260214153
## [1.27.6+260206125_bump_deps_versions] - 2026-02-06

### 💼 Other

- *(deps)* Bump versions
## [1.27.5+260206124_apply_orderby_limit_only_if_not_eq_1] - 2026-02-06

### 💼 Other

- Bump flutter_heyteacher_utils version to  1.45.0+260206123
## [1.27.3+260206081_apply_orderby_limit_only_if_not_eq_1] - 2026-02-06

### 🐛 Bug Fixes

- Apply order by only if `limit` != 1
## [1.13.0+250714074_] - 2025-07-14

### 🐛 Bug Fixes

- Correct logical filter string representation in toString method

### 🚜 Refactor

- Rename *ModelView to *ViewModel
- Standardize string quotes and simplify method implementations in store filters
## [1.11.3+250701122_] - 2025-07-01

### 🚜 Refactor

- Rename logger variable for consistency in StoreCache class and add $runtimeType. in each log in order to indentify store name
## [1.11.2+250626153_] - 2025-06-26

### ⚙️ Miscellaneous Tasks

- Update aws-sdk and faraday dependencies to latest versions
## [1.11.1+250625094_] - 2025-06-25

### ⚙️ Miscellaneous Tasks

- Update gem dependencies to latest versions
- Update version and add package_info_plus dependency
## [1.11.0+250618072_] - 2025-06-18

### 🐛 Bug Fixes

- Correct arrayContains filter assignment in ValueStoreFilter
- Handle FirebaseException for unavailable errors in Store class

### 🚜 Refactor

- Simplify StoreCache class by removing unused LightDataType and renaming methods for clarity
## [1.10.7+250607181_] - 2025-06-07

### 🐛 Bug Fixes

- Update flutter_heyteacher_utils dependency to use local path
## [1.10.5+250603193_] - 2025-06-03

### 🐛 Bug Fixes

- Update intl dependency version to ^0.20.2
- Rename initAggregatesStream to _initAggregatesStream and call it during initialization

### 🚜 Refactor

- Streamline aggregate initialization and update notification logic
## [1.10.1+250529094_] - 2025-05-29

### 🐛 Bug Fixes

- Update setAAD method call to use named parameter
## [1.9.2+250528084_] - 2025-05-28

### 🚀 Features

- Implement StoreCache with syncronized package

### 🐛 Bug Fixes

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
## [1.9.1+250523123_] - 2025-05-23

### 🚀 Features

- Add caching mechanism for detailed data in Store class
- Implement caching in exists method and optimize cache update in batch operation
- Implement caching mechanism using shared_preferences in Store class
- Add cache reset functionality in Store class

### 🐛 Bug Fixes

- Remove duplicate clock package from dev_dependencies

### 🚜 Refactor

- Improve logging messages in cache retrieval and data fetching methods
- Enhance exists method to handle document retrieval exceptions
- Change detailsData type to dynamic in detailed data cache
- Format code for better readability in _getCached and _updateCache methods
- Streamline cache key generation in _getCached, _updateCache, and _removeCache methods
- Improve cache management and logging in Store class
- Remove UserStore implementation and related tests
- Update cache handling to use private fields for cache and offline settings

### 📚 Documentation

- Update documentation to include cache functionality in Store class

### 🧪 Testing

- Initialize SharedPreferences in tests and disable cache in TrackStore

### ⚙️ Miscellaneous Tasks

- Add shared_preferences_platform_interface to dev_dependencies
## [1.8.0+250521124_] - 2025-05-21

### 🚜 Refactor

- Update stream return type to Iterable<LightDataType> for improved data handling
- Change log level from fine to finest for detailed logging in Store class
## [1.7.8+250518215_] - 2025-05-18

### 🐛 Bug Fixes

- Update flutter_heyteacher_utils dependency from path to git reference

### 🚜 Refactor

- Rename Auth to AuthModel + create RemoteConfigMode +  update references across the codebase
