import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<String> subtasks;
  final List<String> tags;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.subtasks = const [],
    this.tags = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? subtasks,
    List<String>? tags,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        dueDate,
        priority,
        status,
        category,
        createdAt,
        updatedAt,
        completedAt,
        subtasks,
        tags,
      ];
}