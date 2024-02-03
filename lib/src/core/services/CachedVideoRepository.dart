import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodhorn/src/core/models/post.dart';
import 'package:foodhorn/src/core/services/CachedDeviceRepository.dart';
import 'package:foodhorn/src/features/profile/services/api_post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class CachedVideoProvider extends ChangeNotifier{

  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;

  XFile? get videoFile => _videoFile;

  set videoFile(XFile? value) {
    _videoFile = value;

    if(_videoFile == null){
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      notifyListeners();
      return;
    }
    _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path));
    _videoPlayerController?.initialize();
    _videoPlayerController?.play();
    _videoPlayerController?.setVolume(0);
    _videoPlayerController?.setLooping(true);

    notifyListeners();
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  Future<File?> compressVideo(String videoFilePath) async {

    final compressedVideoFile = await VideoCompress.compressVideo(
      videoFilePath,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
    );

    if(compressedVideoFile == null){
      return null;
    }

    return compressedVideoFile.file;

  }

  Future<String?> uploadVideoFile(String videoID, String videoPath) async{

    File? compressedVideo = await compressVideo(videoPath);
    if(compressedVideo == null){
      return null;
    }

    UploadTask uploadTask = FirebaseStorage.instance.ref()
        .child("All Videos")
        .child(videoID)
        .putFile(compressedVideo);

    TaskSnapshot taskSnapshot = await uploadTask;

    String contentURL = await taskSnapshot.ref.getDownloadURL();

    return contentURL;

  }

  Future<String?> uploadThumbnail(String videoID, String videoPath) async{

    UploadTask uploadTask = FirebaseStorage.instance.ref()
        .child("All Thumbnails")
        .child(videoID)
        .putFile(await getThumbnailImage(videoPath));

    TaskSnapshot taskSnapshot = await uploadTask;

    String contentURL = await taskSnapshot.ref.getDownloadURL();

    return contentURL;

  }

  Future<File> getThumbnailImage(String videoFilePath) async{
    return await VideoCompress.getFileThumbnail(
      videoFilePath,
    );
  }

  Future<bool> postVideo(String title, String description, String userID, String videoPath) async{

    String? contentURL;
    String? thumbnailURL;

    try{

      String videoID = const Uuid().v4();
      contentURL = await uploadVideoFile(videoID, videoPath);
      thumbnailURL = await uploadThumbnail(videoID, videoPath);

    }catch(e){
      print(e);
    }

    if(contentURL == null || thumbnailURL == null){
      return false;
    }

    String postID = const Uuid().v4();

    Post post = Post(
      title: title,
      post_id: postID,
      description: description,
      creator_id: userID,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
      content_url: contentURL,
      thumbnail_url: thumbnailURL,
      likes: 0,
      bookmarks: 0,
    );

    FirebaseFirestore.instance.collection("posts").add(post.toJson());
    APIPost().addPostToUser(postID);

    return true;
  }


}