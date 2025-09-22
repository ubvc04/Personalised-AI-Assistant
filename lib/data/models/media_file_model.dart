import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'media_file_model.g.dart';

@JsonSerializable()
class MediaFileModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String path;
  final String type; // 'image', 'video', 'audio', 'document'
  final int size;
  final int? duration; // For audio/video files in seconds
  final String? thumbnailPath;
  final DateTime createdAt;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const MediaFileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.duration,
    this.thumbnailPath,
    required this.createdAt,
    this.tags = const [],
    this.metadata = const {},
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> json) =>
      _$MediaFileModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaFileModelToJson(this);

  MediaFileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? path,
    String? type,
    int? size,
    int? duration,
    String? thumbnailPath,
    DateTime? createdAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return MediaFileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  String get fileExtension => name.split('.').last.toLowerCase();
  
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isDocument => type == 'document';

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        path,
        type,
        size,
        duration,
        thumbnailPath,
        createdAt,
        tags,
        metadata,
      ];
}