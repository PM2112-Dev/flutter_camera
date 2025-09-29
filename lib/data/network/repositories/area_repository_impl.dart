import 'package:dartz/dartz.dart';
import 'package:flutter_camera/data/local/preference/auth_local_preference.dart';
import 'package:flutter_camera/data/network/api/area_api_service.dart';
import 'package:flutter_camera/data/network/model/area_tree_model.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/model/area_tree.dart';
import 'package:flutter_camera/domain/repositories/area_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AreaRepository)
class AreaRepositoryImpl implements AreaRepository {
  final AreaApiService _apiService;
  final AuthLocalPreference _localStorage;

  AreaRepositoryImpl(this._apiService, this._localStorage);

  @override
  Future<Either<Failure, List<AreaTreeWithCameras>>> getAreaAllTree() async {
    try {
      // Get access token from local storage
      final tokens = _localStorage.getTokens();
      final accessToken = tokens?.accessToken;

      final response = await _apiService.getAreaAllTree(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final areaTrees = response.data!.map((model) {
            try {
              return model.toEntity();
            } catch (e) {
              print('Error converting model to entity: $e');
              rethrow;
            }
          }).toList();
          return Right(areaTrees);
        } catch (e) {
          return Left(ServerFailure(message: 'Error processing data: $e'));
        }
      } else {
        return Left(
          ServerFailure(message: response.message ?? 'Failed to get area tree'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
