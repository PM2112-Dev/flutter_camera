class CameraFilter {
  final String? selectedArea;
  final String? deviceStatus; // 'On', 'Off', null (all)
  final String? searchKeyword;

  const CameraFilter({
    this.selectedArea,
    this.deviceStatus,
    this.searchKeyword,
  });

  CameraFilter copyWith({
    String? selectedArea,
    String? deviceStatus,
    String? searchKeyword,
  }) {
    return CameraFilter(
      selectedArea: selectedArea ?? this.selectedArea,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  bool get hasActiveFilter =>
      selectedArea != null ||
      deviceStatus != null ||
      (searchKeyword != null && searchKeyword!.isNotEmpty);

  static const CameraFilter empty = CameraFilter();
}
