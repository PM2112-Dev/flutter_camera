import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/area_api_service.dart';
import 'package:flutter_camera/di/injection.dart';

Future<void> testApiCall() async {
  try {
    final areaApiService = getIt<AreaApiService>();
    final authPreference = getIt<AuthLocalPreference>();

    // Get tokens
    final tokens = authPreference.getTokens();
    final accessToken = tokens?.accessToken;

    print('=== Testing API Call ===');
    print('Access token: ${accessToken != null ? "present" : "null"}');

    // Call API
    final response = await areaApiService.getAreaAllTree(
      accessToken: accessToken,
    );

    print('Response success: ${response.isSuccess}');
    print('Response message: ${response.message}');
    print('Response data count: ${response.data?.length ?? 0}');

    if (response.data != null && response.data!.isNotEmpty) {
      final firstItem = response.data!.first;
      print('=== First Item Raw JSON ===');
      print('Name: ${firstItem.name}');
      print('Children count: ${firstItem.children.length}');
      print('Cameras count: ${firstItem.cameras.length}');

      print('=== First Item Full Data ===');
      print('Raw model toString: $firstItem');

      // Try to check children for cameras
      for (int i = 0; i < firstItem.children.length; i++) {
        final child = firstItem.children[i];
        print('Child $i - Name: ${child.name}');
        print('Child $i - Cameras: ${child.cameras.length}');
      }
    }
  } catch (e, stackTrace) {
    print('Error in test API call: $e');
    print('Stack trace: $stackTrace');
  }
}
