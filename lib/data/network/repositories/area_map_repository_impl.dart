import 'package:dartz/dartz.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/area_map_api_service.dart';
import 'package:flutter_camera/data/network/model/area_map_model.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_map.dart';
import 'package:flutter_camera/domain/repositories/area_map_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AreaMapRepository)
class AreaMapRepositoryImpl implements AreaMapRepository {
  final AreaMapApiService _apiService;
  final AuthLocalPreference _localStorage;

  AreaMapRepositoryImpl(this._apiService, this._localStorage);

  @override
  Future<Either<Failure, AreaMapResponse>> getMachinesAndResultByArea() async {
    try {
      // Get access token from local storage
      final tokens = _localStorage.getTokens();
      final accessToken = tokens?.accessToken;

      final response = await _apiService.getMachinesAndResultByArea(accessToken: accessToken);

      if (response.isSuccess && response.data != null) {
        try {
          final areaMapResponse = response.data!.toEntity();
          return Right(areaMapResponse);
        } catch (e) {
          print('Error converting model to entity: $e');
          return Left(ServerFailure(message: 'Error processing data: $e'));
        }
      } else {
        return Left(ServerFailure(message: response.message ?? 'Failed to get area map data'));
      }
    } catch (e) {
      print('Repository error: $e');
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
