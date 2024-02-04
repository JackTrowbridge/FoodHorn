import 'package:foodhorn/src/core/models/post.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User{
  String username;
  List<Post> cachedPosts = [];

  User({
    required this.username,
    required this.cachedPosts,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

}