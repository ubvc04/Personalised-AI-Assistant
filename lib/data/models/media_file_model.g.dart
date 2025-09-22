// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaFileModel _$MediaFileModelFromJson(Map<String, dynamic> json) =>
    MediaFileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MediaFileModelToJson(MediaFileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'path': instance.path,
      'type': instance.type,
      'size': instance.size,
      'duration': instance.duration,
      'thumbnailPath': instance.thumbnailPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
      'metadata': instance.metadata,
    };
