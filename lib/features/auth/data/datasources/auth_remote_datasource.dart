import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../models/admin_user_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<AdminUserModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<AdminUserModel?> getCurrentUser();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<AdminUserModel> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email, password: password,
      );
      final user = response.user;
      if (user == null) throw const AuthException(message: 'Sign in failed.');
      final profile = await _fetchProfile(user.id);
      return AdminUserModel.fromSupabase(user: user, profile: profile);
    } on AuthApiException catch (e) {
      throw AuthException(message: e.message);
    } on AuthException { rethrow; }
    catch (e) { throw AuthException(message: e.toString()); }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(message: e.message);
    }
  }

  @override
  Future<AdminUserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      final profile = await _fetchProfile(user.id);
      return AdminUserModel.fromSupabase(user: user, profile: profile);
    } catch (e) { throw AuthException(message: e.toString()); }
  }

  Future<Map<String, dynamic>> _fetchProfile(String userId) async {
    try {
      return await _client.from('users').select('role, full_name').eq('id', userId).single();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: e.code);
    }
  }
}
