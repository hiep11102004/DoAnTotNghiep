import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/constants/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', state.authEntity.token);
            await prefs.setInt('user_id', state.authEntity.id);
            await prefs.setString('user_name', state.authEntity.name);
            await prefs.setString('user_email', state.authEntity.email);
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.body,
                    decoration: AppWidgets.inputDecoration(
                      label: 'Họ và tên',
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.body,
                    decoration: AppWidgets.inputDecoration(
                      label: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.body,
                    decoration: AppWidgets.inputDecoration(
                      label: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Mật khẩu phải từ 6 ký tự' : null,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Register button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(RegisterSubmitted(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ));
                              }
                            },
                      style: AppWidgets.primaryButtonStyle(radius: AppRadius.md),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.textOnPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Tạo Tài Khoản', style: AppTextStyles.button),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ', style: AppTextStyles.bodySecondary),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Đăng nhập',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryMid, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_rounded, size: 26, color: AppColors.textOnPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Tạo Tài Khoản', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Bắt đầu hành trình tối ưu tài chính cá nhân',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
