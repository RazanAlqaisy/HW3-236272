//Authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
class AuthProvider with ChangeNotifier {
  late FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  AuthProvider.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_authStateChanges);
    _user = _auth.currentUser;
    _authStateChanges(_user);
  }
  Status get status => _status;
  User? get user => _user;
  bool get isAuthenticated => status == Status.Authenticated;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    }
    catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }
  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }
  Future<void> _authStateChanges(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<String> getDLink() async {
    String? userID = _user?.uid;
    String t = await FirebaseStorage.instance
        .ref()
        .child('$userID/profilePic')
        .getDownloadURL();
    notifyListeners();
    return t;
  }

  void sendNotification() {
    notifyListeners();
  }


}
//end of AuthProvider
