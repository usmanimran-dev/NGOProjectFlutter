import 'package:equatable/equatable.dart';

enum UserRole {
  superAdmin,
  ngoAdmin,
  ngoStaff,
  vendorAdmin,
  vendorUser,
  fieldVerifier,
}

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token;
  final String? profileImage;
  final String? vendorId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.profileImage,
    this.vendorId,
  });

  @override
  List<Object?> get props => [id, name, email, role, token, profileImage, vendorId];
}
