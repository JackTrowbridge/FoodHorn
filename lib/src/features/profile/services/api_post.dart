import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APIPost {

  Future<bool> deletePost(Post post) async {
    String? idToken =
    await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/deletePost');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'postId': post.post_id,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return true;
      } else {
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    return false;
  }

  Future<bool> addPost(Post post) async {

    String? idToken =
    await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/addPost');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'post': post.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return true;
      } else {
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    return false;
  }

}