import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/firebase_options.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_camera/presentation/routes/app_routes.dart';
import 'package:flutter_camera/presentation/ui/home/pages/home_page.dart';
import 'package:flutter_camera/presentation/ui/login/page/login_page.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/shared/widgets/combined_config_widget.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/domain/model/server_config.dart';
import 'package:flutter_camera/domain/model/stream_server_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase only if not already initialized
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // Firebase already initialized, continue
    print('Firebase already initialized: $e');
  }

  await configureDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MTKVision',
      theme: AppTheme.lightTheme,
      home: const AppInitializer(),
      routes: routes,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _hasServerConfig = false;
  bool _hasStreamServerConfig = false;
  bool _isCheckingConfig = true;
  ServerConfig? _currentServerConfig;
  StreamServerConfig? _currentStreamConfig;

  @override
  void initState() {
    super.initState();
    _checkServerConfig();
  }

  Future<void> _checkServerConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authPreference = AuthLocalPreference(prefs);

      // Debug log
      print('🔍 Checking server config...');
      print('Has server config: ${authPreference.hasServerConfig()}');
      print('Has stream server config: ${authPreference.hasStreamServerConfig()}');
      print('Base URL: ${authPreference.getBaseUrl()}');
      print('Port: ${authPreference.getPort()}');
      print('Stream Base URL: ${authPreference.getStreamBaseUrl()}');
      print('Stream Port: ${authPreference.getStreamPort()}');

      setState(() {
        _hasServerConfig = authPreference.hasServerConfig();
        _hasStreamServerConfig = authPreference.hasStreamServerConfig();

        // Load existing configs if available
        if (_hasServerConfig) {
          final baseUrl = authPreference.getBaseUrl();
          final port = authPreference.getPort();
          if (baseUrl != null && port != null) {
            _currentServerConfig = ServerConfig(baseUrl: baseUrl, port: port);
            print('✅ Server config loaded: $baseUrl:$port');
          }
        }

        if (_hasStreamServerConfig) {
          final streamBaseUrl = authPreference.getStreamBaseUrl();
          final streamPort = authPreference.getStreamPort();
          if (streamBaseUrl != null && streamPort != null) {
            _currentStreamConfig = StreamServerConfig(baseUrl: streamBaseUrl, port: streamPort);
            print('✅ Stream server config loaded: $streamBaseUrl:$streamPort');
          }
        }

        _isCheckingConfig = false;
      });
    } catch (e) {
      print('❌ Error checking server config: $e');
      setState(() {
        _hasServerConfig = false;
        _hasStreamServerConfig = false;
        _isCheckingConfig = false;
      });
    }
  }

  Future<void> _onCombinedConfigSaved(
    ServerConfig serverConfig,
    StreamServerConfig streamConfig,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authPreference = AuthLocalPreference(prefs);

    try {
      // Save both configurations
      await authPreference.saveServerConfig(baseUrl: serverConfig.baseUrl, port: serverConfig.port);
      await authPreference.saveStreamServerConfig(
        baseUrl: streamConfig.baseUrl,
        port: streamConfig.port,
      );

      setState(() {
        _hasServerConfig = true;
        _hasStreamServerConfig = true;
        _currentServerConfig = serverConfig;
        _currentStreamConfig = streamConfig;
      });

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('All configurations saved successfully'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save configurations: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingConfig) {
      return Scaffold(body: AppWidgets.buildLoadingIndicator(message: 'Initializing app...'));
    }

    // If missing any config, show combined config widget
    if (!_hasServerConfig || !_hasStreamServerConfig) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuration Setup'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: CombinedConfigWidget(
            onSave: _onCombinedConfigSaved,
            initialServerConfig: _currentServerConfig,
            initialStreamConfig: _currentStreamConfig,
          ),
        ),
      );
    }

    // If server config exists, proceed with normal auth flow
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(const AuthStatusChecked()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Show loading screen while checking auth status
              if (state is AuthInitial || state is AuthLoading) {
                return Scaffold(
                  body: AppWidgets.buildLoadingIndicator(message: 'Checking authentication...'),
                );
              }

              if (state is AuthAuthenticated) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            },
          );
        },
      ),
    );
  }
}
