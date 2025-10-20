abstract class AreaMapEvent {
  const AreaMapEvent();
}

/// Fetch area map data
class FetchAreaMapData extends AreaMapEvent {
  const FetchAreaMapData();

  @override
  String toString() => 'FetchAreaMapData()';
}

/// Refresh area map data
class RefreshAreaMapData extends AreaMapEvent {
  const RefreshAreaMapData();

  @override
  String toString() => 'RefreshAreaMapData()';
}
