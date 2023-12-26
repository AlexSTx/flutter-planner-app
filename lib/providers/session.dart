import 'package:flutter/material.dart';

import '../model/user.dart';

class Session extends ChangeNotifier {
  User? session;

  void logOut() => session = null;

  void logIn(User user) => session = user;

  bool get isLoggedIn {
    return session != null;
  }

  int? getSessionUserId() {
    return session?.id;
  }
}
