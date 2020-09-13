import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shop/constants/firebase.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  final _storage = FlutterSecureStorage();

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlPredicate) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlPredicate?key=$FIREBASE_API_KEY';
    try {
      var response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      var responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(responseData['expiresIn']),
      ));
      _autoLogout();
      notifyListeners();
      await _storage.write(
          key: 'AUTH_DATA',
          value: json.encode({
            'token': _token,
            'userId': _userId,
            'expiryDate': _expiryDate.toIso8601String(),
          }));
    } catch (e) {
      // re-throw error to catch it in Auth screen
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logOut() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    notifyListeners();
    _storage.deleteAll();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    var timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () {
      logOut();
    });
  }

  Future<bool> tryAutoLogin() async {
    var authDataStorage = await _storage.read(key: 'AUTH_DATA');
    if (authDataStorage == null) {
      return false;
    }
    var authDatas = json.decode(authDataStorage) as Map<String, Object>;
    var expiryDate = DateTime.parse(authDatas['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _expiryDate = expiryDate;
    _token = authDatas['token'];
    _userId = authDatas['userId'];
    notifyListeners();
    _autoLogout();
    return true;
  }
}
