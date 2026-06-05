import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_bloc.dart';
import 'notification_datasource.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)));
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Chưa có thông báo nào', style: TextStyle(color: Colors.grey, fontSize: 15)),
                ]),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<NotificationBloc>().add(FetchNotifications()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) => _buildNotificationItem(context, state.notifications[index]),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel n) {
    return InkWell(
      onTap: () {
        if (!n.isRead) {
          context.read<NotificationBloc>().add(MarkNotificationAsRead(n.id));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xFFF0FBF5),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(n.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getTypeIcon(n.type), color: _getTypeColor(n.type), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 13.5, color: const Color(0xFF2C3E50))),
                      ),
                      if (!n.isRead)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF27AE60), shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(_formatDate(n.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'budget_alert': return Colors.orange;
      case 'achievement': return Colors.green;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'budget_alert': return Icons.warning_amber_rounded;
      case 'achievement': return Icons.emoji_events;
      default: return Icons.notifications;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
