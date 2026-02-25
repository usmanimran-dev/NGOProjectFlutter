import 'package:equatable/equatable.dart';

class VendorEntity extends Equatable {
  final String id;
  final String name;
  final String city;
  final String? area;
  final String? address;
  final String? contactNumber;
  final String status;
  final DateTime? createdAt;

  const VendorEntity({
    required this.id,
    required this.name,
    required this.city,
    this.area,
    this.address,
    this.contactNumber,
    this.status = 'ACTIVE',
    this.createdAt,
  });

  factory VendorEntity.fromJson(Map<String, dynamic> json) {
    return VendorEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      area: json['area'],
      address: json['address'],
      contactNumber: json['contact_number'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, city, status];
}
