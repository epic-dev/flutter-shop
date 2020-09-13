import 'package:flutter/widgets.dart';
import 'package:flutter_shop/constants/firebase.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

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
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlPredicate?key=$FIREBASE_API_KEY';
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
      notifyListeners();
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
}
