import 'package:flutter/material.dart';
import 'package:flutter_camera/domain/model/stream_server_config.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class StreamServerConfigWidget extends StatefulWidget {
  final Function(StreamServerConfig) onSave;
  final StreamServerConfig? initialConfig;

  const StreamServerConfigWidget({
    super.key,
    required this.onSave,
    this.initialConfig,
  });

  @override
  State<StreamServerConfigWidget> createState() => _StreamServerConfigWidgetState();
}

class _StreamServerConfigWidgetState extends State<StreamServerConfigWidget> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _baseUrlController.text = widget.initialConfig!.baseUrl;
      _portController.text = widget.initialConfig!.port.toString();
    } else {
      // Default values
      _baseUrlController.text = 'thermal.mtktech.com.vn';
      _portController.text = '1984';
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final config = StreamServerConfig(
        baseUrl: _baseUrlController.text.trim(),
        port: int.parse(_portController.text.trim()),
      );
      widget.onSave(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stream, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Stream Server Configuration',
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure the stream server for video playback',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Base URL Field
            TextFormField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                hintText: 'thermal.mtktech.com.vn',
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter base URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Port Field
            TextFormField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: '1984',
                prefixIcon: const Icon(Icons.settings_ethernet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter port number';
                }
                final port = int.tryParse(value.trim());
                if (port == null || port < 1 || port > 65535) {
                  return 'Please enter a valid port number (1-65535)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Preview URL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview URL:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'http://${_baseUrlController.text}:${_portController.text}/api/stream.m3u8',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                  'Save Stream Server Configuration',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
