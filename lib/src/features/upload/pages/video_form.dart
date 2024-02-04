import 'dart:io';

import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:foodhorn/src/core/services/CachedDeviceRepository.dart';
import 'package:foodhorn/src/core/services/CachedVideoRepository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
class VideoForm extends StatefulWidget {

  const VideoForm({super.key});

  @override
  State<VideoForm> createState() => _VideoFormState();
}

class _VideoFormState extends State<VideoForm> {

  bool isUploading = false;

  getVideoFile(CachedVideoProvider cachedVideoProvider, ImageSource sourceImage) async{

    final video = await ImagePicker().pickVideo(source: sourceImage);

    if(video == null){
      print("Video is null");
      return null;
    }

    cachedVideoProvider.videoFile = video;

  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CachedVideoProvider>(builder: (context, videoProvider, child){

      if(videoProvider.videoPlayerController == null){
        return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(99),
                  child: Text("Upload a video"),
                  onPressed: (){
                    getVideoFile(videoProvider, ImageSource.gallery); // Pass the context to the function
                  }
              ),
            )
        );
      }
      return Stack(
        children: [

          // Display video player from videoProvider
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: videoProvider.videoPlayerController == null
                  ? const Center(child: Text("No video"))
                  : VideoPlayer(videoProvider.videoPlayerController!),
            ),
          ),

          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CupertinoButton.filled(
                      child: Text("Cancel"),
                      onPressed: (){
                        videoProvider.videoFile = null;
                      }
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(99),
                        child: Text("Publish"),
                        onPressed: ()async{
                          DeviceProvider deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

                          String? userID = FirebaseAuth.instance.currentUser?.uid;
                          if(userID == null){
                            print("You must be logged in to post a video!");
                            return;
                          }

                          String? videoFilePath = videoProvider.videoFile?.path;
                          if(videoFilePath == null){
                            print("No video file to upload");
                            return;
                          }

                          setState(() {
                            isUploading = true;
                          });
                          Post? post = await videoProvider.postVideo("This is a title", "This is a description", userID, videoFilePath);
                          if(post != null){
                            if(deviceProvider.isUserLoggedIn()){
                              deviceProvider.currentUser?.cachedPosts.add(post);
                            }
                          }
                          setState(() {
                            isUploading = false;
                          });

                        }
                    ),
                  ),

                  if(isUploading)...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Uploading video..."),
                        CupertinoActivityIndicator(),
                      ],
                    )
                  ]

                ],
              ),
            ),
          ),

        ],
      );

    });

  }
}
