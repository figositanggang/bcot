import 'package:bcot/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => this._user;

  set user(UserModel? value) {
    this._user = value;
    notifyListeners();
  }
}
