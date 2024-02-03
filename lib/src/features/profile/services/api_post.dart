import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class APIPost{

  Future<bool> addPostToUser(String postID) async {

    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/addPostToUser');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'postId': postID,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Post added: ${data['postID']}");
        return true;
      } else {
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    return false;
  }

  Future<bool> deletePost(String postID) async {

    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse('http://192.168.1.127:5200/deletePost');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'postId': postID,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Post deleted: ${data['postID']}");
        return true;
      } else {
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    return false;
  }

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

}