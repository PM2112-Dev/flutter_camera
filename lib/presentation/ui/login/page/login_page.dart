import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_camera/presentation/routes/app_routes.dart';
import 'package:flutter_camera/presentation/ui/login/widgets/custom_button.dart';
import 'package:flutter_camera/presentation/ui/login/widgets/custom_text_field.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(kToolbarHeight),
      //   child: Container(
      //     decoration: const BoxDecoration(gradient: AppGradients.primary),
      //     child: AppBar(
      //       title: const Text('Login'),
      //       centerTitle: true,
      //       backgroundColor: Colors.transparent,
      //       elevation: 0,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Container(
          // decoration: const BoxDecoration(
          //   gradient: AppGradients.primarySubtle, // Subtle gradient for background
          // ),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              } else if (state is AuthAuthenticated) {
                // Navigate to home page
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
            builder: (context, state) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/img_login_background.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: AppSpacing.lg,
                                  right: AppSpacing.lg,
                                  top: AppSpacing.lg,
                                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'MTKVision',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: AppSpacing.xl),
                                      CustomTextField(
                                        controller: _usernameController,
                                        label: 'Email',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Vui lòng nhập email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      CustomTextField(
                                        controller: _passwordController,
                                        label: 'Mật khẩu',
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Vui lòng nhập mật khẩu';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return CustomButton(
                                            text: 'Đăng nhập',
                                            gradient: AppGradients.primary, // Use brand gradient
                                            isLoading: state is AuthLoading,
                                            onPressed: state is AuthLoading
                                                ? null
                                                : () {
                                                    if (_formKey.currentState!.validate()) {
                                                      context.read<AuthBloc>().add(
                                                        LoginRequested(
                                                          username: _usernameController.text,
                                                          password: _passwordController.text,
                                                        ),
                                                      );
                                                    }
                                                  },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
