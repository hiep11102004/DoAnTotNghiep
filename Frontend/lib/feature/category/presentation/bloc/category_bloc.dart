import 'package:financial_app/feature/category/domain/repository/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';

// --- EVENT ---
abstract class CategoryEvent {}
class FetchCategories extends CategoryEvent {}

// --- STATE ---
abstract class CategoryState {}
class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories; // Dùng Entity chuẩn
  CategoryLoaded(this.categories);
}
class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

// --- BLOC ---
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository; // Tiêm Repository vào thay vì Dio

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await repository.getCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}