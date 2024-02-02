import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:uuid/uuid.dart';
import 'package:foodhorn/src/core/models/user.dart' as user_model;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return CupertinoApp(builder: (context, child) {
      return CupertinoPageScaffold(
        child: Center(
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
                    onPressed: (){

                      if(FirebaseAuth.instance.currentUser == null){
                        print("User not logged in");
                        return;
                      }

                      user_model.User user = user_model.User(
                        id: FirebaseAuth.instance.currentUser!.uid,
                        posts: [],
                      );

                      Post post = Post(
                        title: "Test Post",
                        post_id: const Uuid().v4(),
                        description: "This is a test post",
                        creator_id: "test",
                        created_at: DateTime.now(),
                        updated_at: DateTime.now(),
                        content_url: "https://www.google.com",
                        likes: 420,
                        bookmarks: 69,
                      );

                      user.posts.add(post.post_id);

                      FirebaseFirestore db = FirebaseFirestore.instance;
                      db.collection("posts").add(post.toJson());
                      db.collection("users").doc(user.id).set(user.toJson());

                    }
                )
              ]),
        ),
      );
    });
  }
}
