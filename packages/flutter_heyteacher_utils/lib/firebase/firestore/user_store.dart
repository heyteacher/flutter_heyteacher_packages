import 'store.dart';
import 'user_data.dart';

class UserStore extends Store<UserData, UserData> {
  // singleton
  static UserStore? _instance;
  static UserStore get instance {
    _instance ??= UserStore._();
    return _instance!;
  }
  UserStore._()
      : super(collection: "", fromFirestoreFactory: UserData.fromFirestore);
}
