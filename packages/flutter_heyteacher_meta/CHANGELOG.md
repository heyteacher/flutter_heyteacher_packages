## [flutter_heyteacher_meta-6.0.1+136] - 2026-03-20

### 💼 Other

- *(deps)* Bump deps to 6.0.1+136

### 📚 Documentation

- Remove `ffmpeg_cmd` docs and add  migration to `monorepo` guide
## [flutter_heyteacher_meta-6.0.0+134] - 2026-03-17

### 🚀 Features

- [**breaking**] Rename `scripts` folder in `tool`.  **BREAKING CHANGE**  Edit `~./bashrc` line `export PATH="$project_meta_root/scripts":$PATH` with `export PATH="$project_meta_root/tool":$PATH`
- [**breaking**] Rename `version.dart` in `dartsemver.dart` and make `executables` in `pubspec.yaml`
- [**breaking**] `configure_git_hooks`, `configure_flutter_package` and `configure_flutter_app` become dart commands and resource file moved into `assets` directory

### 🐛 Bug Fixes

- Remove `dartsemver` from executable. Run instead `dart run flutter_heyteacher_meta:dartsemver show`
- Corrected `configure_flutter_app` copying `AppFastfile`,  corrected destination path of `metadata` and corrected `AppGemfile`
- Remote `\n\t` in lanes description
- Corrected version
- Remove `fastlane/metadata`
- Regenerate version
- Regenerate version

### 💼 Other

- *(deps)* Bump deps to 6.0.0+138
- *(deps)* Bump deps to 7.0.0+140
- *(deps)* Bump deps to 7.0.0+142
- *(deps)* Bump deps to 6.0.0+134
- *(deps)* Bump deps to 6.0.0+134

### 📚 Documentation

- Update documentation adding `monorepo` section  and the new dart commands `configure_*`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.0+140
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+140
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.0+142
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+134
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+134
## [flutter_heyteacher_meta-5.0.0+132] - 2026-03-11

### 🚀 Features

- [**breaking**] Replace `auto-changelog` with `git-cliff`. Install `git-cliff` running `npm install -g git-cliff`

### 💼 Other

- *(deps)* Bump deps to 5.0.0+132

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-5.0.0+132
## [flutter_heyteacher_meta-4.4.5+130] - 2026-03-06

### 🐛 Bug Fixes

- Run `dart pub get` at the end of release for run builders

### 💼 Other

- *(deps)* Bump deps to 4.4.5+130

### 📚 Documentation

- Update `localization` setup example package
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.5+130
## [flutter_heyteacher_meta-4.4.4+128] - 2026-03-05

### 🐛 Bug Fixes

- *(meta)* Add `--tag-prefix` params to `auto-changelog` in order to correct generation of `CHANGELOG.md`

### 💼 Other

- *(deps)* Bump deps to 4.4.4+128

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.4+128
## [flutter_heyteacher_meta-4.4.3+126] - 2026-03-05

### 🐛 Bug Fixes

- *(meta)* `configure_flutter_package` wrong call of `configure_github_hooks`

### 💼 Other

- *(deps)* Bump deps to 4.4.3+126

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.3+126
## [flutter_heyteacher_meta-4.4.2+124] - 2026-03-04

### 🐛 Bug Fixes

- Strip `package_name` extracted from package directory name

### 💼 Other

- *(deps)* Bump deps to 4.4.1+122
- *(deps)* Bump deps to 4.4.1+122
- *(deps)* Bump deps to 4.4.2+124

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.2+124

### ⚙️ Miscellaneous Tasks

- *(meta)* Move git hooks creation into a separated bash file `configure_git_hooks.sh`
- *(meta)* Create release named `{package_name}-{version}` instead of `v{version}` in order to be compatible with `monorepo` projects. Fix typo `http://` url in credits.
## [4.4.0+120] - 2026-03-04

### 🐛 Bug Fixes

- Ignore `build(deps): bump` commits in `CHANGELOG.md`
- Remove debug `exit` in `create_github_release`

### 💼 Other

- *(deps)* Bump deps to 4.2.0+116
- *(deps)* Bump deps to 4.3.0+118
- *(deps)* Bump deps to 4.4.0+120

### 📚 Documentation

- Add `Requirements` and `Credits` section to `README.md` and fix `release` lane documentation
- *(CHANGELOG)* Update CHANGELOG.md with release v4.4.0+120
## [4.1.5+114] - 2026-03-02

### 🐛 Bug Fixes

- In lane `release` increments build before read version

### 💼 Other

- *(deps)* Bump deps to 4.1.5+114

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.5+114
## [4.1.4+111] - 2026-03-02

### 🐛 Bug Fixes

- Remove local `tag` generate in lane `release` when `github:false`
- Ignore CHANGELOG commits updating CHANGELOG.md
- Escape `\` in regex for `--ignore-commit-pattern` param of `auto-changelog`

### 💼 Other

- *(deps)* Bump deps to 4.1.1+105
- *(deps)* Bump deps to 4.1.2+107
- *(deps)* Bump deps to 4.1.3+109
- *(deps)* Bump deps to 4.1.4+111

### 📚 Documentation

- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.4+111

### ⚙️ Miscellaneous Tasks

- Move `bump` lane to `AppFastfile` for `app` projects and remove `exit(0) from ruby function `create_github_release`
## [4.1.0+104] - 2026-02-28

### 🚀 Features

- Add `publish.yml` github action to publish on `pub.dev` on push tag `v{version}`
- Rename `Firestore` lanes `backup` , `restore` and `rm` in `firestore_backup`, `firestore_restore` and `firestore_remove_backup`
- Update`CHANGELOG.md` with `auto-changelog`, generate and push tag then generate release

### 💼 Other

- *(deps)* Bump deps to 4.1.0+103
- *(deps)* Bump deps to 4.1.0+103
- Update tag pattern for publishing workflow

### 📚 Documentation

- Update CHANGELOG.md with release v4.0.0+101
- Update CHANGELOG.md with release v4.1.0+103
- *(CHANGELOG)* Add workflow for generating changelog on release
- *(CHANGELOG)* Delete .github/workflows/changelog.md
- *(CHANGELOG)* Add GitHub Actions workflow for changelog generation
- *(CHANGELOG)* Update repository name in changelog workflow
- *(CHANGELOG)* Delete .github/workflows/changelog.yml
- *(CHANGELOG)* Generate changelog for v4.1.0+104
- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.0+104
- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.0+104
## [4.0.0+101] - 2026-02-27

### 🚀 Features

- Move `FakePubspecVersion`  into a separeted `dart` file and share between tests and example app
- Replace `buildNumber` with a counter and  update example app
- Rename `increment_flutter_build_number` in `increment_build`
- `release` lane add prefix `v` to version and if `github` is `false` create a local tag instead remote. So only a github release generate e remote tag that can automate `pub.dev` publish

### 🐛 Bug Fixes

- Corrected `suffix` parameters and move `increment_build` after version increase and before commit `pubspec.yaml`
- In `release` lane commit `pubspecs.yaml` in current branch and create local tag without `v` prefix in order to prevent publish in `pub.dev` if pushed in remote
- Unit tests corrected for use of common `FakePubspecVersion`

### 💼 Other

- *(deps)* Bump deps to 4.0.0+101

### 📚 Documentation

- Update CHANGELOG.md with release 3.1.2+260226154
## [3.1.2+260226154] - 2026-02-26

### 🐛 Bug Fixes

- Corrected `README.md ` install section and reorder setup subsections
- Add `fastlane/metadata/ skeleton to `app` project via  `configure_flutter_app.sh`

### 💼 Other

- *(deps)* Bump deps version to 3.1.2+260226154

### 📚 Documentation

- Update CHANGELOG.md with release 3.1.1+260226123
## [3.1.1+260226123] - 2026-02-26

### 🐛 Bug Fixes

- Remove pubspec.lock
- Stop force commit of `pubspec.lock`

### 💼 Other

- *(deps)* Bump deps version to 3.1.1+260226123

### 📚 Documentation

- Update CHANGELOG.md with release 3.1.0+260226113
## [3.1.0+260226113] - 2026-02-26

### 🚀 Features

- Reorganize `version` function into a Singleton  and extract `main` into a separeted `dart` file
- Add example `android` and `ios` application
- Add example `android` and `ios` application

### 🐛 Bug Fixes

- Remove ignored `.lock`  files
- Ignore `android/.kotlin` in example
- Install `flutter_heyteacher_meta` as dev dependency

### 💼 Other

- *(deps)* Bump deps version to 3.1.0+260226113

### 📚 Documentation

- Update CHANGELOG.md with release 3.0.1+260225163

### 🧪 Testing

- Add unit tests for `PubspecVersion.version` method

### ⚙️ Miscellaneous Tasks

- Ignore `pubspec.lock' in all subdirectories
- Update example version in `pubspec.yaml`
## [3.0.1+260225163] - 2026-02-25

### 🐛 Bug Fixes

- Typo in `configure_flutter_app`

### 💼 Other

- *(deps)* Bump deps version to 3.0.1+260225163

### 📚 Documentation

- Update CHANGELOG.md with release 3.0.0+260225151
## [3.0.0+260225151] - 2026-02-25

### 🚀 Features

- [**breaking**] Replace local git installation with pub cache installation

### 💼 Other

- *(deps)* Bump deps version to 3.0.0+260225151
## [2.2.3+260225103] - 2026-02-25

### 🐛 Bug Fixes

- *(meta)* `fl bump` do nothing if all files are committed without raising error

### 💼 Other

- *(deps)* Bump deps version to 2.2.3+260225103
## [2.2.2+260225101] - 2026-02-25

### 🐛 Bug Fixes

- Remove link to `http://localhost:8080` due to `pub.dev` alert as insecure

### 💼 Other

- *(deps)* Bump deps version to 2.2.2+260225101

### 📚 Documentation

- Update CHANGELOG.md with release 2.2.1+260222212
## [2.2.1+260222212] - 2026-02-22

### 💼 Other

- *(deps)* Bump deps version to 2.2.1+260222212

### 📚 Documentation

- Update CHANGELOG.md with release 2.2.0+260220161
- Add `fastlane` lanes , `launcher icon` and `splash` documentation
## [2.2.0+260220161] - 2026-02-20

### 🚀 Features

- Add lane`github_release` for create a github release and update `CHANGELOG.md`

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version to 2.2.0+260220161

### 📚 Documentation

- Update CHANGELOG.md with release 2.1.1+260219100
## [2.1.1+260219100] - 2026-02-19

### 🐛 Bug Fixes

- Commit `pubspec.yaml` in `bump` lane, useful when when runs `flutter pub upgrade --major-versions`

### 💼 Other

- *(deps)* Bump deps version
- *(deps)* Bump deps version to 2.1.1+260219100

### 📚 Documentation

- Update CHANGELOG.md with release 2.1.0+260216145
## [2.1.0+260216145] - 2026-02-16

### 🐛 Bug Fixes

- Rename test into `dummy_test`

### 💼 Other

- *(deps)* Bump deps version to 2.1.0+260216145

### 📚 Documentation

- Update CHANGELOG.md with release 2.0.1+260216114
- Add `repository`, 'license`, `issue_tracker`, `homepage`, `documentation`, `topics` and `funding`
## [2.0.1+260216114] - 2026-02-16

### 💼 Other

- *(deps)* Bump deps version to 2.0.1+260216114

### 📚 Documentation

- Update CHANGELOG.md with release 2.0.0+260215111
- Add `installing`, `git utilities`, `documentation utilities`, `webcrypto setup` and `ffmeg utilities` sections
- Add a top description and reorder sections

### ⚙️ Miscellaneous Tasks

- Remove unuseful `launch` lane
- Remove unuseful `build` lane and enhance `release` description
## [2.0.0+260215111] - 2026-02-15

### 💼 Other

- *(deps)* Bump deps version to 2.0.0+260215111

### 🚜 Refactor

- Rename `flutter_heyteacher_fastlane` into `flutter_heyteacher_meta` and add `github` flag to `release` lane to generate or not the github release

### 📚 Documentation

- Update CHANGELOG.md with release 1.2.1+260208140
## [1.2.1+260208140] - 2026-02-08

### 💼 Other

- *(deps)* Bump deps versions
- *(deps)* Bump deps version to 1.2.1+260208140

### 📚 Documentation

- Update CHANGELOG.md with release 1.2.0+260208113

### ⚙️ Miscellaneous Tasks

- Fix lane `bump` getting current branch
- Rename `Pluginfile` to `PluginFile.template`
## [1.2.0+260208113] - 2026-02-08

### 🚀 Features

- Add  lane

### 💼 Other

- *(deps)* Bump deps version to 1.2.0+260208113

### ⚙️ Miscellaneous Tasks

- Conventional commit
- Commit Gemfile.lock on bump lane
- In `fl bump` check if current branch in `main`
- `pre-commit` and `commit-msg` git hooks
- Remove space and eval fastlane/Pluginfile
- Rename `install_app_lanes.sh` with `configure_flutter_app.sh` and `install_common_lanes` with `configure_flutter_package.sh`.
- Fix conventional commit regex
- Fix conventional commit regex
## [1.0.1+260129184_create_release_on_fl_release] - 2026-01-29
