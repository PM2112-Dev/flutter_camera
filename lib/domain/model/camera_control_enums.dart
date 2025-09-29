enum CameraControlCommand {
  /// PTZ commands
  up(1, 'Move Up'),
  down(2, 'Move Down'),
  left(3, 'Move Left'),
  right(4, 'Move Right'),
  upLeft(5, 'Move Up-Left'),
  upRight(6, 'Move Up-Right'),
  downLeft(7, 'Move Down-Left'),
  downRight(8, 'Move Down-Right'),

  /// Zoom commands
  zoomIn(9, 'Zoom In'),
  zoomOut(10, 'Zoom Out'),

  /// Preset commands
  setPreset1(11, 'Set Preset 1'),
  setPreset2(12, 'Set Preset 2'),
  setPreset3(13, 'Set Preset 3'),
  gotoPreset1(14, 'Go to Preset 1'),
  gotoPreset2(15, 'Go to Preset 2'),
  gotoPreset3(16, 'Go to Preset 3'),

  /// Additional controls
  stop(0, 'Stop'),
  home(17, 'Go Home'),
  autoPan(18, 'Auto Pan'),
  autoScan(19, 'Auto Scan');

  const CameraControlCommand(this.value, this.description);

  final int value;
  final String description;

  static CameraControlCommand fromValue(int value) {
    return CameraControlCommand.values.firstWhere(
      (command) => command.value == value,
      orElse: () => CameraControlCommand.stop,
    );
  }
}

enum CameraControlSpeed {
  stop(0, 'Stop'),
  verySlow(10, 'Very Slow'),
  slow(20, 'Slow'),
  medium(30, 'Medium'),
  fast(45, 'Fast'),
  veryFast(55, 'Very Fast'),
  maximum(63, 'Maximum');

  const CameraControlSpeed(this.value, this.description);

  final int value;
  final String description;

  static CameraControlSpeed fromValue(int value) {
    return CameraControlSpeed.values.firstWhere(
      (speed) => speed.value == value,
      orElse: () => CameraControlSpeed.medium,
    );
  }

  /// Get speed from range 0-63
  static CameraControlSpeed fromRange(int value) {
    final clampedValue = value.clamp(0, 63);
    if (clampedValue == 0) return CameraControlSpeed.stop;
    if (clampedValue <= 15) return CameraControlSpeed.verySlow;
    if (clampedValue <= 25) return CameraControlSpeed.slow;
    if (clampedValue <= 40) return CameraControlSpeed.medium;
    if (clampedValue <= 50) return CameraControlSpeed.fast;
    if (clampedValue <= 60) return CameraControlSpeed.veryFast;
    return CameraControlSpeed.maximum;
  }

  /// Check if value is in valid range (0-63)
  static bool isValidRange(int value) {
    return value >= 0 && value <= 63;
  }
}
