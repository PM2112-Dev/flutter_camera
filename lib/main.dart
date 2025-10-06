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
import 'package:flutter_camera/presentation/ui/notification/pages/notification_detail_page.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MTKVision',
      theme: AppTheme.lightTheme,
      home: const AppInitializer(),
      routes: routes,
      onGenerateRoute: (settings) {
        // Handle routes that require parameters
        if (settings.name == AppRoutes.notificationDetail) {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (_) => NotificationDetailPage(
              notificationId: args['id'] ?? '',
              dataTime: args['dataTime'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
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
