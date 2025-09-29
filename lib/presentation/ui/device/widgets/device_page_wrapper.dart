import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_stream_data_provider.dart';
import 'package:flutter_camera/presentation/ui/device/pages/device_page.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/provider_initializer.dart';

class DevicePageWrapper extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const DevicePageWrapper({super.key, this.onRefreshCallback});

  @override
  State<DevicePageWrapper> createState() => _DevicePageWrapperState();
}

class _DevicePageWrapperState extends State<DevicePageWrapper> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CameraSelectionProvider is now provided by HomePage
        ChangeNotifierProvider(create: (_) => CameraStreamDataProvider()),
      ],
      child: ProviderInitializer(child: DevicePage(onRefreshCallback: widget.onRefreshCallback)),
    );
  }
}
