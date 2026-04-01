# `flutter_heyteacher_packages`

## Table of Contents

- [`flutter_heyteacher_packages`](#flutter_heyteacher_packages)
  - [Table of Contents](#table-of-contents)
  - [Packages collection](#packages-collection)
  - [`Model-View-ViewModel` (`MVVM`) architecture](#model-view-viewmodel-mvvm-architecture)
  - [`Singleton` pattern](#singleton-pattern)

## Packages collection

The `Flutter Heyteacher` ecosystem created by @heyteacher. A [Pub workspace](https://dart.dev/tools/pub/workspaces) (`monorepo`) packages collection:

- [flutter_heyteacher_meta](packages/flutter_heyteacher_meta): meta project implementing utilities and best practices for Flutter `package` and `app` project avoiding `Copy & Paste pattern`

- [flutter_heyteacher_auth](packages/flutter_heyteacher_auth): authentication utilities via [Firebase Authentication](https://firebase.google.com/docs/auth)

- [flutter_heyteacher_charts](packages/flutter_heyteacher_charts): a high-level Flutter charting library built on top of [fl_chart](https://pub.dev/packages/fl_chart).

- [flutter_heyteacher_connectivity](packages/flutter_heyteacher_connectivity): manage and display connectivity status

- [flutter_heyteacher_e2ee](packages/flutter_heyteacher_e2ee): `End-to-End Encryption` (`E2EE`) workflows with generation, storage, and management of cryptographic keys and `Additional Authenticated Data` (`AAD`)

- [flutter_heyteacher_firebase](packages/flutter_heyteacher_firebase/): integration of [Firebase](https://firebase.google.com/docs)

- [flutter_heyteacher_locale](packages/flutter_heyteacher_locale): manage formatting based on the user's locale, and localization helpers

- [flutter_heyteacher_logger](packages/flutter_heyteacher_logger): UI components and a model for viewing and managing application logs

- [flutter_heyteacher_heyteacher_math](packages/flutter_heyteacher_math): mathematical utilities and algorithms

- [flutter_heyteacher_platform](packages/flutter_heyteacher_platform): platform-specific utilities, UI components, and localization support

- [flutter_heyteacher_site](packages/flutter_heyteacher_site): A set of standardized UI components and utilities for building websites and landing pages

- [flutter_heyteacher_store](packages/flutter_heyteacher_store): a `Firebase Firestore` library using [generics](https://dart.dev/language/generics|generics)

- [flutter_heyteacher_text_to_speech](packages/flutter_heyteacher_text_to_speech): `Text-to-Speech` (`TTS`) functionalities

- [flutter_heyteacher_timer_workflow](packages/flutter_heyteacher_timer_workflow): functionalities to manage timer-based workflows

- [flutter_heyteacher_views](packages/flutter_heyteacher_views): a collection of reusable UI widgets, adaptive layouts, and view utilities

- [flutter_heyteacher_worker](packages/flutter_heyteacher_worker): a [generics](https://dart.dev/language/generics) `Worker<I,O>` class to run long-running tasks in a background isolate

## `Model-View-ViewModel` (`MVVM`) architecture

All packages of the `Flutter Heyteacher` ecosystem implement the `Model-View-ViewModel` (`MVVM`) as described in FLutter [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide).

![`Model-View-ViewModel` architecture](https://docs.flutter.dev/assets/images/docs/app-architecture/guide/feature-architecture-simplified-Data-highlighted.png)

`Data`, the classes with suffix `Data`, represents the data of application without logic, implementing only serialization (`JSON` or `Firestore` ).

`Data` transport information across layers.

Each component exposed by the `Flutter Heyteacher` packages implements one of these layers:

- `View`: `Widget` or `Layout`, a UI component for represent `Data` with basic logic which interacts with one or more `View Model` to aquire `Data`.
  
- `View Model`, the classes with suffix `ViewModel` implemented via [`Singleton` Pattern](#singleton-pattern), retrieve `Data` from `Repository` or `Shared Preferances` or `Service`. `View Model` also implements strong logic.
`Data` are exposed to `View` component in bidirectional way:
  
  - `User Action Trigger commands`: `View` component invoke a `View Model` method after an user action
  
  - `UI State`: `View Model` emits `Data` and `View` component which are listening the `View Model` stream, receives `Data` and refresh itself

- `Repository`: in `Flutter Heyteacher` ecosystem, compoment which extend `Store` class of [flutter_heyteacher_store](packages/flutter_heyteacher_store) package which wraps [Firestore](https://firebase.google.com/docs/firestore).
As for interaction betwen `View` and  `View Model`,  `Data` are exposed to `View Model` component in bidirectional way:

  - `method call`: `View Model` component invoke a `Repository` method (`list`, `get`, `set`, `update`, `delete`, etc)
  
  - `domain model`: `Repository` emits `Data` and `View Model` component which are listening the `Repository` stream, receives `Data`

## `Singleton` pattern

The `View Model` implements the `Singleton` pattern, instantiating a single object instance and avoiding to invoke outside the class.

The benefits of this pattern are:

- the object can share his status to all the application

- only one object are created, avoiding memory leak
