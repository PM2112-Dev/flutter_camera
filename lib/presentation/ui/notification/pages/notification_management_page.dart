import 'package:flutter/material.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/data/local/preference/notification_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() => _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;

  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

  NotificationPreference? _notificationPreference;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationPreference = NotificationPreference(prefs);

      setState(() {
        _notificationsEnabled = _notificationPreference!.notificationsEnabled;
        _soundEnabled = _notificationPreference!.soundEnabled;
        _vibrationEnabled = _notificationPreference!.vibrationEnabled;
        _quietHoursEnabled = _notificationPreference!.quietHoursEnabled;
        _quietStartTime = TimeOfDay(
          hour: _notificationPreference!.quietStartHour,
          minute: _notificationPreference!.quietStartMinute,
        );
        _quietEndTime = TimeOfDay(
          hour: _notificationPreference!.quietEndHour,
          minute: _notificationPreference!.quietEndMinute,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notification settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_notificationPreference == null) return;

    try {
      await _notificationPreference!.setNotificationsEnabled(_notificationsEnabled);
      await _notificationPreference!.setSoundEnabled(_soundEnabled);
      await _notificationPreference!.setVibrationEnabled(_vibrationEnabled);
      await _notificationPreference!.setQuietHoursEnabled(_quietHoursEnabled);
      await _notificationPreference!.setQuietStartTime(
        _quietStartTime.hour,
        _quietStartTime.minute,
      );
      await _notificationPreference!.setQuietEndTime(_quietEndTime.hour, _quietEndTime.minute);

      print('✅ Notification settings saved successfully');
    } catch (e) {
      print('❌ Error saving notification settings: $e');
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietStartTime : _quietEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietStartTime = picked;
        } else {
          _quietEndTime = picked;
        }
      });
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: AppElevations.level2,
          centerTitle: true,
          title: Text(
            'Quản lý thông báo',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: AppWidgets.buildLoadingIndicator(message: 'Đang tải cài đặt...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: AppElevations.level2,
        centerTitle: true,
        title: Text(
          'Quản lý thông báo',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
            border: Border.all(color: AppColors.textOnPrimary.withOpacity(0.2), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Enable/Disable Notifications Section
          _buildSection(
            title: 'Bật/Tắt thông báo',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile(
                title: 'Nhận thông báo',
                subtitle: 'Bật/tắt tất cả thông báo từ ứng dụng',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSettings();
                },
                icon: _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? AppColors.success : AppColors.error,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Sound & Vibration Section (only shown when notifications are enabled)
          if (_notificationsEnabled) ...[
            _buildSection(
              title: 'Âm thanh & Rung',
              icon: Icons.volume_up,
              children: [
                _buildSwitchTile(
                  title: 'Âm thanh thông báo',
                  subtitle: 'Phát âm thanh khi có thông báo mới',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                    _saveSettings();
                  },
                  icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: _soundEnabled ? AppColors.success : AppColors.textSecondary,
                ),
                _buildSwitchTile(
                  title: 'Rung thiết bị',
                  subtitle: 'Rung điện thoại khi có thông báo quan trọng',
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() => _vibrationEnabled = value);
                    _saveSettings();
                  },
                  icon: _vibrationEnabled ? Icons.vibration : Icons.mobile_off,
                  color: _vibrationEnabled ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quiet Hours Section
            _buildSection(
              title: 'Giờ im lặng',
              icon: Icons.bedtime,
              children: [
                _buildSwitchTile(
                  title: 'Bật giờ im lặng',
                  subtitle: 'Tắt thông báo trong khoảng thời gian nhất định',
                  value: _quietHoursEnabled,
                  onChanged: (value) {
                    setState(() => _quietHoursEnabled = value);
                    _saveSettings();
                  },
                  icon: _quietHoursEnabled ? Icons.bedtime : Icons.schedule,
                  color: _quietHoursEnabled ? AppColors.info : AppColors.textSecondary,
                ),

                if (_quietHoursEnabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thời gian im lặng',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(true),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Từ',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _quietStartTime.format(context),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(false),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đến',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _quietEndTime.format(context),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
