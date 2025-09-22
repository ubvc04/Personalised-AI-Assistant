import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> additionalInfo;

  const ContactModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo = const {},
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);

  ContactModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        avatarUrl,
        isFavorite,
        createdAt,
        updatedAt,
        additionalInfo,
      ];
}