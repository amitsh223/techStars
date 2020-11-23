
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constant.dart';


class UserProvider with ChangeNotifier {
  final _url = url;
  Future<void> addprofile(
      FirebaseUser user, String name, String address) async {
    final rsp = await http.patch(
        "https://ambulancetracker-bea10.firebaseio.com/UserInformation/${user.uid}.json",
        body: json.encode({
          "FullName": name,
          "Address": address,
          "uid": user.uid,
          "phone": user.phoneNumber
        }));
    print(rsp.statusCode);
  }

  Future<bool> checkProfile(String uid) async {
    final res = await http.get("$_url/UserInformation/$uid.json");
    final extracted = json.decode(res.body) as Map<String, dynamic>;
    if (extracted == null) {
      return false;
    }
    return true;
  }
}
