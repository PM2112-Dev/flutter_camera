// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart'
    as _i183;
import 'package:flutter_camera/data/local/preference/notification_preference.dart'
    as _i1024;
import 'package:flutter_camera/data/local/preference/pin_camera_preference.dart'
    as _i437;
import 'package:flutter_camera/data/local/preference/selected_cameras_preference.dart'
    as _i547;
import 'package:flutter_camera/data/network/api/area_api_service.dart' as _i990;
import 'package:flutter_camera/data/network/api/auth_api_service.dart' as _i531;
import 'package:flutter_camera/data/network/api/camera_control_api_service.dart'
    as _i951;
import 'package:flutter_camera/data/network/api/camera_stream_api_service.dart'
    as _i174;
import 'package:flutter_camera/data/network/api/notification_api_service.dart'
    as _i678;
import 'package:flutter_camera/data/network/api/user_token_api_service.dart'
    as _i1045;
import 'package:flutter_camera/data/network/api/vision_notification_api_service.dart'
    as _i827;
import 'package:flutter_camera/data/network/repositories/area_repository_impl.dart'
    as _i964;
import 'package:flutter_camera/data/network/repositories/auth_repository_impl.dart'
    as _i162;
import 'package:flutter_camera/data/network/repositories/camera_control_repository_impl.dart'
    as _i565;
import 'package:flutter_camera/data/network/repositories/camera_stream_repository_impl.dart'
    as _i299;
import 'package:flutter_camera/data/network/repositories/notification_repository_impl.dart'
    as _i761;
import 'package:flutter_camera/data/network/repositories/vision_notifications_repository_impl.dart'
    as _i952;
import 'package:flutter_camera/data/services/firebase_messaging_service.dart'
    as _i935;
import 'package:flutter_camera/data/services/screenshot_service.dart' as _i170;
import 'package:flutter_camera/data/services/stream_server_service.dart'
    as _i793;
import 'package:flutter_camera/di/injection.dart' as _i995;
import 'package:flutter_camera/domain/repositories/area_repository.dart'
    as _i170;
import 'package:flutter_camera/domain/repositories/auth_repository.dart'
    as _i88;
import 'package:flutter_camera/domain/repositories/camera_control_repository.dart'
    as _i773;
import 'package:flutter_camera/domain/repositories/camera_stream_repository.dart'
    as _i39;
import 'package:flutter_camera/domain/repositories/notifications_repository.dart'
    as _i819;
import 'package:flutter_camera/domain/repositories/vision_notifications_repository.dart'
    as _i983;
import 'package:flutter_camera/domain/usecase/area/get_all_tree_use_case.dart'
    as _i203;
import 'package:flutter_camera/domain/usecase/auth/check_auth_status_usecase.dart'
    as _i1064;
import 'package:flutter_camera/domain/usecase/auth/get_profile_use_case.dart'
    as _i315;
import 'package:flutter_camera/domain/usecase/auth/get_stored_tokens_usecase.dart'
    as _i392;
import 'package:flutter_camera/domain/usecase/auth/login_use_case.dart'
    as _i597;
import 'package:flutter_camera/domain/usecase/auth/logout_use_case.dart'
    as _i597;
import 'package:flutter_camera/domain/usecase/auth/refresh_token_use_case.dart'
    as _i833;
import 'package:flutter_camera/domain/usecase/camera_control/camera_control_usecase.dart'
    as _i1006;
import 'package:flutter_camera/domain/usecase/get_camera_stream_usecase.dart'
    as _i499;
import 'package:flutter_camera/domain/usecase/notification/get_notification_detail_use_case.dart'
    as _i999;
import 'package:flutter_camera/domain/usecase/notification/get_notifications_use_case.dart'
    as _i362;
import 'package:flutter_camera/domain/usecase/vision_notification/get_vision_notifications_use_case.dart'
    as _i527;
import 'package:flutter_camera/presentation/bloc/auth/auth_bloc.dart' as _i649;
import 'package:flutter_camera/presentation/bloc/camera_control/camera_control_bloc.dart'
    as _i470;
import 'package:flutter_camera/presentation/bloc/camera_stream/camera_stream_bloc.dart'
    as _i295;
import 'package:flutter_camera/presentation/ui/device/bloc/device_bloc.dart'
    as _i840;
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_bloc.dart'
    as _i150;
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_count_bloc.dart'
    as _i310;
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_detail_bloc.dart'
    as _i44;
import 'package:flutter_camera/presentation/ui/notification/bloc/notification_list_bloc.dart'
    as _i843;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i170.ScreenshotService>(() => _i170.ScreenshotService());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i437.PinCameraPreference>(
      () => registerModule.pinCameraPreference(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i547.SelectedCamerasPreference>(
      () => registerModule.selectedCamerasPreference(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i183.AuthLocalPreference>(
      () => _i183.AuthLocalPreference(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i1024.NotificationPreference>(
      () => _i1024.NotificationPreference(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i793.StreamServerService>(
      () => _i793.StreamServerService(gh<_i183.AuthLocalPreference>()),
    );
    gh.factory<_i990.AreaApiService>(
      () => _i990.AreaApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i1045.UserTokenApiService>(
      () => _i1045.UserTokenApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i678.NotificationApiService>(
      () => _i678.NotificationApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i827.VisionNotificationApiService>(
      () => _i827.VisionNotificationApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i983.VisionNotificationsRepository>(
      () => _i952.VisionNotificationsRepositoryImpl(
        gh<_i827.VisionNotificationApiService>(),
      ),
    );
    gh.factory<_i951.CameraControlApiService>(
      () => _i951.CameraControlApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i531.AuthApiService>(
      () => _i531.AuthApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i174.CameraStreamApiService>(
      () => _i174.CameraStreamApiService(
        gh<_i361.Dio>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.lazySingleton<_i773.CameraControlRepository>(
      () => _i565.CameraControlRepositoryImpl(
        gh<_i951.CameraControlApiService>(),
      ),
    );
    gh.factory<_i819.NotificationsRepository>(
      () =>
          _i761.NotificationsRepositoryImpl(gh<_i678.NotificationApiService>()),
    );
    gh.factory<_i527.GetVisionNotificationsUseCase>(
      () => _i527.GetVisionNotificationsUseCase(
        gh<_i983.VisionNotificationsRepository>(),
      ),
    );
    gh.factory<_i170.AreaRepository>(
      () => _i964.AreaRepositoryImpl(
        gh<_i990.AreaApiService>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.singleton<_i935.FirebaseMessagingService>(
      () => _i935.FirebaseMessagingService(
        gh<_i1045.UserTokenApiService>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i1006.CameraControlUseCase>(
      () => _i1006.CameraControlUseCase(gh<_i773.CameraControlRepository>()),
    );
    gh.factory<_i39.CameraStreamRepository>(
      () =>
          _i299.CameraStreamRepositoryImpl(gh<_i174.CameraStreamApiService>()),
    );
    gh.factory<_i999.GetNotificationDetailUseCase>(
      () => _i999.GetNotificationDetailUseCase(
        gh<_i819.NotificationsRepository>(),
      ),
    );
    gh.factory<_i362.GetNotificationsUseCase>(
      () => _i362.GetNotificationsUseCase(gh<_i819.NotificationsRepository>()),
    );
    gh.lazySingleton<_i88.AuthRepository>(
      () => _i162.AuthRepositoryImpl(
        gh<_i531.AuthApiService>(),
        gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i597.LogoutUseCase>(
      () => _i597.LogoutUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i833.RefreshTokenUseCase>(
      () => _i833.RefreshTokenUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i597.LoginUseCase>(
      () => _i597.LoginUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i315.GetProfileUseCase>(
      () => _i315.GetProfileUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i470.CameraControlBloc>(
      () => _i470.CameraControlBloc(gh<_i1006.CameraControlUseCase>()),
    );
    gh.factory<_i499.GetCameraStreamUsecase>(
      () => _i499.GetCameraStreamUsecase(gh<_i39.CameraStreamRepository>()),
    );
    gh.factory<_i44.NotificationDetailBloc>(
      () => _i44.NotificationDetailBloc(
        getNotificationDetailUseCase: gh<_i999.GetNotificationDetailUseCase>(),
        authLocalPreference: gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i392.GetStoredTokensUseCase>(
      () => _i392.GetStoredTokensUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i1064.CheckAuthStatusUseCase>(
      () => _i1064.CheckAuthStatusUseCase(gh<_i88.AuthRepository>()),
    );
    gh.factory<_i150.NotificationBloc>(
      () => _i150.NotificationBloc(
        getNotificationsUseCase: gh<_i527.GetVisionNotificationsUseCase>(),
      ),
    );
    gh.factory<_i295.CameraStreamBloc>(
      () => _i295.CameraStreamBloc(gh<_i499.GetCameraStreamUsecase>()),
    );
    gh.factory<_i203.GetAllTreeUseCase>(
      () => _i203.GetAllTreeUseCase(gh<_i170.AreaRepository>()),
    );
    gh.factory<_i310.NotificationCountBloc>(
      () => _i310.NotificationCountBloc(
        getNotificationsUseCase: gh<_i362.GetNotificationsUseCase>(),
        authLocalPreference: gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i843.NotificationListBloc>(
      () => _i843.NotificationListBloc(
        getNotificationsUseCase: gh<_i362.GetNotificationsUseCase>(),
        authLocalPreference: gh<_i183.AuthLocalPreference>(),
      ),
    );
    gh.factory<_i649.AuthBloc>(
      () => _i649.AuthBloc(
        gh<_i597.LoginUseCase>(),
        gh<_i597.LogoutUseCase>(),
        gh<_i315.GetProfileUseCase>(),
        gh<_i392.GetStoredTokensUseCase>(),
        gh<_i935.FirebaseMessagingService>(),
      ),
    );
    gh.factory<_i840.DeviceBloc>(
      () => _i840.DeviceBloc(gh<_i203.GetAllTreeUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i995.RegisterModule {}
