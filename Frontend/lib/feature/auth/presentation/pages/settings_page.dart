import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import 'package:financial_app/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Dio _dio = DioClient().dio;

  bool _isLoading = true;
  bool _isSaving = false;

  String _language = 'vi';
  String _theme = 'light';
  bool _enableAI = true;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final response = await _dio.get(AppConstants.userSettings);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : {};
        setState(() {
          _language  = data['language'] ?? 'vi';
          _theme     = data['theme'] ?? 'light';
          _enableAI  = data['enable_ai'] == true || data['enable_ai'] == 1;
          final timeStr = data['daily_reminder_time'] as String?;
          if (timeStr != null && timeStr.isNotEmpty) {
            final parts = timeStr.split(':');
            _reminderTime = TimeOfDay(
              hour:   int.tryParse(parts[0]) ?? 8,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        });
      }
    } catch (_) {
      // Dùng giá trị mặc định nếu chưa có settings
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final body = {
        'language':  _language,
        'theme':     _theme,
        'enable_ai': _enableAI,
        if (_reminderTime != null)
          'daily_reminder_time':
              '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}:00',
      };
      await _dio.put(AppConstants.userSettings, data: body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu cài đặt'), backgroundColor: Color(0xFF27AE60)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu cài đặt: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Lưu', style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Ngôn ngữ & Giao diện',
                  children: [
                    _buildDropdownTile(
                      icon: Icons.language,
                      label: 'Ngôn ngữ',
                      value: _language,
                      items: const {'vi': 'Tiếng Việt', 'en': 'English'},
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                    _buildDropdownTile(
                      icon: Icons.palette_outlined,
                      label: 'Giao diện',
                      value: _theme,
                      items: const {'light': 'Sáng (Light)', 'dark': 'Tối (Dark)'},
                      onChanged: (v) => setState(() => _theme = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Tính năng AI',
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.psychology_outlined, color: Colors.purple, size: 20),
                      ),
                      title: const Text('Bật AI Coaching', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Nhận phân tích tài chính từ AI', style: TextStyle(fontSize: 12)),
                      value: _enableAI,
                      activeColor: const Color(0xFF27AE60),
                      onChanged: (v) => setState(() => _enableAI = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Thông báo',
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.alarm_outlined, color: Colors.orange, size: 20),
                      ),
                      title: const Text('Nhắc nhở hàng ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _reminderTime != null
                            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                            : 'Chưa đặt giờ nhắc',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_reminderTime != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                              onPressed: () => setState(() => _reminderTime = null),
                            ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: _pickReminderTime,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String label,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF27AE60).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF27AE60), size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50)),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
