import 'package:equatable/equatable.dart';

class AuditLogEntity extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String role;
  final String action;
  final String entity;
  final String? entityId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? ipAddress;
  final DateTime? createdAt;

  const AuditLogEntity({
    required this.id,
    required this.userId,
    this.userName,
    required this.role,
    required this.action,
    required this.entity,
    this.entityId,
    this.oldValue,
    this.newValue,
    this.ipAddress,
    this.createdAt,
  });

  factory AuditLogEntity.fromJson(Map<String, dynamic> json) {
    return AuditLogEntity(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user']?['full_name'],
      role: json['role'] ?? '',
      action: json['action'] ?? '',
      entity: json['entity'] ?? '',
      entityId: json['entity_id'],
      oldValue: json['old_value'] is Map ? Map<String, dynamic>.from(json['old_value']) : null,
      newValue: json['new_value'] is Map ? Map<String, dynamic>.from(json['new_value']) : null,
      ipAddress: json['ip_address'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, action, entity];
}
