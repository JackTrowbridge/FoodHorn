import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:foodhorn/src/core/services/CachedVideoRepository.dart';
import 'package:foodhorn/src/features/home/pages/feed_page.dart';
import 'package:foodhorn/src/features/profile/pages/profile_page.dart';
import 'package:foodhorn/src/features/upload/pages/video_form.dart';
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

