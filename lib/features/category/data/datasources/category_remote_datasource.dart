import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/logging/app_logger.dart';
import '../models/category_model.dart';

final _log = AppLogger.getLogger('CategoryDataSource');

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
    _log.fine('DB SELECT categories');
    try {
      final res = await _t.select().order('sort_order');
      final list = (res as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      _log.info('Categories loaded: count=${list.length}');
      return list;
    } on PostgrestException catch (e) {
      _log.severe('DB error fetching categories: ${e.message}', e);
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e, st) {
      _log.severe('Unexpected error fetching categories', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel m) async {
    _log.fine('DB INSERT category, name=${m.nameEn}');
    try {
      final res = await _t.insert(m.toJson()).select().single();
      final created = CategoryModel.fromJson(res);
      _log.info('Category created: id=${created.id}');
      return created;
    } on PostgrestException catch (e) {
      _log.severe('DB error creating category: ${e.message}', e);
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e, st) {
      _log.severe('Unexpected error creating category', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel m) async {
    _log.fine('DB UPDATE category, id=${m.id}');
    try {
      final res = await _t.update(m.toJson()).eq('id', m.id).select().single();
      final updated = CategoryModel.fromJson(res);
      _log.info('Category updated: id=${updated.id}');
      return updated;
    } on PostgrestException catch (e) {
      _log.severe('DB error updating category: ${e.message}', e);
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e, st) {
      _log.severe('Unexpected error updating category', e, st);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateCategory(String id) async {
    _log.fine('DB UPDATE category deactivate, id=$id');
    try {
      await _t.update({'is_active': false}).eq('id', id);
      _log.info('Category deactivated: id=$id');
    } on PostgrestException catch (e) {
      _log.severe('DB error deactivating category: ${e.message}', e);
      throw ServerException(message: e.message, statusCode: e.code);
    } catch (e, st) {
      _log.severe('Unexpected error deactivating category', e, st);
      throw ServerException(message: e.toString());
    }
  }
}
