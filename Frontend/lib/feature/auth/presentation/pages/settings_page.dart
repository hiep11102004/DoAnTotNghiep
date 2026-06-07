import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import 'package:financial_app/core/constants/app_theme.dart';
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
          SnackBar(
            content: const Text('Đã lưu cài đặt'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu cài đặt: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
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
      appBar: AppWidgets.appBar(
        title: 'Cài đặt',
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : Text('Lưu', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const SizedBox(height: AppSpacing.sm),
                _buildSection(
                  title: 'NGÔN NGỮ & GIAO DIỆN',
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
                const SizedBox(height: AppSpacing.xl),
                _buildSection(
                  title: 'TÍNH NĂNG AI',
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: const Icon(Icons.psychology_outlined, color: Colors.purple, size: 20),
                      ),
                      title: Text('Bật AI Coaching', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('Nhận phân tích tài chính từ AI', style: AppTextStyles.caption),
                      value: _enableAI,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _enableAI = v),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSection(
                  title: 'THÔNG BÁO',
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: Icon(Icons.alarm_outlined, color: AppColors.warning, size: 20),
                      ),
                      title: Text('Nhắc nhở hàng ngày', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _reminderTime != null
                            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                            : 'Chưa đặt giờ nhắc',
                        style: AppTextStyles.caption,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_reminderTime != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                              onPressed: () => setState(() => _reminderTime = null),
                            ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        ],
                      ),
                      onTap: _pickReminderTime,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title, style: AppTextStyles.label),
        ),
        Container(
          decoration: AppWidgets.cardDecoration(),
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
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
