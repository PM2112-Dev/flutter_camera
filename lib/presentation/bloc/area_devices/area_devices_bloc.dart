import 'package:bloc/bloc.dart';
import 'package:flutter_camera/domain/failures/failures.dart';
import 'package:flutter_camera/domain/usecase/area/get_area_devices_use_case.dart';
import 'package:injectable/injectable.dart';
import 'area_devices_event.dart';
import 'area_devices_state.dart';

@injectable
class AreaDevicesBloc extends Bloc<AreaDevicesEvent, AreaDevicesState> {
  final GetAreaDevicesUseCase _getAreaDevicesUseCase;

  AreaDevicesBloc(this._getAreaDevicesUseCase) : super(const AreaDevicesInitial()) {
    on<FetchAreaDevices>(_onFetchAreaDevices);
    on<RefreshAreaDevices>(_onRefreshAreaDevices);
  }

  Future<void> _onFetchAreaDevices(FetchAreaDevices event, Emitter<AreaDevicesState> emit) async {
    emit(const AreaDevicesLoading(message: 'Đang tải thiết bị...'));

    final result = await _getAreaDevicesUseCase.call(event.areaId);

    result.fold(
      (failure) {
        print('❌ AreaDevicesBloc - Error: ${failure.message}');
        emit(
          AreaDevicesError(
            message: failure.message,
            code: failure is ServerFailure ? failure.code : null,
          ),
        );
      },
      (data) {
        print('✅ AreaDevicesBloc - Loaded ${data.devices.length} devices for area ${event.areaId}');
        emit(
          AreaDevicesLoaded(
            devices: data.devices,
            message: 'Đã tải ${data.devices.length} thiết bị',
          ),
        );
      },
    );
  }

  Future<void> _onRefreshAreaDevices(
    RefreshAreaDevices event,
    Emitter<AreaDevicesState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await _getAreaDevicesUseCase.call(event.areaId);

    result.fold(
      (failure) {
        print('❌ AreaDevicesBloc - Refresh Error: ${failure.message}');
        // Keep current state on refresh error
        if (state is! AreaDevicesLoaded) {
          emit(
            AreaDevicesError(
              message: failure.message,
              code: failure is ServerFailure ? failure.code : null,
            ),
          );
        }
      },
      (data) {
        print(
          '✅ AreaDevicesBloc - Refreshed ${data.devices.length} devices for area ${event.areaId}',
        );
        emit(AreaDevicesLoaded(devices: data.devices, message: 'Đã làm mới dữ liệu'));
      },
    );
  }
}
