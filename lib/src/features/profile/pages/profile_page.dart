import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:foodhorn/src/core/models/user.dart' as aUser;
import 'package:foodhorn/src/core/services/CachedDeviceRepository.dart';
import 'package:foodhorn/src/features/profile/services/api_post.dart';
import 'package:foodhorn/src/features/profile/services/api_user.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoggingIn = false;
  String errorMessage = "";

  final usernameController = TextEditingController();

  void requestLogin() async {
    setState(() {
      isLoggingIn = true;
    });
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final User? user = cred.user;
      if (user != null) {
        // Get user data
        aUser.User? userData = await APIUser().getUserData();
        if (userData != null) {
          // Set the user data in the device provider
          Provider.of<DeviceProvider>(context, listen: false)
              .setCurrentUser(userData);
        }
        setState(() {
          isLoggingIn = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoggingIn =
            false; // Ensure to stop the loading indicator or login process
      });

      // Handling specific error codes
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        errorMessage =
            "The email address or password is incorrect, please try again.";
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        errorMessage =
            "The email address or password is incorrect, please try again.";
      } else if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
        print(
            'The supplied auth credential is incorrect, malformed or has expired.');
        errorMessage =
            "The email address or password is incorrect, please try again.";
      } else if (e.code == "too-many-requests") {
        print("Too many requests, please try again later.");
        errorMessage =
            "Slow down partner, too many requests, please try again later.";
      } else {
        // Handle other errors
        print('An error occurred: ${e.message}');
        errorMessage = "An error occurred during sign in, please try again.";
      }
    } catch (e) {
      setState(() {
        isLoggingIn =
            false; // Ensure to stop the loading indicator or login process
      });
      print(e);
      errorMessage = "An unexpected error occurred, please try again.";
    }

    setState(() {
      isLoggingIn =
          false; // Ensure to stop the loading indicator or login process
    });
  }

  @override
  Widget build(BuildContext context) {
    double prefixWidth = 120;

    // No user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      return ListView(children: [
        CupertinoListSection(
          dividerMargin: 20,
          additionalDividerMargin: 0,
          backgroundColor: material.Colors.transparent,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemGroupedBackground, context),
            borderRadius: BorderRadius.circular(8),
          ),
          header: Text("Login"),
          children: [
            CupertinoTextFormFieldRow(
              controller: emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
              prefix: SizedBox(
                width: prefixWidth,
                child: const Text("Email Address", textAlign: TextAlign.left),
              ),
              placeholder: "Email address",
              keyboardType: TextInputType.emailAddress,
            ),
            CupertinoTextFormFieldRow(
              controller: passwordController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onEditingComplete: () {
                requestLogin();
                FocusScope.of(context).unfocus();
              },
              prefix: SizedBox(
                width: prefixWidth,
                child: const Text("Password", textAlign: TextAlign.left),
              ),
              placeholder: "Required",
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign In"),
                  if (isLoggingIn) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CupertinoActivityIndicator(),
                    ),
                  ],
                ],
              ),
              onPressed: () {
                requestLogin();
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(errorMessage,
              style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemRed, context),
              )),
        )
      ]);
    }

    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return ListView(
          children: [
            CupertinoButton(
              child: Text("Update user data"),
              onPressed: () async{
                aUser.User? user = await APIUser().getUserData();
                if(user != null){

                  deviceProvider.setCurrentUser(user);
                  setState(() {
                    usernameController.text = user.username;
                    deviceProvider.currentUser?.cachedPosts = user.cachedPosts;
                  });

                }
              },
            ),
            CupertinoButton(
              child: Text("Verify token with python server"),
              onPressed: () async {
                await APIUser().verifyToken();
              },
            ),
            if (deviceProvider.currentUser != null) ...[

              Column(children: [
                Wrap(
                  children: [
                    for (var post in deviceProvider.currentUser!.cachedPosts) ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                        child: CupertinoContextMenu(
                          actions: [
                            CupertinoContextMenuAction(
                              child: const Text('Delete'),
                              isDestructiveAction: true,
                              trailingIcon: CupertinoIcons.delete,
                              onPressed: () async{
                                Navigator.of(context, rootNavigator: true).pop();
                                await APIPost().deletePost(post);
                              },
                            ),
                          ],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // Rounded corners
                            child: Image.network(
                              post.thumbnail_url,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(),
                                  height: 75,
                                  width: 75,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Icon(CupertinoIcons.photo)],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ]),

            ],
            CupertinoListSection(
              dividerMargin: 20,
              additionalDividerMargin: 0,
               header: Text("Your Profile"),
              children: [
                CupertinoTextFormFieldRow(
                  controller: usernameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  prefix: SizedBox(
                    width: prefixWidth,
                    child: const Text("Username", textAlign: TextAlign.left),
                  ),
                  placeholder: "Username",
                  keyboardType: TextInputType.text,
                )
              ],
            ),

            const SizedBox(height: 20),

            CupertinoButton(
                child: Text("Update Profile"),
                onPressed: () async{

                  aUser.User? user = await APIUser().updateUserData(
                      aUser.User(
                          username: usernameController.text,
                          cachedPosts: []
                      )
                  );

                  if(user != null){
                    deviceProvider.setCurrentUser(user);
                    setState(() {
                      usernameController.text = user.username;
                    });
                  }

                }
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(8),
                  child: Text("Sign Out"),
                  onPressed: () {
                    setState(() {
                      // deviceProvider.userPosts = [];
                      FirebaseAuth.instance.signOut();
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
