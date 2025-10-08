import 'package:flutter_camera/data/services/firebase_messaging_service.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_camera/presentation/bloc/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/device_page_wrapper.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/camera_selection_page_wrapper.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_stream_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_page.dart';
import 'package:flutter_camera/presentation/ui/notification/pages/notification_management_page.dart';
import 'package:flutter_camera/presentation/ui/settings/pages/settings_page.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_bloc.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_state.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_count_bloc.dart';
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_list_bloc.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/auth_api_service.dart';
import 'package:flutter_camera/data/network/api/notification_api_service.dart';
import 'package:flutter_camera/data/network/repositories/notification_repository_impl.dart';
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart';
import 'package:flutter_camera/presentation/ui/notification/models/notification_filter.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper classes for filter options
class CompareTypeOption {
  final String code;
  final String name;

  CompareTypeOption({required this.code, required this.name});
}

class StatusOption {
  final String code;
  final String name;

  StatusOption({required this.code, required this.name});
}

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
  final GlobalKey _filterButtonKey = GlobalKey();
  NotificationFilter _notificationFilter = NotificationFilter();

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
    // Clear camera selection data before logout to prevent conflicts
    try {
      await _cameraSelectionProvider.clearAll();
      print('✅ Camera selection cleared');
    } catch (e) {
      print('⚠️ Error clearing camera selection: $e');
    }

    // Clear camera stream data before logout to prevent conflicts
    try {
      // Try to get streamDataProvider from context if available
      final streamDataProvider = context.read<CameraStreamDataProvider>();
      streamDataProvider.clearAllStreamData();
      print('✅ Camera stream data cleared');
    } catch (e) {
      print('⚠️ Error clearing stream data (provider not available in this context): $e');
    }

    // Close dialog
    Navigator.of(context).pop();

    // Dispatch logout event to AuthBloc (it will handle API call and token clearing)
    context.read<AuthBloc>().add(const LogoutRequested());
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

  void _showFilterDialog(BuildContext mainContext) {
    final RenderBox? renderBox = _filterButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            Positioned(
              top: position.dy,
              right: 8,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: _FilterDialogContent(
                    filter: _notificationFilter,
                    mainContext: mainContext,
                    onFilterChanged: (newFilter) {
                      setState(() {
                        _notificationFilter = newFilter;
                      });
                      Navigator.pop(dialogContext);
                    },
                    onClearAll: () {
                      setState(() {
                        _notificationFilter = NotificationFilter();
                      });
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // padding status bar
    final double statusBarHeight = MediaQuery.of(context).padding.top;

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
              BlocProvider(
                create: (context) => NotificationListBloc(
                  getNotificationsUseCase: useCase,
                  authLocalPreference: authLocalPreference,
                )..add(FetchNotificationList()),
              ),
            ],
            child: Builder(
              builder: (scaffoldContext) => Scaffold(
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
                          : [
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
                                child: Stack(
                                  children: [
                                    IconButton(
                                      key: _filterButtonKey,
                                      icon: const Icon(
                                        Icons.filter_list,
                                        color: AppColors.textOnPrimary,
                                      ),
                                      onPressed: () => _showFilterDialog(scaffoldContext),
                                      tooltip: 'Lọc thông báo',
                                    ),
                                    if (_notificationFilter.hasActiveFilters)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.info,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        decoration: const BoxDecoration(gradient: AppGradients.primary),
                        padding: EdgeInsets.fromLTRB(24, statusBarHeight + 16, 24, 24),
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
                                  border: Border.all(
                                    color: AppColors.textOnPrimary.withOpacity(0.2),
                                  ),
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
                    DevicePageWrapper(
                      onRefreshCallback: (callback) => _refreshDevicePage = callback,
                    ),
                    NotificationPage(
                      key: ValueKey(_notificationFilter.hashCode),
                      filter: _notificationFilter,
                    ),
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
            ),
          );
        },
      ),
    );
  }
}

// Filter Dialog Content Widget
class _FilterDialogContent extends StatefulWidget {
  final NotificationFilter filter;
  final BuildContext mainContext;
  final Function(NotificationFilter) onFilterChanged;
  final VoidCallback onClearAll;

  const _FilterDialogContent({
    required this.filter,
    required this.mainContext,
    required this.onFilterChanged,
    required this.onClearAll,
  });

  @override
  State<_FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<_FilterDialogContent> {
  late NotificationFilter _localFilter;
  List<CompareTypeOption> _availableCompareTypes = [];
  List<String> _availableAreas = [];

  // Expand/collapse states
  bool _isTimeExpanded = true;
  bool _isCompareTypeExpanded = true;
  bool _isAreaExpanded = true;
  bool _isStatusExpanded = true;

  // Fixed status options
  final List<StatusOption> _fixedStatuses = [
    StatusOption(code: 'PENDING', name: 'Chưa xử lý'),
    StatusOption(code: 'RESOLVED', name: 'Đã xử lý'),
  ];

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
    _loadExpandStates();
    _extractAvailableOptions();
  }

  Future<void> _loadExpandStates() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isTimeExpanded = prefs.getBool('filter_time_expanded') ?? true;
        _isCompareTypeExpanded = prefs.getBool('filter_compareType_expanded') ?? true;
        _isAreaExpanded = prefs.getBool('filter_area_expanded') ?? true;
        _isStatusExpanded = prefs.getBool('filter_status_expanded') ?? true;
      });
      print(
        '📥 Loaded expand states: Time=$_isTimeExpanded, Compare=$_isCompareTypeExpanded, Area=$_isAreaExpanded, Status=$_isStatusExpanded',
      );
    }
  }

  Future<void> _saveExpandState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    print('💾 Saved $key = $value');
  }

  void _extractAvailableOptions() {
    try {
      // Extract compareTypes from NotificationListBloc
      final notificationListBloc = widget.mainContext.read<NotificationListBloc>();
      final notificationState = notificationListBloc.state;

      print('🔍 Filter dialog - NotificationList state: ${notificationState.runtimeType}');

      if (notificationState is NotificationListLoaded) {
        final notifications = notificationState.notifications;
        print('📊 Filter dialog - Total notifications: ${notifications.length}');

        // Extract unique compareType options
        final compareTypeSet = <String, CompareTypeOption>{};

        for (var notification in notifications) {
          // CompareType
          if (notification.compareTypeObject != null) {
            final code = notification.compareTypeObject!.code;
            final name = notification.compareTypeObject!.name;
            if (code != null && name != null) {
              compareTypeSet[code] = CompareTypeOption(code: code, name: name);
            }
          }
        }

        print('✅ CompareTypes found: ${compareTypeSet.length} - ${compareTypeSet.keys.join(", ")}');

        setState(() {
          _availableCompareTypes = compareTypeSet.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
        });
      } else {
        print('⚠️ NotificationList state is not loaded: $notificationState');
      }

      // Extract areas from DeviceBloc
      final deviceBloc = widget.mainContext.read<DeviceBloc>();
      final deviceState = deviceBloc.state;

      print('🔍 Filter dialog - Device state: ${deviceState.runtimeType}');

      if (deviceState is DeviceStartedState) {
        final areaTrees = deviceState.areaTrees;
        print('📊 Filter dialog - Total area trees: ${areaTrees.length}');

        // Extract ONLY leaf area names (areas without children) to avoid parent-child confusion
        final areaSet = <String>{};

        void extractLeafAreasRecursively(List<AreaTreeWithCameras> areas) {
          for (var area in areas) {
            if (area.children.isEmpty && area.name.isNotEmpty) {
              // This is a leaf area (no children)
              areaSet.add(area.name);
            } else {
              // This has children, continue recursively
              extractLeafAreasRecursively(area.children);
            }
          }
        }

        extractLeafAreasRecursively(areaTrees);

        print('✅ Leaf Areas found: ${areaSet.length} - ${areaSet.take(5).join(", ")}...');

        setState(() {
          _availableAreas = areaSet.toList()..sort();
        });
      } else {
        print('⚠️ Device state is not started: $deviceState');
      }
    } catch (e) {
      print('❌ Error extracting filter options: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.medium),
              topRight: Radius.circular(AppBorderRadius.medium),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, size: 20, color: AppColors.info),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Bộ lọc', style: AppTextStyles.headline3.copyWith(color: AppColors.info)),
                ],
              ),
              TextButton(
                onPressed: widget.onClearAll,
                child: Text(
                  'Xóa tất cả',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Range Filter
                _buildExpandableFilterSection(
                  title: 'Thời gian',
                  icon: Icons.calendar_today,
                  isExpanded: _isTimeExpanded,
                  onToggle: () {
                    final newValue = !_isTimeExpanded;
                    setState(() => _isTimeExpanded = newValue);
                    _saveExpandState('filter_time_expanded', newValue);
                  },
                  child: Column(
                    children: [
                      _buildFilterOption(
                        title: 'Hôm nay',
                        selected: _localFilter.timeRange == 'today',
                        onTap: () {
                          setState(() {
                            _localFilter = _localFilter.copyWith(
                              timeRange: 'today',
                              startDate: DateTime.now(),
                              endDate: DateTime.now(),
                            );
                          });
                        },
                      ),
                      _buildFilterOption(
                        title: '3 ngày qua',
                        selected: _localFilter.timeRange == '3days',
                        onTap: () {
                          setState(() {
                            _localFilter = _localFilter.copyWith(
                              timeRange: '3days',
                              startDate: DateTime.now().subtract(const Duration(days: 3)),
                              endDate: DateTime.now(),
                            );
                          });
                        },
                      ),
                      _buildFilterOption(
                        title: '7 ngày qua',
                        selected: _localFilter.timeRange == '7days',
                        onTap: () {
                          setState(() {
                            _localFilter = _localFilter.copyWith(
                              timeRange: '7days',
                              startDate: DateTime.now().subtract(const Duration(days: 7)),
                              endDate: DateTime.now(),
                            );
                          });
                        },
                      ),
                      // _buildFilterOption(
                      //   title: '30 ngày qua',
                      //   selected: _localFilter.timeRange == '30days',
                      //   onTap: () {
                      //     setState(() {
                      //       _localFilter = _localFilter.copyWith(
                      //         timeRange: '30days',
                      //         startDate: DateTime.now().subtract(const Duration(days: 30)),
                      //         endDate: DateTime.now(),
                      //       );
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Compare Type Filter
                _buildExpandableFilterSection(
                  title: 'Loại so sánh',
                  icon: Icons.compare_arrows,
                  isExpanded: _isCompareTypeExpanded,
                  onToggle: () {
                    final newValue = !_isCompareTypeExpanded;
                    setState(() => _isCompareTypeExpanded = newValue);
                    _saveExpandState('filter_compareType_expanded', newValue);
                  },
                  child: _availableCompareTypes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(
                            'Đang tải...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Column(
                          children: _availableCompareTypes.map((compareType) {
                            return _buildFilterOption(
                              title: compareType.name,
                              selected: _localFilter.compareTypeCode == compareType.code,
                              onTap: () {
                                setState(() {
                                  _localFilter = _localFilter.copyWith(
                                    compareTypeCode:
                                        _localFilter.compareTypeCode == compareType.code
                                        ? null
                                        : compareType.code,
                                    clearCompareType:
                                        _localFilter.compareTypeCode == compareType.code,
                                  );
                                });
                              },
                            );
                          }).toList(),
                        ),
                ),

                const Divider(height: 1),

                // Area Filter
                _buildExpandableFilterSection(
                  title: 'Khu vực',
                  icon: Icons.location_on,
                  isExpanded: _isAreaExpanded,
                  onToggle: () {
                    final newValue = !_isAreaExpanded;
                    setState(() => _isAreaExpanded = newValue);
                    _saveExpandState('filter_area_expanded', newValue);
                  },
                  child: _availableAreas.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(
                            'Đang tải...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFilterOption(
                              title: 'Tất cả khu vực',
                              selected: _localFilter.areaName == null,
                              onTap: () {
                                setState(() {
                                  _localFilter = _localFilter.copyWith(clearArea: true);
                                });
                              },
                            ),
                            ..._availableAreas.map((area) {
                              return _buildFilterOption(
                                title: area,
                                selected: _localFilter.areaName == area,
                                onTap: () {
                                  setState(() {
                                    _localFilter = _localFilter.copyWith(
                                      areaName: _localFilter.areaName == area ? null : area,
                                      clearArea: _localFilter.areaName == area,
                                    );
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                ),

                const Divider(height: 1),

                // Status Filter
                _buildExpandableFilterSection(
                  title: 'Trạng thái',
                  icon: Icons.check_circle_outline,
                  isExpanded: _isStatusExpanded,
                  onToggle: () {
                    final newValue = !_isStatusExpanded;
                    setState(() => _isStatusExpanded = newValue);
                    _saveExpandState('filter_status_expanded', newValue);
                  },
                  child: Column(
                    children: _fixedStatuses.map((status) {
                      return _buildFilterOption(
                        title: status.name,
                        selected: _localFilter.statusCode == status.code,
                        onTap: () {
                          setState(() {
                            _localFilter = _localFilter.copyWith(
                              statusCode: _localFilter.statusCode == status.code
                                  ? null
                                  : status.code,
                              clearStatus: _localFilter.statusCode == status.code,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Apply Button - Always visible at bottom
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppBorderRadius.medium),
              bottomRight: Radius.circular(AppBorderRadius.medium),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_localFilter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                elevation: 2,
              ),
              child: const Text('Áp dụng'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.info),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      child,
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.info.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: selected ? AppColors.info : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.info : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.check_circle, size: 18, color: AppColors.info),
            ],
          ],
        ),
      ),
    );
  }
}
