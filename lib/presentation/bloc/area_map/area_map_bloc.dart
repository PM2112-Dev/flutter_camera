import 'package:bloc/bloc.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/usecase/area/get_area_map_use_case.dart';
import 'package:injectable/injectable.dart';
import 'area_map_event.dart';
import 'area_map_state.dart';

@injectable
class AreaMapBloc extends Bloc<AreaMapEvent, AreaMapState> {
  final GetAreaMapUseCase _getAreaMapUseCase;

  AreaMapBloc(this._getAreaMapUseCase) : super(const AreaMapInitial()) {
    on<FetchAreaMapData>(_onFetchAreaMapData);
    on<RefreshAreaMapData>(_onRefreshAreaMapData);
  }

  Future<void> _onFetchAreaMapData(FetchAreaMapData event, Emitter<AreaMapState> emit) async {
    emit(const AreaMapLoading(message: 'Đang tải dữ liệu bản đồ...'));

    final result = await _getAreaMapUseCase.call();

    result.fold(
      (failure) {
        print('❌ AreaMapBloc - Error: ${failure.message}');
        emit(
          AreaMapError(
            message: failure.message,
            code: failure is ServerFailure ? failure.code : null,
          ),
        );
      },
      (data) {
        print('✅ AreaMapBloc - Loaded ${data.areas.length} areas');
        emit(AreaMapLoaded(data: data, message: 'Đã tải ${data.areas.length} khu vực'));
      },
    );
  }

  Future<void> _onRefreshAreaMapData(RefreshAreaMapData event, Emitter<AreaMapState> emit) async {
    // Don't show loading for refresh
    final result = await _getAreaMapUseCase.call();

    result.fold(
      (failure) {
        print('❌ AreaMapBloc - Refresh Error: ${failure.message}');
        // Keep current state on refresh error
        if (state is! AreaMapLoaded) {
          emit(
            AreaMapError(
              message: failure.message,
              code: failure is ServerFailure ? failure.code : null,
            ),
          );
        }
      },
      (data) {
        print('✅ AreaMapBloc - Refreshed ${data.areas.length} areas');
        emit(AreaMapLoaded(data: data, message: 'Đã làm mới dữ liệu'));
      },
    );
  }
}
