import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  const AdminUserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String role;
  final String? fullName;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, email, role, fullName, createdAt];
}
