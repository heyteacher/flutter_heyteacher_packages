## [flutter_heyteacher_meta-7.3.0+160] - 2026-03-31

### 🚀 Features

- *(Fastfile)* Show open issues and check issue exists in `checkout` lane

### 💼 Other

- *(flutter_heyteacher_meta)* Update version to 7.3.0+160 which closes #70

### 📚 Documentation

- *(README.md)* Update `fl checkout` documentation
## [flutter_heyteacher_meta-7.2.2+158] - 2026-03-31

### 🐛 Bug Fixes

- Update commits adding `scope` as package name

### 💼 Other

- *(flutter_heyteacher_meta)* Update version to 7.2.2+158 which closes #79

### 📚 Documentation

- *(flutter_heyteacher_meta)* Update `CHANGELOG.md` with flutter_heyteacher_meta-7.2.2+158
## [flutter_heyteacher_meta-7.2.1+156] - 2026-03-27

### 🐛 Bug Fixes

- Compatible with dependency constraint lower bounds

### 💼 Other

- Update version to 7.2.1+156 which closes #62

### 📚 Documentation

- Add usage example to release a new version and close an issue
- Update changelog generated for flutter_heyteacher_meta-7.2.1+156
## [flutter_heyteacher_meta-7.2.0+154] - 2026-03-26

### 🚀 Features

- Add `publish` param to  `release` lane and set `forge` default to `true`

### 💼 Other

- Update version to 7.2.0+154 which closes #40

### 📚 Documentation

- Update changelog generated for flutter_heyteacher_meta-7.2.0+154
## [flutter_heyteacher_meta-7.1.0+152] - 2026-03-26

### 🚀 Features

- Create branch on issue number and add `closes #issue' on commit before merging. On merge delete local branch

### 🐛 Bug Fixes

- Corrected commit message on update `pubspec.yaml`

### 💼 Other

- Update version to 7.1.0+152 which closes #49

### 📚 Documentation

- Update changelog generated for flutter_heyteacher_meta-7.1.0+152
## [flutter_heyteacher_meta-7.0.6+150] - 2026-03-25

### 🚀 Features

- Add  lane
- Add lane`github_release` for create a github release and update `CHANGELOG.md`
- [**breaking**] Replace local git installation with pub cache installation
- Reorganize `version` function into a Singleton  and extract `main` into a separeted `dart` file
- Add example `android` and `ios` application
- Add example `android` and `ios` application
- Move `FakePubspecVersion`  into a separeted `dart` file and share between tests and example app
- Replace `buildNumber` with a counter and  update example app
- Rename `increment_flutter_build_number` in `increment_build`
- `release` lane add prefix `v` to version and if `github` is `false` create a local tag instead remote. So only a github release generate e remote tag that can automate `pub.dev` publish
- Add `publish.yml` github action to publish on `pub.dev` on push tag `v{version}`
- Rename `Firestore` lanes `backup` , `restore` and `rm` in `firestore_backup`, `firestore_restore` and `firestore_remove_backup`
- Update`CHANGELOG.md` with `auto-changelog`, generate and push tag then generate release
- [**breaking**] Replace `auto-changelog` with `git-cliff`. Install `git-cliff` running `npm install -g git-cliff`
- [**breaking**] Rename `scripts` folder in `tool`.  **BREAKING CHANGE**  Edit `~./bashrc` line `export PATH="$project_meta_root/scripts":$PATH` with `export PATH="$project_meta_root/tool":$PATH`
- [**breaking**] Rename `version.dart` in `dartsemver.dart` and make `executables` in `pubspec.yaml`
- [**breaking**] `configure_git_hooks`, `configure_flutter_package` and `configure_flutter_app` become dart commands and resource file moved into `assets` directory
- [**breaking**] Integrate `forgejo` and necome forge indipendent supporting forgejo public instances

### 🐛 Bug Fixes

- Rename test into `dummy_test`
- Commit `pubspec.yaml` in `bump` lane, useful when when runs `flutter pub upgrade --major-versions`
- Remove link to `http://localhost:8080` due to `pub.dev` alert as insecure
- *(meta)* `fl bump` do nothing if all files are committed without raising error
- Typo in `configure_flutter_app`
- Remove ignored `.lock`  files
- Ignore `android/.kotlin` in example
- Install `flutter_heyteacher_meta` as dev dependency
- Remove pubspec.lock
- Stop force commit of `pubspec.lock`
- Corrected `README.md ` install section and reorder setup subsections
- Add `fastlane/metadata/ skeleton to `app` project via  `configure_flutter_app.sh`
- Corrected `suffix` parameters and move `increment_build` after version increase and before commit `pubspec.yaml`
- In `release` lane commit `pubspecs.yaml` in current branch and create local tag without `v` prefix in order to prevent publish in `pub.dev` if pushed in remote
- Unit tests corrected for use of common `FakePubspecVersion`
- Remove local `tag` generate in lane `release` when `github:false`
- Ignore CHANGELOG commits updating CHANGELOG.md
- Escape `\` in regex for `--ignore-commit-pattern` param of `auto-changelog`
- In lane `release` increments build before read version
- Ignore `build(deps): bump` commits in `CHANGELOG.md`
- Remove debug `exit` in `create_github_release`
- Strip `package_name` extracted from package directory name
- *(meta)* `configure_flutter_package` wrong call of `configure_github_hooks`
- *(meta)* Add `--tag-prefix` params to `auto-changelog` in order to correct generation of `CHANGELOG.md`
- Run `dart pub get` at the end of release for run builders
- Remove `dartsemver` from executable. Run instead `dart run flutter_heyteacher_meta:dartsemver show`
- Corrected `configure_flutter_app` copying `AppFastfile`,  corrected destination path of `metadata` and corrected `AppGemfile`
- Remote `\n\t` in lanes description
- Corrected version
- Remove `fastlane/metadata`
- Regenerate version
- Regenerate version
- Add new line `\` in `detect_forge`
- Corrected `merge` invocation for `forgejo`
- In `forge_merge` checkout `main` branch
- Remove`squash` method in `fj pr merge'
- Remove release creation with `forgejo CLI`
- Restore release creation for 'forgejo'
- Corrected `homepage`, 'documentation'
- Waith 2 second before create release in `forgejo` public instance

### 💼 Other

- *(deps)* Bump deps version to 1.2.0+260208113
- *(deps)* Bump deps versions
- *(deps)* Bump deps version to 1.2.1+260208140
- *(deps)* Bump deps version to 2.0.0+260215111
- *(deps)* Bump deps version to 2.0.1+260216114
- *(deps)* Bump deps version to 2.1.0+260216145
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 2.1.1+260219100
- *(deps)* Bump deps version
- *(deps)* Bump deps version to 2.2.0+260220161
- *(deps)* Bump deps version to 2.2.1+260222212
- *(deps)* Bump deps version to 2.2.2+260225101
- *(deps)* Bump deps version to 2.2.3+260225103
- *(deps)* Bump deps version to 3.0.0+260225151
- *(deps)* Bump deps version to 3.0.1+260225163
- *(deps)* Bump deps version to 3.1.0+260226113
- *(deps)* Bump deps version to 3.1.1+260226123
- *(deps)* Bump deps version to 3.1.2+260226154
- *(deps)* Bump deps to 4.0.0+101
- *(deps)* Bump deps to 4.1.0+103
- *(deps)* Bump deps to 4.1.0+103
- Update tag pattern for publishing workflow
- *(deps)* Bump deps to 4.1.1+105
- *(deps)* Bump deps to 4.1.2+107
- *(deps)* Bump deps to 4.1.3+109
- *(deps)* Bump deps to 4.1.4+111
- *(deps)* Bump deps to 4.1.5+114
- *(deps)* Bump deps to 4.2.0+116
- *(deps)* Bump deps to 4.3.0+118
- *(deps)* Bump deps to 4.4.0+120
- *(deps)* Bump deps to 4.4.1+122
- *(deps)* Bump deps to 4.4.1+122
- *(deps)* Bump deps to 4.4.2+124
- *(deps)* Bump deps to 4.4.3+126
- *(deps)* Bump deps to 4.4.4+128
- *(deps)* Bump deps to 4.4.5+130
- *(deps)* Bump deps to 5.0.0+132
- *(deps)* Bump deps to 6.0.0+138
- *(deps)* Bump deps to 7.0.0+140
- *(deps)* Bump deps to 7.0.0+142
- *(deps)* Bump deps to 6.0.0+134
- *(deps)* Bump deps to 6.0.0+134
- *(deps)* Bump deps to 6.0.1+136
- *(deps)* Bump deps to 7.0.0+138
- *(deps)* Bump deps to 7.0.1+140
- *(deps)* Bump deps to 7.0.2+142
- *(deps)* Bump deps to 7.0.3+144
- *(deps)* Bump deps to 7.0.4+146
- *(deps)* Bump deps to 7.0.5+148
- *(deps)* Bump deps to 7.0.6+150

### 🚜 Refactor

- Rename `flutter_heyteacher_fastlane` into `flutter_heyteacher_meta` and add `github` flag to `release` lane to generate or not the github release
- Merge remote-tracking branch 'temp_meta/main' into integrate-monorepo
- Move `flutter_heytacher_meta` to monorepo `flutter_heyteacher_packages`

### 📚 Documentation

- Update CHANGELOG.md with release 1.2.0+260208113
- Update CHANGELOG.md with release 1.2.1+260208140
- Update CHANGELOG.md with release 2.0.0+260215111
- Add `installing`, `git utilities`, `documentation utilities`, `webcrypto setup` and `ffmeg utilities` sections
- Add a top description and reorder sections
- Update CHANGELOG.md with release 2.0.1+260216114
- Add `repository`, 'license`, `issue_tracker`, `homepage`, `documentation`, `topics` and `funding`
- Update CHANGELOG.md with release 2.1.0+260216145
- Update CHANGELOG.md with release 2.1.1+260219100
- Update CHANGELOG.md with release 2.2.0+260220161
- Add `fastlane` lanes , `launcher icon` and `splash` documentation
- Update CHANGELOG.md with release 2.2.1+260222212
- Update CHANGELOG.md with release 3.0.0+260225151
- Update CHANGELOG.md with release 3.0.1+260225163
- Update CHANGELOG.md with release 3.1.0+260226113
- Update CHANGELOG.md with release 3.1.1+260226123
- Update CHANGELOG.md with release 3.1.2+260226154
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
- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.4+111
- *(CHANGELOG)* Update CHANGELOG.md with release v4.1.5+114
- Add `Requirements` and `Credits` section to `README.md` and fix `release` lane documentation
- *(CHANGELOG)* Update CHANGELOG.md with release v4.4.0+120
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.2+124
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.3+126
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.4+128
- Update `localization` setup example package
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-4.4.5+130
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-5.0.0+132
- Update documentation adding `monorepo` section  and the new dart commands `configure_*`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.0+140
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+140
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.0+142
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+134
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.0+134
- Remove `ffmpeg_cmd` docs and add  migration to `monorepo` guide
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-6.0.1+136
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.0+138
- Make indipendent from `forge` provider and add a guide for migrate from `Github` to  `forgejo` public instance
- Update `repository`, `issue_tracker`, `homepage` and `documentation`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.2+142
- Fix `funding` link
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.3+144
- Update migration guide from `Github` to `forgejo` public instance
- Update `git-credential-oauth` installation linking github page with instruction and adding `go` installation as example. Add cache configuration to `~/.gitconfig`
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.4+146
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.4+146
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.5+148
- *(CHANGELOG)* Update CHANGELOG.md with release flutter_heyteacher_meta-7.0.6+150

### 🧪 Testing

- Add unit tests for `PubspecVersion.version` method

### ⚙️ Miscellaneous Tasks

- Conventional commit
- Commit Gemfile.lock on bump lane
- In `fl bump` check if current branch in `main`
- `pre-commit` and `commit-msg` git hooks
- Remove space and eval fastlane/Pluginfile
- Rename `install_app_lanes.sh` with `configure_flutter_app.sh` and `install_common_lanes` with `configure_flutter_package.sh`.
- Fix conventional commit regex
- Fix conventional commit regex
- Fix lane `bump` getting current branch
- Rename `Pluginfile` to `PluginFile.template`
- Remove unuseful `launch` lane
- Remove unuseful `build` lane and enhance `release` description
- Ignore `pubspec.lock' in all subdirectories
- Update example version in `pubspec.yaml`
- Move `bump` lane to `AppFastfile` for `app` projects and remove `exit(0) from ruby function `create_github_release`
- *(meta)* Move git hooks creation into a separated bash file `configure_git_hooks.sh`
- *(meta)* Create release named `{package_name}-{version}` instead of `v{version}` in order to be compatible with `monorepo` projects. Fix typo `http://` url in credits.
