import 'package:dartz/dartz.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/area_devices_api_service.dart';
import 'package:flutter_camera/data/network/model/area_devices_model.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';
import 'package:flutter_camera/domain/repositories/area_devices_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AreaDevicesRepository)
class AreaDevicesRepositoryImpl implements AreaDevicesRepository {
  final AreaDevicesApiService _apiService;
  final AuthLocalPreference _localStorage;

  AreaDevicesRepositoryImpl(this._apiService, this._localStorage);

  @override
  Future<Either<Failure, AreaDevicesResponse>> getMachinesAndResultByArea(int areaId) async {
    try {
      // Get access token from local storage
      final tokens = _localStorage.getTokens();
      final accessToken = tokens?.accessToken;

      final response = await _apiService.getMachinesAndResultByArea(
        areaId: areaId,
        accessToken: accessToken,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final areaDevicesResponse = response.data!.toEntity();
          return Right(areaDevicesResponse);
        } catch (e) {
          print('Error converting model to entity: $e');
          return Left(ServerFailure(message: 'Error processing data: $e'));
        }
      } else {
        return Left(ServerFailure(message: response.message ?? 'Failed to get area devices data'));
      }
    } catch (e) {
      print('Repository error: $e');
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
