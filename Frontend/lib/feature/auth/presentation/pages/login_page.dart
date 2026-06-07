import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl * 2),

                    // Logo & Title
                    _buildHeader(),

                    const SizedBox(height: AppSpacing.xxxl),

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

                    // Login button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(LoginSubmitted(
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
                            : const Text('Đăng Nhập', style: AppTextStyles.button),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Divider
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text('hoặc', style: AppTextStyles.caption),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ]),

                    const SizedBox(height: AppSpacing.lg),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chưa có tài khoản? ', style: AppTextStyles.bodySecondary),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          ),
                          child: Text(
                            'Đăng ký ngay',
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryMid, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_rounded, size: 40, color: AppColors.textOnPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'AI Financial Coach',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Quản lý chi tiêu thông minh cùng AI',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
