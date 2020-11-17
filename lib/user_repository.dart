import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Status { Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  String tempAvatar = 'https://thispersondoesnotexist.com/image';
  var url;
  Set<String> saved = Set<String>();
  Status _status = Status.Unauthenticated;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;

  User get user => _user;

  Future<bool> register(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Reference ref = storage.ref().child("image1"+user.email);
      url = await ref.getDownloadURL();
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    url = 'https://thispersondoesnotexist.com/image';
    _user = null;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  void syncPairs(){
    if (user != null) {
    _firestore.collection('users').doc(user.email).set({
      "Pairs": saved.toList(),
    });
    notifyListeners();
    }
  }


  void pullPairs() {
    if(user != null) {
      _firestore.collection('users').doc(user.email).get().then((snapshot) {
        if (snapshot.exists) {
          saved.addAll(snapshot.data()['Pairs'].cast<String>());
          notifyListeners();
        }
        syncPairs();
      });
    }
  }

  void addPair(String pair) {
    saved.add(pair);
    syncPairs();
  }

  void deletePair(String pair) {
    saved.remove(pair);
    syncPairs();
  }
}
