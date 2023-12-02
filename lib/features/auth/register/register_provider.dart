import 'package:flutter/material.dart';

class RegisterProvider extends ChangeNotifier {
  TextEditingController _email = TextEditingController();
  TextEditingController get email => this._email;

  set email(TextEditingController value) {
    this._email = value;
    notifyListeners();
  }

  TextEditingController _username = TextEditingController();
  TextEditingController get username => this._username;

  set username(TextEditingController value) {
    this._username = value;
    notifyListeners();
  }

  TextEditingController _name = TextEditingController();
  TextEditingController get name => this._name;

  set name(TextEditingController value) {
    this._name = value;
    notifyListeners();
  }

  TextEditingController _password = TextEditingController();
  TextEditingController get password => this._password;

  set password(TextEditingController value) {
    this._password = value;
    notifyListeners();
  }
}
