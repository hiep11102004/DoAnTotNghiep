import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_datasource.dart';

// ---- EVENTS ----
abstract class NotificationEvent {}

class FetchNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final int id;
  MarkNotificationAsRead(this.id);
}

// ---- STATES ----
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// ---- BLOC ----
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationDatasource datasource;

  NotificationBloc(this.datasource) : super(NotificationInitial()) {

    on<FetchNotifications>((event, emit) async {
      emit(NotificationLoading());
      try {
        final notifications = await datasource.getNotifications();
        emit(NotificationLoaded(notifications));
      } catch (e) {
        emit(NotificationError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<MarkNotificationAsRead>((event, emit) async {
      try {
        await datasource.markAsRead(event.id);
        add(FetchNotifications());
      } catch (_) {
        // Lỗi mark as read thì bỏ qua
      }
    });
  }
}
