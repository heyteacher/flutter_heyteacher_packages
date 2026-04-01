# `flutter_heyteacher_store`

Firebase Firestore library using [generics](https://dart.dev/language/generics|generics).

- use [generics](https://dart.dev/language/generics|generics) to define two
  different DataType in [firestore.CollectionReference.withConverter]
  - `<LightDataType>` the lighweight [FirestoreData] document used in
     [Store.list] and [Store.query]
  - `<DetailsDataType>` the full detailed [FirestoreData] document used in
    [Store.get], [Store.set] and [Store.update]

- manage collection separation in a main collection wich store
  `<LightDataType>` documents and a `<collection>_details` which store
  `<DetailsDataType>` documents (only if `<LightDataType>` and
  `<DetailsDataType>` differs)

- manage the user collection `/users/<uid>/` with [Store._userProfile]
  integrating [FirebaseAuth] using automatically the `uid` of authenticated
  user

- manage data filtering with `StoreFilter`

- manage multiple order by field with `Store.orderByFields`

- implement distinct and group by `Store._groupByFields`

- manage aggregate field via `Store.aggregateFields` and notify aggregate
  value changes via `Store.aggregateStream`

- cache `DetailsDataType` object in `SharedPreferencesAsync`

- use [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore) for tests and example

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.or/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Table of Contents

- [`flutter_heyteacher_store`](#flutter_heyteacher_store)
  - [Table of Contents](#table-of-contents)
  - [Installing](#installing)
  - [Usage](#usage)
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
- group by track `year`

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
           detailsFromFirestoreFactory: TrackData.fromFirestore,
           // group by track year, the map field /users/<uid>/tracks_years 
           //store years and // track count per year
           groupByFields: {
             "years": _groupByYear,
           });

 // function used for group by year the track
 static String _groupByYear(TrackData trackData) {
   return "${trackData.startTime.year}";
 }

 // singleton
 static TrackStore? _instance;
 static TrackStore get instance {
   _instance ??= TrackStore._();
   return _instance!;
 }

}
```

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
       'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
       'duration': duration,
       'distance': distance,
 };
}
```

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
