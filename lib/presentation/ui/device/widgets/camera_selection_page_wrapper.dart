import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';
import 'package:flutter_camera/presentation/ui/device/pages/camera_selection_page.dart';

class CameraSelectionPageWrapper extends StatelessWidget {
  final CameraSelectionProvider cameraSelectionProvider;

  const CameraSelectionPageWrapper({super.key, required this.cameraSelectionProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CameraSelectionProvider>.value(
      value: cameraSelectionProvider,
      child: const CameraSelectionPage(),
    );
  }
}
