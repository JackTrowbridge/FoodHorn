import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:video_player/video_player.dart';
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  List<Post> posts = []; // There should only be 3 posts loaded at a time
  Map<int, VideoPlayerController> _controllers = {}; // Should only be 3 controllers at a time
  PageController _pageController = PageController(initialPage: 0);

  Timer? _debounce;

  void _populateScreens() async {
    List<Post>? newPosts = await _fetchPosts();
    if(newPosts != null){

      setState(() {
        posts = newPosts;
      });

      for(var post in posts) {
        int index = posts.indexOf(post);
        try{
          _controllers[index] =
          VideoPlayerController.networkUrl(Uri.parse(post.content_url))
            ..initialize().then((_) {
              setState(() {}); // Update the UI to show the video
              _controllers[index]!.setLooping(true);
              if (index == _pageController.page!.round()) {
                _controllers[index]!.play();
              }
            }).timeout(const Duration(seconds: 5));
        }catch(e){
          print("Error initializing video player: $e");
          posts[index].error = true; // Set error to true if there is an error
        }

      }

    }
  }

  Future<List<Post>?> _fetchPosts() async {

    FirebaseFirestore db = FirebaseFirestore.instance;
    final postsRef = db.collection("posts"); // Sometimes might only have 1 video in it.

    Query query = postsRef.orderBy("created_at", descending: true).limit(3);

    try{
      var snapshot = await query.get().timeout(const Duration(seconds: 5));

      List<Post> newPosts = [];
      for (var doc in snapshot.docs) {
        var postData = Post.fromJson(doc.data() as Map<String, dynamic>);
        postData.documentSnapshot = doc;
        newPosts.add(postData);
      }

      return newPosts;

    }catch(e){
      print("Error fetching posts: $e");
    }

    return null;

  }

  void _onUpdate() async{
    print("Adding more posts");
    List<Post>? newPosts = await _fetchPosts();
    if(newPosts != null){
      setState(() {
        posts.addAll(newPosts);
      });

      for(var post in newPosts) {
        int index = posts.indexOf(post);
        try{
          _controllers[index] =
          VideoPlayerController.networkUrl(Uri.parse(post.content_url))
            ..initialize().then((_) {
              setState(() {}); // Update the UI to show the video
              _controllers[index]!.setLooping(true);
              if (index == _pageController.page!.round()) {
                _controllers[index]!.play();
              }
            }).timeout(const Duration(seconds: 5));
        }catch(e){
          print("Error initializing video player: $e");
          posts[index].error = true; // Set error to true if there is an error
        }

      }

    }
  }

  void _onScrollFinished() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Check if the current page is at the end of the list
      int currentPage = _pageController.page!.round();
      bool isAtEnd = currentPage == posts.length - 1;

      // Trigger update if on the second to last page or the last page
      if (currentPage >= posts.length - 2) {
        _onUpdate();
      }

      // Additional logic to handle when the user has reached the very end
      if (isAtEnd) {
        // Handle the case when the user is at the bottom of the page view.
        // This could be showing some UI indication or loading more content if available
        print('Reached the bottom of the PageView');
      }
    });
  }

  void _onScroll(){

    int currentPage = _pageController.page!.round();


    // Pause all other videos
    _controllers.forEach((key, value) {
      if(key != _pageController.page!.round()){
        value.pause();
      }
    });

    // Play the video for the current page
    if(_controllers.containsKey(currentPage)){
      _controllers[currentPage]!.play();
    }


  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
    _pageController.addListener(_onScrollFinished);
    _populateScreens();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.removeListener(_onScrollFinished);
    _pageController.dispose();
    _controllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: posts.length, // Always have 3 screens
        itemBuilder: (context, index) {
          // Check if the post exists for the current index
          if (index < posts.length && posts[index].error != true) {
            // Check if a video controller exists for the current post
            if (_controllers.containsKey(index)) {

              if(_controllers[index]!.value.isInitialized) {

                return Stack(
                  children: [

                    SafeArea(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: AspectRatio(
                            aspectRatio: _controllers[index]!.value.aspectRatio,
                            child: VideoPlayer(_controllers[index]!),
                        ),
                      ),
                    ),
                    _controllers[index]!.value.isBuffering
                        ? const CupertinoActivityIndicator()
                        : const SizedBox.shrink(),

                    Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                CupertinoColors.darkBackgroundGray.withOpacity(0),
                                CupertinoColors.darkBackgroundGray.withOpacity(0.5),
                                CupertinoColors.darkBackgroundGray.withOpacity(0.8),
                                CupertinoColors.darkBackgroundGray.withOpacity(1),
                              ],
                            ),
                          ),
                        )
                    ),

                    Positioned(
                        bottom: 75,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Username",
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(posts[index].title,
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 20,
                                ),
                              ),

                              Text(posts[index].description,
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                ),
                              ),

                            ],
                          ),
                        )
                    ),


                  ],
                );

              }else{
                return const Center(child: CupertinoActivityIndicator());
              }
            }
          }

          // Default "Oops" screen for cases where the post doesn't exist, has an error, or the controller isn't initialized
          return Container(
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
            ),
            child: Center(
              child: Text(
                "Oops! Something went wrong.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
