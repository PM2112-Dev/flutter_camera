import 'package:flutter_camera/data/services/firebase_messaging_service.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/device_page_wrapper.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/camera_selection_page_wrapper.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_page.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_management_page.dart';
import 'package:flutter_camera/presentation/ui/settings/pages/settings_page.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_bloc.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_count_bloc.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/auth_api_service.dart';
import 'package:flutter_camera/data/network/api/notification_api_service.dart';
import 'package:flutter_camera/data/network/repositories/notification_repository_impl.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  VoidCallback? _refreshDevicePage;
  final FirebaseMessagingService _firebaseMessagingService = getIt<FirebaseMessagingService>();
  late final CameraSelectionProvider _cameraSelectionProvider;

  @override
  void initState() {
    super.initState();
    _firebaseMessagingService.initialize();
    _cameraSelectionProvider = CameraSelectionProvider();
  }

  Future<String> _getUserName(AuthLocalPreference authPreference) async {
    try {
      final tokens = authPreference.getTokens();
      if (tokens?.accessToken != null) {
        final authApiService = getIt<AuthApiService>();
        final response = await authApiService.getProfile(accessToken: tokens!.accessToken);

        if (response.isSuccess && response.data != null) {
          final userData = response.data!;
          return userData.fullName.isNotEmpty
              ? userData.fullName
              : userData.username.isNotEmpty
              ? userData.username
              : 'User';
        }
      }
      return 'User';
    } catch (e) {
      print('Error getting user name: $e');
      return 'User';
    }
  }

  Future<String> _getUserEmail(AuthLocalPreference authPreference) async {
    try {
      final tokens = authPreference.getTokens();
      if (tokens?.accessToken != null) {
        final authApiService = getIt<AuthApiService>();
        final response = await authApiService.getProfile(accessToken: tokens!.accessToken);

        if (response.isSuccess && response.data != null) {
          final userData = response.data!;
          return userData.email.isNotEmpty
              ? userData.email
              : userData.username.isNotEmpty
              ? userData.username
              : 'No email';
        }
      }
      return 'No email';
    } catch (e) {
      print('Error getting user email: $e');
      return 'No email';
    }
  }

  Future<String> _getUserRole(AuthLocalPreference authPreference) async {
    try {
      final tokens = authPreference.getTokens();
      if (tokens?.accessToken != null) {
        final authApiService = getIt<AuthApiService>();
        final response = await authApiService.getProfile(accessToken: tokens!.accessToken);

        if (response.isSuccess && response.data != null) {
          final userData = response.data!;
          return userData.roleNames.isNotEmpty ? userData.roleNames : 'User';
        }
      }
      return 'User';
    } catch (e) {
      print('Error getting user role: $e');
      return 'User';
    }
  }

  void _showLogoutDialog(BuildContext parentContext, AuthLocalPreference authPreference) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _performLogout(parentContext, authPreference);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context, AuthLocalPreference authPreference) async {
    try {
      // Call logout API
      final authApiService = getIt<AuthApiService>();
      await authApiService.logout();
      // Clear local storage
      await authPreference.clearTokens();
      // Close dialog
      Navigator.of(context).pop();
      // Dispatch logout event to AuthBloc (let AppInitializer handle navigation)
      context.read<AuthBloc>().add(const LogoutRequested());
    } catch (e) {
      // Close dialog anyway
      Navigator.of(context).pop();
      // Clear local storage even if API call fails
      await authPreference.clearTokens();
      // Dispatch logout event to AuthBloc (let AppInitializer handle navigation)
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  void _showCameraSelectionDialog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CameraSelectionPageWrapper(cameraSelectionProvider: _cameraSelectionProvider),
      ),
    );

    // Force refresh DevicePage khi quay lại
    if (mounted && _index == 0) {
      _refreshDevicePage?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CameraSelectionProvider>.value(
      value: _cameraSelectionProvider,
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: AppWidgets.buildLoadingIndicator(message: 'Đang khởi tạo ứng dụng...'),
            );
          }

          final prefs = snapshot.data!;
          final authLocalPreference = AuthLocalPreference(prefs);
          final apiService = getIt<NotificationApiService>();
          final repository = NotificationsRepositoryImpl(apiService);
          final useCase = GetNotificationsUseCase(repository);

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<DeviceBloc>()),
              BlocProvider(
                create: (context) => NotificationCountBloc(
                  getNotificationsUseCase: useCase,
                  authLocalPreference: authLocalPreference,
                )..add(FetchNotificationCount()),
              ),
            ],
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  decoration: const BoxDecoration(gradient: AppGradients.primary),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Builder(
                      builder: (context) => Container(
                        margin: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppBorderRadius.small),
                          border: Border.all(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: AppColors.textOnPrimary),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      _index == 0 ? 'Camera' : 'Thông Báo',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: _index == 0
                        ? [
                            Container(
                              margin: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                border: Border.all(
                                  color: AppColors.textOnPrimary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
                                onPressed: () {
                                  _showCameraSelectionDialog();
                                },
                                tooltip: 'Thêm camera',
                              ),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(gradient: AppGradients.primary),
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<String>(
                            future: _getUserName(authLocalPreference),
                            builder: (context, snapshot) => Text(
                              snapshot.data ?? 'Đang tải...',
                              style: AppTextStyles.headline3.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _getUserEmail(authLocalPreference),
                            builder: (context, snapshot) => Text(
                              snapshot.data ?? 'Đang tải...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _getUserRole(authLocalPreference),
                            builder: (context, snapshot) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.textOnPrimary.withOpacity(0.2)),
                              ),
                              child: Text(
                                snapshot.data ?? 'Người dùng',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_active, color: AppColors.primary),
                      title: Text('Quản lý thông báo', style: AppTextStyles.bodyLarge),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationManagementPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings, color: AppColors.primary),
                      title: Text('Cài đặt', style: AppTextStyles.bodyLarge),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Đăng xuất',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.red),
                      ),
                      onTap: () {
                        _showLogoutDialog(context, authLocalPreference);
                      },
                    ),
                  ],
                ),
              ),
              body: IndexedStack(
                index: _index,
                children: [
                  DevicePageWrapper(onRefreshCallback: (callback) => _refreshDevicePage = callback),
                  const NotificationPage(),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _index,
                onTap: (int index) {
                  setState(() {
                    _index = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông Báo'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
