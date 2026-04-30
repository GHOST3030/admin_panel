import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/auth/domain/entities/admin_user_entity.dart';

void main() {
  group('AdminUserEntity', () {
    final adminUser = AdminUserEntity(
      id: '1', email: 'admin@test.com',
      role: 'admin', createdAt: DateTime(2024),
    );
    final regularUser = AdminUserEntity(
      id: '2', email: 'user@test.com',
      role: 'user', createdAt: DateTime(2024),
    );

    test('isAdmin returns true for admin role', () => expect(adminUser.isAdmin, isTrue));
    test('isAdmin returns false for non-admin', () => expect(regularUser.isAdmin, isFalse));

    test('supports value equality', () {
      final same = AdminUserEntity(
        id: '1', email: 'admin@test.com',
        role: 'admin', createdAt: DateTime(2024),
      );
      expect(adminUser, equals(same));
    });
  });
}
