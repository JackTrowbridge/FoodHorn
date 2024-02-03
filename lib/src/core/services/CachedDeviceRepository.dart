import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';

class DeviceProvider extends ChangeNotifier{

  List<Post> _userPosts = [];

  List<Post> get userPosts => _userPosts;

  set userPosts(List<Post> value) {
    _userPosts = value;
    notifyListeners();
  }

  Future<void> updateUserPosts() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final usersRef = db.collection("users");

    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      return;
    }

    DocumentSnapshot userDoc = await usersRef.doc(auth.currentUser!.uid).get();
    if (!userDoc.exists) {
      print("User not found");
      return;
    }

    List<String> postIDs = List<String>.from(userDoc.get("posts"));
    final postRef = db.collection("posts");

    List<Post> newPosts = [];
    try {
      QuerySnapshot snapshot = await postRef.get();

      for (var doc in snapshot.docs) {
        // Check if the document contains 'post_id' before trying to access it
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('post_id') && postIDs.contains(doc.get('post_id'))) {
          newPosts.add(Post.fromJson(doc.data() as Map<String, dynamic>));
        }
      }

    } catch (e) {
      print("Error fetching posts: $e");
      return;
    }

    // Assuming you have a userPosts variable in your state
    userPosts = newPosts;
  }



}