
import 'package:admin_panel/features/auth/data/models/admin_user_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<AdminUserModel> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<AdminUserModel?> getCurrentUser();
}
