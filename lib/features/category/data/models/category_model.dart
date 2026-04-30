import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id, required super.nameEn, required super.nameAr,
    required super.slug, super.imageUrl, super.parentId,
    required super.isActive, required super.sortOrder,
    required super.createdAt, required super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id: j['id'] as String, nameEn: j['name_en'] as String,
    nameAr: j['name_ar'] as String, slug: j['slug'] as String,
    imageUrl: j['image_url'] as String?, parentId: j['parent_id'] as String?,
    isActive: j['is_active'] as bool? ?? true,
    sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.parse(j['created_at'] as String),
    updatedAt: DateTime.parse(j['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name_en': nameEn, 'name_ar': nameAr, 'slug': slug,
    if (imageUrl != null) 'image_url': imageUrl,
    if (parentId != null) 'parent_id': parentId,
    'is_active': isActive, 'sort_order': sortOrder,
  };

  factory CategoryModel.fromEntity(CategoryEntity e) => CategoryModel(
    id: e.id, nameEn: e.nameEn, nameAr: e.nameAr, slug: e.slug,
    imageUrl: e.imageUrl, parentId: e.parentId, isActive: e.isActive,
    sortOrder: e.sortOrder, createdAt: e.createdAt, updatedAt: e.updatedAt,
  );
}
