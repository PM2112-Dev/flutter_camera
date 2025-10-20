import 'package:flutter_camera/presentation/ui/home/pages/home_page.dart';
import 'package:flutter_camera/presentation/ui/login/page/login_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String onvifCamera = '/onvif-camera';

  static const String notification = '/notification';
  static const String notificationDetail = '/notification-detail';
  static const String notificationList = '/notification-list';
  static const String go2rtcStream = '/go2rtc-stream';
  static const String exoplayerDemo = '/exoplayer-demo';
}

final routes = {
  AppRoutes.login: (_) => const LoginPage(),
  AppRoutes.home: (_) => const HomePage(),
  // OnvifCameraPage requires parameters, handle in MaterialApp.onGenerateRoute
  // AppRoutes.notification: (_) => const NotificationPage(),
  // AppRoutes.notificationList: (_) => const NotificationListPage(),
  // NotificationDetailPage requires parameters, handle in MaterialApp.onGenerateRoute
  // OnvifCameraPage requires Camera argument, handle in MaterialApp.onGenerateRoute
};
