import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_camera/data/local/preference/pin_camera_preference.dart';
import 'package:flutter_camera/data/local/preference/selected_cameras_preference.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize injectable dependencies
  await getIt.init();
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  @lazySingleton
  PinCameraPreference pinCameraPreference(SharedPreferences prefs) =>
      PinCameraPreference(prefs);

  @lazySingleton
  SelectedCamerasPreference selectedCamerasPreference(
    SharedPreferences prefs,
  ) => SelectedCamerasPreference(prefs);
}
