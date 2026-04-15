# `flutter_heyteacher_store`

> [!IMPORTANT]
> __BREAKING CHANGE__ starting from version `3.0.0` the __Group By__ features has been replaced by
> [Pipelines](https://firebase.google.com/docs/firestore/enterprise/pipelines-overview) available only on databases
> __Firestore in Native mode (with Pipeline operations) for Enterprise edition__

Firebase Firestore library using [generics](https://dart.dev/language/generics|generics). This package is specifically designed for the [Flutter HeyTeacher ecosystem](../../).

- use [generics](https://dart.dev/language/generics|generics) to define two
  different DataType in [firestore.CollectionReference.withConverter]
  - `<LightDataType>` the lighweight [FirestoreData] document used in [Store.list] and [Store.query]
  - `<DetailsDataType>` the full detailed [FirestoreData] document used in [Store.get], [Store.set] and [Store.update]

- manage collection separation in a main collection wich store `<LightDataType>` documents and a `<collection>_details` which store `<DetailsDataType>` documents (only if `<LightDataType>` and `<DetailsDataType>` differs)

- manage the user collection `/users/<uid>/` with [Store._userProfile] integrating [FirebaseAuth] using automatically the `uid` of authenticated user

- manage data filtering with `StoreFilter`

- manage multiple order by field with `Store.orderByFields`

- manage aggregate field via `Store.aggregateFields` and notify aggregate value changes via `Store.aggregateStream`

- cache `DetailsDataType` object in `SharedPreferencesAsync`

- expose [Pipelines](https://firebase.google.com/docs/firestore/enterprise/pipelines-overview) on `<LightDataType>` and `<DetailsDataType>` collections ([Pipelines](https://firebase.google.com/docs/firestore/enterprise/pipelines-overview) available only on databases __Firestore in Native mode (with Pipeline operations) for Enterprise edition__)

- use [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore) for tests and example

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Table of Contents

- [`flutter_heyteacher_store`](#flutter_heyteacher_store)
  - [Table of Contents](#table-of-contents)
  - [Installing](#installing)
  - [Usage](#usage)
    - [`TrackStore`](#trackstore)
    - [`BaseTrackData`](#basetrackdata)
    - [`TrackData`](#trackdata)
    - [`CountPerYearData`](#countperyeardata)
    - [`UserStore`](#userstore)
  - [Example](#example)
  - [`fake_cloud_firestore` configuration](#fake_cloud_firestore-configuration)

## Installing

- add `flutter_heyteacher_store` to dependencies

  ```bash
  flutter pub add flutter_heyteacher_store
  ```

- Import the library in your code

  ```dart
  import 'package:flutter_heyteacher_store/firebase/firestore/store.dart';
  ```

- Extends the `abstract` `class` [Store](lib/src/store/store.dart) supplying configuration parameters

## Usage

Consider the following example, store tracks in `Firestore` in these way:

- store in `/users/<uid>/tracks` `BaseTrackData` document (`<LightDataType>`)
- store in `/users<uid>/tracks_details` `TrackData` document (`<DetailsDataType>`)
- order by track `startTime` descending
- aggregate `distance` and `duration` for `sum` and `average`
- count per year using pipeline

### `TrackStore`

Define `TrackStore` class:

```dart
class TrackStore extends Store<BaseTrackData, TrackData> {
 TrackStore._()
     : super(
           // the main collection which store BaseTrackData document
           collection: "tracks",
           // store data into /users/<uid>/tracks
           userProfile: true,
           // order by track start time
           orderByFields: {"startTime": true},
           // aggregate per track distance and track duration 
           // per `sum` and `average`
           aggregateFields: [
             (field: 'distance', aggregatationType: AggregatationType.sum),
             (field: 'distance', aggregatationType: AggregatationType.average),
             (field: 'duration', aggregatationType: AggregatationType.sum),
             (field: 'duration', aggregatationType: AggregatationType.average),
           ],
           // factory per BaseTrackData creation
           fromFirestoreFactory: BaseTrackData.fromFirestore,
           // factory per TrackData creation
           detailsFromFirestoreFactory: TrackData.fromFirestore);

  // singleton
  static TrackStore? _instance;
  static TrackStore get instance {
    _instance ??= TrackStore._();
    return _instance!;
  }

  /// Returns the count per year using pipeline available only on databases
  /// Firestore in Native mode (with Pipeline operations) for Enterprise edition
  Future<Iterable<CountPerYearData?>> get countPerTrackTypeAndYearList async {
    final snapshot = await collectionPipeline
        .aggregateWithOptions(
          AggregateStageOptions(
            accumulators: [CountAll().as('count')],
            groups: [Field('year')],
          ),
        )
        .execute();
    return snapshot.result.map(
      (pipelineResult) => pipelineResult.data() != null
          ? CountPerYearData.fromJson(pipelineResult.data()!)
          : null,
    );
  }
}
```

### `BaseTrackData`

Define the `BaseTrackData` class, the `<LightDataType>` which store basic data in `/users/<uid>/tracks` collection

```dart
class BaseTrackData extends FirestoreData {
 static final DateFormat keyDateTimeFormatter =
 DateFormat("yyyyMMdd_HHmmss");

 DateTime startTime;
 DateTime? stopTime;
 num? duration;
 num? distance;

 @override
 String get id => keyDateTimeFormatter.format(startTime.toLocal());

 BaseTrackData(
     {required this.startTime,
     this.stopTime,
     this.duration,
     this.distance});
 factory BaseTrackData.fromFirestore(Map<String, dynamic> map) {
   return BaseTrackData(
       startTime: FirestoreData.fromFirestoreTimestamp(map["startTime"])!,
       stopTime: map["stopTime"] != null
           ? FirestoreData.fromFirestoreTimestamp(map["stopTime"])
           : null,
       duration: map["stopTime"] != null
          ? map["duration"]
           : calculateDuration(
               FirestoreData.fromFirestoreTimestamp(map["startTime"])!,
               clock.now(),
               0),
       distance: ((map["distance"] as num? ?? 0) * 10).round() / 10);
 }

 @override
 Map<String, dynamic> toFirestore() => {
       'startTime': FirestoreData.toFirestoreTimestamp(startTime),
       'year': startTime.year,
       'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
       'duration': duration,
       'distance': distance,
 };
}
```

### `TrackData`

Define the`TrackData`, the `<DetailsDataType>` which store details data in `/users/<uid>/tracks_details` collection.

- extends the `<LightDataType>` `TrackData`

- implements [FirestoreData.getParentData] and [FirestoreData.setParentData]
  used to get and set data of super class `BaseTrackData` which store data
  in `/users/<uid>/tracks`

So, `<DetailsDataType>` contains the merge of data stored
`/users/<uid>/tracks` `/users/<uid>/tracks_details`

```dart
class TrackData extends BaseTrackData {
  late List<LocationData> locations;

  TrackData(
      {required super.startTime,
      super.stopTime,
      super.duration,
      super.distance,
      super.average,
      this.locations = const []});

  factory TrackData.fromFirestore(Map<String, dynamic> map) {
    List<LocationData> locations = [];
    for (var location in jsonDecode(map["locations"])) {
      locations.add(LocationData.fromJson(location));
    }
    return TrackData(
        startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
        locations: locations);
  }

  @override
  Map<String, dynamic> toFirestore() => {
        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
        'locations': jsonEncode(locations)
      };

  @override
  void setParentData(FirestoreData parentData) {
    BaseTrackData baseTrackData = parentData as BaseTrackData;
    startTime = baseTrackData.startTime;
    distance = baseTrackData.distance;
    duration = baseTrackData.duration;
    stopTime = baseTrackData.stopTime;
  }

  @override
  FirestoreData getParentData() {
    return BaseTrackData(
        startTime: startTime,
        distance: distance,
        duration: duration,
        stopTime: stopTime);
  }
}
```

### `CountPerYearData`

Define `CountPerYearData` which represents the count for a specific year returned by `pipeline` query.

```dart
/// Represents the count for a specific year
class CountPerYearData {
  /// Creates an instance of [CountPerYearData] specifying the
  /// [count] of track for a specific [year]
  const CountPerYearData._({
    required this.count,
    required this.year,
  });

  /// Creates a [CountPerYearData] instance from a JSON map from a pipeline.
  factory CountPerYearData.fromJson(Map<String, dynamic> json) =>
      CountPerYearData._(
        count: json['count'] as int,
        year: json['year'] as int,
      );

  /// The user's Functional Threshold Power (FTP) in watts at the time of the
  /// track.
  final int count;

  /// The user's Functional Threshold Heart Rate (FTHR) in BPM at the time of
  /// the track.
  final int year;
}
```

### `UserStore`

Define the `UserStore`  an user collection `/users/<uid>` ([Store._collection] is empty).
Since `<LightDataType>` and `<DetailsDataType>` are equal to `UserData`
*_details collection isn't created

```dart
class UserStore extends Store<UserData, UserData> {
UserStore._()
     : super(
           collection: "",
           userProfile: true,
           fromFirestoreFactory: UserData.fromFirestore);

// singleton
static UserStore? _instance;
static UserStore get instance {
  _instance ??= UserStore._();
  return _instance!;
}
```

## Example

The complete app example can be found in [`example`](example) directory.

## `fake_cloud_firestore` configuration

In flutter test or in `example` app is useful to work locally without connect to `firebase firestore` instance skipping real authentication and `App Check`.

[fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore) simulates `firebase firestore` into a in-memory local database and simulates Authentication using a fake user locally.

In ordet to configure a fake instance of firestore, add this code on `setup` in your test or in initializiation of `example` app:

```dart
  // mock sign-in
  unawaited(
    AuthViewModel.instance.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'test@example.com',
    ),
  );
  // mock firestore with mock authentication
  final firestore = FakeFirebaseFirestore(
    authObject: AuthViewModel.instance.authForFakeFirestore,
  );
  TrackStore.instance = TrackStore(firebaseFirestore: firestore);
```
