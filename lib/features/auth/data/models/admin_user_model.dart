import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.email,
    required super.role,
    super.fullName,
    required super.createdAt,
  });

  factory AdminUserModel.fromSupabase({
    required User user,
    required Map<String, dynamic> profile,
  }) => AdminUserModel(
    id: user.id,
    email: user.email ?? '',
    role: profile['role'] as String? ?? 'user',
    fullName: profile['full_name'] as String?,
    createdAt: DateTime.parse(user.createdAt),
  );
}
