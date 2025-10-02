import 'package:flutter/material.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/domain/model/server_config.dart';
import 'package:flutter_camera/domain/model/stream_server_config.dart';
import 'package:flutter_camera/presentation/ui/shared/widgets/combined_config_widget.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/di/injection.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AuthLocalPreference _authPreference;
  ServerConfig? _currentConfig;
  StreamServerConfig? _currentStreamConfig;

  @override
  void initState() {
    super.initState();
    _authPreference = getIt<AuthLocalPreference>();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final baseUrl = _authPreference.getBaseUrl();
    final port = _authPreference.getPort();

    if (baseUrl != null && port != null) {
      setState(() {
        _currentConfig = ServerConfig(baseUrl: baseUrl, port: port);
      });
    }

    final streamBaseUrl = _authPreference.getStreamBaseUrl();
    final streamPort = _authPreference.getStreamPort();

    if (streamBaseUrl != null && streamPort != null) {
      setState(() {
        _currentStreamConfig = StreamServerConfig(baseUrl: streamBaseUrl, port: streamPort);
      });
    }
  }

  Future<void> _saveCombinedConfig(
    ServerConfig serverConfig,
    StreamServerConfig streamConfig,
  ) async {
    try {
      await _authPreference.saveServerConfigWithNormalization(
        baseUrl: serverConfig.baseUrl,
        port: serverConfig.port,
      );
      await _authPreference.saveStreamServerConfigWithNormalization(
        baseUrl: streamConfig.baseUrl,
        port: streamConfig.port,
      );

      setState(() {
        _currentConfig = serverConfig;
        _currentStreamConfig = streamConfig;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cấu hình server đã được lưu thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu cấu hình: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Combined Configuration Widget
            CombinedConfigWidget(
              onSave: _saveCombinedConfig,
              initialServerConfig: _currentConfig,
              initialStreamConfig: _currentStreamConfig,
            ),
          ],
        ),
      ),
    );
  }
}
