import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foodhorn/src/core/models/user.dart' as aUser;

class APIUser {

  Future<bool> verifyToken() async{

    String? idToken =
    await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/verifyToken');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("UID: ${data['uid']}");
        return true;
      } else {
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    return false;

  }

  Future<aUser.User?> updateUserData(aUser.User newUser) async {
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/updateUserData');

    try {
      // Wrap the http.post call in a Future.timeout
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'username': newUser.username,
        }),
      ).timeout(Duration(seconds: 5)); // Specify the timeout duration here

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        aUser.User user = aUser.User(
            username: data != null ? data['username'] : "Unknown",
            cachedPosts: []
        );

        return user;
      } else {
        print("Error occurred: ${response.body}");
      }
    } on TimeoutException catch (_) {
      // Handle the timeout case
      print("The request timed out.");
    } catch (e) {
      // Handle other errors
      print("Error occurred: $e");
    }

    return null;
  }

  Future<aUser.User?> getUserData() async {
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/getUserData');

    try {
      // Wrap the http.post call in a Future.timeout
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      ).timeout(Duration(seconds: 5)); // Specify the timeout duration here

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        List<Post> posts = [];
        if(data != null && data['posts'] != null){
          for(var post in data['posts']){
            posts.add(Post.fromJson(post));
          }
        }

        aUser.User user = aUser.User(
            username: data != null ? data['username'] : "Unknown",
            cachedPosts: data != null ? posts : []
        );

        return user;
      } else {
        print("Error occurred: ${response.body}");
      }
    } on TimeoutException catch (_) {
      // Handle the timeout case
      print("The request timed out.");
    } catch (e) {
      // Handle other errors
      print("Error occurred: $e");
    }

    return null;
  }
}
