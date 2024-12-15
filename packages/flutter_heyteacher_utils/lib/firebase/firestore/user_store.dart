
import 'store.dart';
import 'user_data.dart';

class UserStore extends Store<UserData, UserData> {
  // singleton
  static UserStore? _instance;
  static UserStore get instance {
    _instance ??= UserStore._(
        collection: "",
        listFromFirestoreFactory: UserData.fromFirestore,
        objectFromFirestoreFactory: UserData.fromFirestore);
    return _instance!;
  }

  UserStore._(
      {required super.collection,
      required super.listFromFirestoreFactory,
      required super.objectFromFirestoreFactory});
      
}
