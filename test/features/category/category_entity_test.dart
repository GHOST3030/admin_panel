import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/category/domain/entities/category_entity.dart';

void main() {
  final cat = CategoryEntity(
    id: 'c1', nameEn: 'Men', nameAr: 'رجال', slug: 'men',
    isActive: true, sortOrder: 1,
    createdAt: DateTime(2024), updatedAt: DateTime(2024),
  );

  group('CategoryEntity', () {
    test('localizedName returns EN', () => expect(cat.localizedName('en'), 'Men'));
    test('localizedName returns AR', () => expect(cat.localizedName('ar'), 'رجال'));
    test('copyWith updates single field', () {
      final updated = cat.copyWith(nameEn: 'Updated');
      expect(updated.nameEn, 'Updated');
      expect(updated.nameAr, cat.nameAr);
    });
  });
}
