// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      title: json['title'] as String,
      post_id: json['post_id'] as String,
      description: json['description'] as String,
      creator_id: json['creator_id'] as String,
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String),
      content_url: json['content_url'] as String,
      likes: json['likes'] as int,
      bookmarks: json['bookmarks'] as int,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'title': instance.title,
      'post_id': instance.post_id,
      'description': instance.description,
      'creator_id': instance.creator_id,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at.toIso8601String(),
      'content_url': instance.content_url,
      'likes': instance.likes,
      'bookmarks': instance.bookmarks,
    };
