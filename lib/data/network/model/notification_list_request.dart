class NotificationListRequest {
  final String? fromTime;
  final String? toTime;
  final int page;
  final int pageSize;

  NotificationListRequest({
    this.fromTime,
    this.toTime,
    this.page = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (fromTime != null) 'fromTime': fromTime,
      if (toTime != null) 'toTime': toTime,
      'page': page,
      'pageSize': pageSize,
    }..removeWhere((key, value) => value == null);
  }
}
