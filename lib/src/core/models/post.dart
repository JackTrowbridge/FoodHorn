import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post{
  String title;
  String post_id;
  String description;
  String creator_id;
  DateTime created_at;
  DateTime updated_at;
  String content_url;
  int likes;
  int bookmarks;

  Post ({
    required this.title,
    required this.post_id,
    required this.description,
    required this.creator_id,
    required this.created_at,
    required this.updated_at,
    required this.content_url,
    required this.likes,
    required this.bookmarks,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

}