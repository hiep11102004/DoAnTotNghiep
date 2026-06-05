import 'package:financial_app/feature/category/data/datasource/category_remote_data_source.dart';
import 'package:financial_app/feature/category/domain/repository/category_repository.dart';

import '../../domain/entities/category_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    // Gọi tầng DataSource lấy Model về và tự động ép kiểu thành Entity trả lên tầng Domain
    return await remoteDataSource.getCategories();
  }
}