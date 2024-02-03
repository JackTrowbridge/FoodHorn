import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:foodhorn/src/core/services/CachedVideoRepository.dart';
import 'package:foodhorn/src/features/home/pages/feed_page.dart';
import 'package:foodhorn/src/features/home/pages/video_form.dart';
import 'package:foodhorn/src/features/profile/pages/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:foodhorn/src/core/models/user.dart' as user_model;
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_stack),
                label: "Feed"
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.plus_rectangle_fill),
                label: "Upload"
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled),
                label: "Profile"
            ),
          ]
        ),
        tabBuilder: (BuildContext context, int index){
          return CupertinoTabView(
              builder: (BuildContext context) {
                switch(index){
                  case 0:
                    return FeedPage();
                  case 1:
                    return VideoForm();
                  case 2:
                    return ProfilePage();
                }
                return FeedPage();
              }
          );
        }
    );
  }
}

Widget getDebugWidgets(CachedVideoProvider videoProvider, BuildContext context) {

  getVideoFile(CachedVideoProvider cachedVideoProvider, ImageSource sourceImage) async{

    final video = await ImagePicker().pickVideo(source: sourceImage);

    if(video == null){
      print("Video is null");
      return null;
    }

    cachedVideoProvider.videoFile = video;

  }
  return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Text(
            'Welcome to FoodHorn!',
            style: TextStyle(fontSize: 24),
          ),
          CupertinoButton(
              child: Text("Is user logged in?"),
              onPressed: () {
                print(FirebaseAuth.instance.currentUser != null
                    ? "Yes"
                    : "No");
              }),
          CupertinoButton(
              child: Text("Sign up with premade creds"),
              onPressed: () async {
                try {
                  final cred = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: "test@test.com",
                    password: "hello12345",
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    print('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    print('The account already exists for that email.');
                  }
                } catch (e) {
                  print(e);
                }
              }),
          CupertinoButton(
              child: Text("Sign in"),
              onPressed: () {
                try {
                  final cred =
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: "test@test.com",
                    password: "hello12345",
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                } catch (e) {
                  print(e);
                }
              }),
          CupertinoButton(
              child: Text("Sign out"),
              onPressed: () {
                try {
                  FirebaseAuth.instance.signOut();
                } catch (e) {
                  print(e);
                }
              }),
          CupertinoButton(
              child: Text("Create shitpost"),
              onPressed: () async {

                if(FirebaseAuth.instance.currentUser == null){
                  print("User not logged in");
                  return;
                }

                FirebaseFirestore db = FirebaseFirestore.instance;

                user_model.User user = user_model.User(
                  id: FirebaseAuth.instance.currentUser!.uid,
                  posts: [],
                );

                user = user_model.User.fromJson(
                    (await db.collection("users").doc(user.id).get()).data()!
                );

                Post post = Post(
                  title: "Test Post",
                  post_id: const Uuid().v4(),
                  description: "This is a test post",
                  creator_id: "test",
                  created_at: DateTime.now(),
                  updated_at: DateTime.now(),
                  content_url: "https://www.google.com",
                  thumbnail_url: "https://www.google.com",
                  likes: 420,
                  bookmarks: 69,
                );

                user.posts.add(post.post_id);

                db.collection("posts").add(post.toJson());
                db.collection("users").doc(user.id).set(user.toJson());

              }
          ),
          CupertinoButton.filled(
              child: Text("Upload video"),
              onPressed: () async {
                getVideoFile(videoProvider, ImageSource.gallery); // Pass the context to the function
                Navigator.pushNamed(context, '/video_form');
              }
          ),

        ]),

  );
}
