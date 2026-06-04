import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import '../../data/models/category_spending_model.dart'; // Trỏ đúng đường dẫn file Model vừa tạo nhé

// --- EVENTS ---
abstract class ReportEvent {}

class FetchCategorySpending extends ReportEvent {}

// --- STATES ---
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<CategorySpendingModel> spendingList;
  ReportLoaded(this.spendingList);
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}

// --- BLOC ---
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final Dio dio;

  ReportBloc({required this.dio}) : super(ReportInitial()) {
    on<FetchCategorySpending>((event, emit) async {
      emit(ReportLoading());
      try {
        // Gọi API mà ông vừa tạo bên Laravel
        final response = await dio.get(AppConstants.spendingByCategoryReport);
        
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final spendingList = data.map((json) => CategorySpendingModel.fromJson(json)).toList();
          emit(ReportLoaded(spendingList));
        } else {
          emit(ReportError('Lỗi tải báo cáo: ${response.statusCode}'));
        }
      } catch (e) {
        emit(ReportError('Không thể kết nối máy chủ: $e'));
      }
    });
  }
}