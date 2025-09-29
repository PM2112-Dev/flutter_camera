import 'package:flutter_camera/data/network/model/notification_detail_response.dart';
import 'package:flutter_camera/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetNotificationDetailUseCase {
  final NotificationsRepository repository;
  GetNotificationDetailUseCase(this.repository);

  Future<NotificationDetailResponse?> call({
    required String id,
    required String dataTime,
    required String token,
  }) {
    return repository.getNotificationDetail(
      id: id,
      dataTime: dataTime,
      token: token,
    );
  }
}
