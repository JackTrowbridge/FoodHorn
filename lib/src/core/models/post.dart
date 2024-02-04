import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  String title;
  String description;
  String post_id;
  String creator_id;
  DateTime created_at;
  DateTime updated_at;
  String content_url;
  String thumbnail_url;
  int likes;
  int bookmarks;
  @JsonKey(includeFromJson: false, includeToJson: false) // Updated line
  DocumentSnapshot? documentSnapshot;
  @JsonKey(includeFromJson: false, includeToJson: false) // Updated line
  bool error = false;

  Post({
    required this.title,
    required this.description,
    required this.post_id,
    required this.creator_id,
    required this.created_at,
    required this.updated_at,
    required this.content_url,
    required this.thumbnail_url,
    this.error = false,
    required this.likes,
    required this.bookmarks,
    this.documentSnapshot,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
