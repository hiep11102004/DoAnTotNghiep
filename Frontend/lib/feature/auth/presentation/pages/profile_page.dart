import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'settings_page.dart';
import '../../../../core/constants/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Người dùng';
      _userEmail = prefs.getString('user_email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        appBar: AppBar(
          title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: Text(initials, style: const TextStyle(fontSize: 32, color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(_userName, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(_userEmail, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        // Main menu card
        Container(
          decoration: AppWidgets.cardDecoration(),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.savings_outlined,
                label: 'Mục tiêu tiết kiệm',
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/saving-goals'),
              ),
              _divider(),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Thông báo',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              _divider(),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                label: 'Cài đặt',
                color: Colors.blueGrey,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Logout card — separate, highlighted
        Container(
          decoration: BoxDecoration(
            color: AppColors.expense.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.expense.withOpacity(0.15)),
          ),
          child: _buildMenuItem(
            icon: Icons.logout_rounded,
            label: 'Đăng xuất',
            color: AppColors.expense,
            onTap: _confirmLogout,
            textColor: AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: textColor ?? AppColors.textPrimary)),
      trailing: Icon(Icons.chevron_right_rounded, color: textColor?.withOpacity(0.5) ?? AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16);

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutSubmitted());
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
