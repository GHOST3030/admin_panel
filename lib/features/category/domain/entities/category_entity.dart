import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.slug,
    this.imageUrl,
    this.parentId,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, nameEn, nameAr, slug;
  final String? imageUrl, parentId;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt, updatedAt;

  String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;

  CategoryEntity copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? slug,
    String? imageUrl,
    String? parentId,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CategoryEntity(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        slug: slug ?? this.slug,
        imageUrl: imageUrl ?? this.imageUrl,
        parentId: parentId ?? this.parentId,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameAr,
        slug,
        imageUrl,
        parentId,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
