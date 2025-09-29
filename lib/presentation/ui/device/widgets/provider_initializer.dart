import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera/presentation/ui/device/providers/camera_selection_provider.dart';

class ProviderInitializer extends StatefulWidget {
  final Widget child;

  const ProviderInitializer({super.key, required this.child});

  @override
  State<ProviderInitializer> createState() => _ProviderInitializerState();
}

class _ProviderInitializerState extends State<ProviderInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() async {
    try {
      if (mounted && !_isInitialized) {
        final selectionProvider = context.read<CameraSelectionProvider>();
        await selectionProvider.initialize();
        setState(() {
          _isInitialized = true;
        });
        debugPrint('ProviderInitializer: Providers initialized');
      }
    } catch (e) {
      debugPrint('ProviderInitializer: Failed to initialize providers: $e');
      // If GetIt fails, try again after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _initializeProviders();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraSelectionProvider>(
      builder: (context, selectionProvider, child) {
        // This ensures the provider is available and initialized
        return widget.child;
      },
    );
  }
}
