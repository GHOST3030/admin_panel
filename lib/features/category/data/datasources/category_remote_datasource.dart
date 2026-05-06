import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract interface class ICategoryRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> createCategory(CategoryModel m);
  Future<CategoryModel> updateCategory(CategoryModel m);
  Future<void> deactivateCategory(String id);
}

class CategoryRemoteDataSource implements ICategoryRemoteDataSource {
  const CategoryRemoteDataSource(this._client);
  final SupabaseClient _client;
  SupabaseQueryBuilder get _t => _client.from('categories');

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final res = await _t.select().order('sort_order');
      return (res as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) { throw ServerException(message: e.message, statusCode: e.code); }
    catch (e) { throw ServerException(message: e.toString()); }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel m) async {
    try {
      final res = await _t.insert(m.toJson()).select().single();
      return CategoryModel.fromJson(res);
    } on PostgrestException catch (e) { throw ServerException(message: e.message, statusCode: e.code); }
    catch (e) { throw ServerException(message: e.toString()); }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel m) async {
    try {
      final res = await _t.update(m.toJson()).eq('id', m.id).select().single();
      return CategoryModel.fromJson(res);
    } on PostgrestException catch (e) { throw ServerException(message: e.message, statusCode: e.code); }
    catch (e) { throw ServerException(message: e.toString()); }
  }

  @override
  Future<void> deactivateCategory(String id) async {
    try { await _t.update({'is_active': false}).eq('id', id); }
    on PostgrestException catch (e) { throw ServerException(message: e.message, statusCode: e.code); }
    catch (e) { throw ServerException(message: e.toString()); }
  }
}
