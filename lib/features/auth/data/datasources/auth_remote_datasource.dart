import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/logging/app_logger.dart';
import '../models/admin_user_model.dart';

final _log = AppLogger.getLogger('AuthDataSource');

abstract interface class IAuthRemoteDataSource {
  Future<AdminUserModel> signIn(
      {required String email, required String password});
  Future<void> signOut();
  Future<AdminUserModel?> getCurrentUser();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<AdminUserModel> signIn(
      {required String email, required String password}) async {
    _log.info('Sign-in attempt for email=$email');
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        _log.warning('Sign-in failed: null user returned');
        throw const AuthException(message: 'Sign in failed.');
      }
      final profile = await _fetchProfile(user.id);
      _log.info('Sign-in successful, userId=${user.id}');
      return AdminUserModel.fromSupabase(user: user, profile: profile);
    } on AuthApiException catch (e) {
      _log.warning('Sign-in failed: ${e.message}');
      throw AuthException(message: e.message);
    } on AuthException {
      _log.warning('Authentication error during sign-in');
      rethrow;
    } on ServerException catch (e) {
      _log.severe(
          'Server error during sign-in, statusCode=${e.statusCode}', e);
      rethrow;
    } catch (e, st) {
      _log.severe('Unexpected error during sign-in: ${e.runtimeType}', e, st);
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    _log.info('Sign-out initiated');
    try {
      await _client.auth.signOut();
      _log.info('Sign-out completed');
    } on AuthApiException catch (e) {
      _log.severe('Sign-out failed: ${e.message}', e);
      throw AuthException(message: e.message);
    }
  }

  @override
  Future<AdminUserModel?> getCurrentUser() async {
    _log.fine('Checking current session');
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        _log.fine('No active session found');
        return null;
      }
      _log.fine('Active session found, userId=${user.id}');
      final profile = await _fetchProfile(user.id);
      return AdminUserModel.fromSupabase(user: user, profile: profile);
    } catch (e, st) {
      _log.severe('Failed to get current user', e, st);
      throw AuthException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> _fetchProfile(String userId) async {
    _log.fine('Fetching user profile, userId=$userId');
    try {
      final result = await _client
          .from('users')
          .select('role, full_name')
          .eq('id', userId)
          .single();
      _log.fine('Profile fetched, role=${result['role']}');
      return result;
    } on PostgrestException catch (e) {
      _log.severe('Failed to fetch profile, userId=$userId', e);
      throw ServerException(message: e.message, statusCode: e.code);
    }
  }
}
