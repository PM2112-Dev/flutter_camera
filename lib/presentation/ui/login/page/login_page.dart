import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_camera/presentation/routes/app_routes.dart';
import 'package:flutter_camera/presentation/ui/login/widgets/custom_button.dart';
import 'package:flutter_camera/presentation/ui/login/widgets/custom_text_field.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/shared/widgets/combined_config_widget.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/domain/model/server_config.dart';
import 'package:flutter_camera/domain/model/stream_server_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Config state
  bool _hasServerConfig = false;
  bool _hasStreamServerConfig = false;
  ServerConfig? _currentServerConfig;
  StreamServerConfig? _currentStreamConfig;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkServerConfig();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authPreference = AuthLocalPreference(prefs);

      if (mounted) {
        setState(() {
          _hasServerConfig = authPreference.hasServerConfig();
          _hasStreamServerConfig = authPreference.hasStreamServerConfig();

          // Load existing configs if available
          if (_hasServerConfig) {
            final baseUrl = authPreference.getBaseUrl();
            final port = authPreference.getPort();
            if (baseUrl != null && port != null) {
              _currentServerConfig = ServerConfig(baseUrl: baseUrl, port: port);
            }
          }

          if (_hasStreamServerConfig) {
            final streamBaseUrl = authPreference.getStreamBaseUrl();
            final streamPort = authPreference.getStreamPort();
            if (streamBaseUrl != null && streamPort != null) {
              _currentStreamConfig = StreamServerConfig(baseUrl: streamBaseUrl, port: streamPort);
            }
          }
        });
      }
    } catch (e) {
      print('❌ Error checking server config: $e');
    }
  }

  Future<void> _onCombinedConfigSaved(
    ServerConfig serverConfig,
    StreamServerConfig streamConfig,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authPreference = AuthLocalPreference(prefs);

    try {
      // Save both configurations with URL normalization
      await authPreference.saveServerConfigWithNormalization(
        baseUrl: serverConfig.baseUrl,
        port: serverConfig.port,
      );
      await authPreference.saveStreamServerConfigWithNormalization(
        baseUrl: streamConfig.baseUrl,
        port: streamConfig.port,
      );

      if (mounted) {
        setState(() {
          _hasServerConfig = true;
          _hasStreamServerConfig = true;
          _currentServerConfig = serverConfig;
          _currentStreamConfig = streamConfig;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cấu hình đã được lưu thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu cấu hình thất bại: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            } else if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            }
          },
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    final screenHeight = mediaQuery.size.height;
    final availableHeight = screenHeight - keyboardHeight;

    return Container(
      height: screenHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img_login_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title section
            _buildTitleSection(isKeyboardVisible, availableHeight),

            // Content container
            _buildContentContainer(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isKeyboardVisible, double availableHeight) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isKeyboardVisible ? availableHeight * 0.15 : availableHeight * 0.25,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: isKeyboardVisible ? 24 : 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: const Text('MTKVision', textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildContentContainer(AuthState state) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLoginTab(state), _buildConfigTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: _tabController.index == 0 ? 4 : MediaQuery.of(context).size.width / 2 - 20,
                top: 4,
                bottom: 4,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
              // Tab buttons
              Row(children: [_buildTabButton(0, 'Đăng nhập'), _buildTabButton(1, 'Cấu hình')]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_tabController.index != index) {
            _tabController.animateTo(index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              final isSelected = _tabController.index == index;
              return Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),

            CustomTextField(
              controller: _usernameController,
              label: 'Tên đăng nhập',
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Vui lòng nhập tên đăng nhập' : null,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              obscureText: true,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Đăng nhập',
                textColor: Colors.white,
                gradient: AppGradients.primary,
                isLoading: state is AuthLoading,
                onPressed: state is AuthLoading ? null : _handleLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CombinedConfigWidget(
        onSave: _onCombinedConfigSaved,
        initialServerConfig: _currentServerConfig,
        initialStreamConfig: _currentStreamConfig,
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(username: _usernameController.text, password: _passwordController.text),
      );
    }
  }
}
