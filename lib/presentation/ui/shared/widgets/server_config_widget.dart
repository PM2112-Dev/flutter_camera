import 'package:flutter/material.dart';
import 'package:flutter_camera/domain/model/server_config.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class ServerConfigWidget extends StatefulWidget {
  final Function(ServerConfig) onSave;
  final ServerConfig? initialConfig;
  final bool showTitle;

  const ServerConfigWidget({
    super.key,
    required this.onSave,
    this.initialConfig,
    this.showTitle = true,
  });

  @override
  State<ServerConfigWidget> createState() => _ServerConfigWidgetState();
}

class _ServerConfigWidgetState extends State<ServerConfigWidget> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _portController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(
      text:
          widget.initialConfig?.baseUrl ??
          'http://thermal.infosysvietnam.com.vn',
    );
    _portController = TextEditingController(
      text: widget.initialConfig?.port.toString() ?? '10253',
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final baseUrl = _baseUrlController.text.trim();
      final port = int.parse(_portController.text.trim());

      final config = ServerConfig(baseUrl: baseUrl, port: port);

      widget.onSave(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTitle) ...[
                Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Server Configuration',
                      style: AppTextStyles.headline3.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Please enter the server URL and port to connect to the thermal camera system.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Base URL Field
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://thermal.infosysvietnam.com.vn',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter server URL';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
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
                  hintText: '10253',
                  prefixIcon: const Icon(Icons.router),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter port number';
                  }
                  final port = int.tryParse(value.trim());
                  if (port == null || port <= 0 || port > 65535) {
                    return 'Please enter a valid port number (1-65535)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveConfig,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Configuration'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.preview, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Preview: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_baseUrlController.text}:${_portController.text}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
