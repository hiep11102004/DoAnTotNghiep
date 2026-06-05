// budget_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import '../../data/models/budget_model.dart';
import 'budget_event.dart'; // Đảm bảo import đúng
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final Dio dio;

  BudgetBloc({required this.dio}) : super(BudgetInitial()) {
    
    // Xử lý lấy danh sách
    on<FetchBudgets>((event, emit) async {
      emit(BudgetLoading());
      try {
        final response = await dio.get(AppConstants.budgets);
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final budgets = data.map((json) => BudgetModel.fromJson(json)).toList();
          emit(BudgetLoaded(budgets));
        } else {
          emit(BudgetError('Lỗi tải ngân sách: ${response.statusCode}'));
        }
      } catch (e) {
        emit(BudgetError('Không thể kết nối server: $e'));
      }
    });

    // Xử lý thêm ngân sách
    on<AddBudget>((event, emit) async {
      // Bắn trạng thái loading để UI biết đang xử lý
      emit(BudgetLoading()); 
      try {
        // 🚀 ĐÃ FIX: Gửi đầy đủ 4 trường dữ liệu lên Laravel
        await dio.post(AppConstants.budgets, data: {
          'category_id': event.categoryId,
          'amount_limit': event.amountLimit,
          'start_date': event.startDate,
          'end_date': event.endDate,
        });
        // Gọi lại FetchBudgets để cập nhật list mới nhất
        add(FetchBudgets());
      } catch (e) {
        emit(BudgetError('Không thể tạo ngân sách: $e'));
        // Sau khi báo lỗi thì nên tải lại danh sách cũ để UI không bị treo
        add(FetchBudgets()); 
      }
    });
  }
}

// 🚀 ĐÃ FIX: Định nghĩa lại Event AddBudget để nhận thêm ngày tháng
class AddBudget extends BudgetEvent {
  final int categoryId;
  final double amountLimit;
  final String startDate;
  final String endDate;
  
  AddBudget({
    required this.categoryId, 
    required this.amountLimit,
    required this.startDate,
    required this.endDate,
  });
}