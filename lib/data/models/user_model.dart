import 'package:hive/hive.dart';
import 'package:demo/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String roleName;

  const UserModel({
    required String id,
    required String name,
    required String email,
    required this.roleName,
    String? token,
    String? profileImage,
    String? vendorId,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: roleName == 'SUPER_ADMIN'
              ? UserRole.superAdmin
              : roleName == 'NGO_ADMIN'
                  ? UserRole.ngoAdmin
                  : roleName == 'NGO_STAFF'
                      ? UserRole.ngoStaff
                      : roleName == 'VENDOR_ADMIN'
                          ? UserRole.vendorAdmin
                          : roleName == 'VENDOR_USER'
                              ? UserRole.vendorUser
                              : UserRole.fieldVerifier,
          token: token,
          profileImage: profileImage,
          vendorId: vendorId,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      roleName: json['role'] ?? 'NGO_STAFF',
      token: json['token'],
      profileImage: json['profile_image'],
      vendorId: json['vendor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'role': roleName,
      'token': token,
      'profile_image': profileImage,
      'vendor_id': vendorId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? roleName,
    String? token,
    String? profileImage,
    String? vendorId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roleName: roleName ?? this.roleName,
      token: token ?? this.token,
      profileImage: profileImage ?? this.profileImage,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}

// ── Manual Hive Adapter ──
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      roleName: map['roleName'] ?? 'NGO_STAFF',
      token: map['token'],
      profileImage: map['profileImage'],
      vendorId: map['vendorId'],
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'email': obj.email,
      'roleName': obj.roleName,
      'token': obj.token,
      'profileImage': obj.profileImage,
      'vendorId': obj.vendorId,
    });
  }
}
