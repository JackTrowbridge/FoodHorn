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

  Future<String?> uploadVideoFile(String videoPath) async{

    File? compressedVideo = await compressVideo(videoPath);
    if(compressedVideo == null){
      return null;
    }

    UploadTask uploadTask = FirebaseStorage.instance.ref()
        .child("All Videos")
        .putFile(compressedVideo);

    TaskSnapshot taskSnapshot = await uploadTask;

    String contentURL = await taskSnapshot.ref.getDownloadURL();

    return contentURL;

  }

  Future<String?> uploadThumbnail(String videoPath) async{

    UploadTask uploadTask = FirebaseStorage.instance.ref()
        .child("All Thumbnails")
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

  Future<Post?> postVideo(String title, String description, String userID, String videoPath) async{

    String? contentURL;
    String? thumbnailURL;

    try{

      contentURL = await uploadVideoFile(videoPath);
      thumbnailURL = await uploadThumbnail(videoPath);

    }catch(e){
      print(e);
    }

    if(contentURL == null || thumbnailURL == null){
      return null;
    }

    Post post = Post(
      title: title,
      description: description,
      post_id: "Not set",
      creator_id: userID,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
      content_url: contentURL,
      thumbnail_url: thumbnailURL,
      likes: 0,
      bookmarks: 0,
    );

    // DocumentReference documentReference = await FirebaseFirestore.instance.collection("posts").add(post.toJson());
    await APIPost().addPost(post);

    return post;
  }



}