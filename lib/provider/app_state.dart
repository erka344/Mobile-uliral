import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _user;
  bool get loggedIn => _user != null;

  Future<void> init() async {
    _auth.userChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void signOut() {
    _auth.signOut();
  }
}
