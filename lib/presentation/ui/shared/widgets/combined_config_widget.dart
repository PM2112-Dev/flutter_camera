import 'package:flutter/material.dart';
import 'package:flutter_camera/domain/model/server_config.dart';
import 'package:flutter_camera/domain/model/stream_server_config.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class CombinedConfigWidget extends StatefulWidget {
  final Function(ServerConfig, StreamServerConfig) onSave;
  final ServerConfig? initialServerConfig;
  final StreamServerConfig? initialStreamConfig;

  const CombinedConfigWidget({
    super.key,
    required this.onSave,
    this.initialServerConfig,
    this.initialStreamConfig,
  });

  @override
  State<CombinedConfigWidget> createState() => _CombinedConfigWidgetState();
}

class _CombinedConfigWidgetState extends State<CombinedConfigWidget> {
  final _formKey = GlobalKey<FormState>();

  // Server config controllers
  final _serverBaseUrlController = TextEditingController();
  final _serverPortController = TextEditingController();

  // Stream server config controllers
  final _streamBaseUrlController = TextEditingController();
  final _streamPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize server config
    if (widget.initialServerConfig != null) {
      _serverBaseUrlController.text = widget.initialServerConfig!.baseUrl;
      _serverPortController.text = widget.initialServerConfig!.port.toString();
    } else {
      _serverBaseUrlController.text = 'https://thermal.infosysvietnam.com.vn';
      _serverPortController.text = '10253';
    }

    // Initialize stream server config
    if (widget.initialStreamConfig != null) {
      _streamBaseUrlController.text = widget.initialStreamConfig!.baseUrl;
      _streamPortController.text = widget.initialStreamConfig!.port.toString();
    } else {
      _streamBaseUrlController.text = 'https://thermal.infosysvietnam.com.vn';
      _streamPortController.text = '1984';
    }
  }

  @override
  void dispose() {
    _serverBaseUrlController.dispose();
    _serverPortController.dispose();
    _streamBaseUrlController.dispose();
    _streamPortController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final serverConfig = ServerConfig(
        baseUrl: _serverBaseUrlController.text.trim(),
        port: int.parse(_serverPortController.text.trim()),
      );

      final streamConfig = StreamServerConfig(
        baseUrl: _streamBaseUrlController.text.trim(),
        port: int.parse(_streamPortController.text.trim()),
      );

      widget.onSave(serverConfig, streamConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API Server Configuration
          _buildListHeader('API Server Configuration', Icons.api),
          _buildTextField(
            controller: _serverBaseUrlController,
            label: 'Base URL',
            hint: 'https://thermal.infosysvietnam.com.vn',
            prefixIcon: Icons.language,
            isUrl: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _serverPortController,
            label: 'Port',
            hint: '10253',
            prefixIcon: Icons.settings_ethernet,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),

          // Stream Server Configuration
          _buildListHeader('Stream Server Configuration', Icons.stream),
          _buildTextField(
            controller: _streamBaseUrlController,
            label: 'Base URL',
            hint: 'https://thermal.infosysvietnam.com.vn',
            prefixIcon: Icons.language,
            isUrl: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _streamPortController,
            label: 'Port',
            hint: '1984',
            prefixIcon: Icons.settings_ethernet,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
              ),
              child: Text(
                'Lưu cấu hình',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool isUrl = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppBorderRadius.medium)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }

        if (isUrl) {
          // Basic URL validation
          final urlValue = value.trim();
          if (!urlValue.contains('.')) {
            return 'Please enter a valid URL';
          }
          // Check if it has protocol, if not that's ok (will be added automatically)
          if (urlValue.startsWith('http://') || urlValue.startsWith('https://')) {
            try {
              Uri.parse(urlValue);
            } catch (e) {
              return 'Please enter a valid URL format';
            }
          }
        } else if (keyboardType == TextInputType.number) {
          final port = int.tryParse(value.trim());
          if (port == null || port < 1 || port > 65535) {
            return 'Please enter a valid port number (1-65535)';
          }
        }
        return null;
      },
    );
  }
}
