import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/domain/usecase/thermal/get_real_time_thermal_data_use_case.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_event.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class RealTimeThermalBloc extends Bloc<RealTimeThermalEvent, RealTimeThermalState> {
  final GetRealTimeThermalDataUseCase _getRealTimeThermalDataUseCase;

  RealTimeThermalBloc(this._getRealTimeThermalDataUseCase) : super(RealTimeThermalInitial()) {
    on<FetchRealTimeThermalData>(_onFetchRealTimeThermalData);
    on<RefreshRealTimeThermalData>(_onRefreshRealTimeThermalData);
  }

  Future<void> _onFetchRealTimeThermalData(
    FetchRealTimeThermalData event,
    Emitter<RealTimeThermalState> emit,
  ) async {
    print('🌡️  RealTimeThermalBloc: Fetching data (machineId=${event.machineId}, id=${event.id})');
    emit(RealTimeThermalLoading());
    try {
      final data = await _getRealTimeThermalDataUseCase.execute(
        machineId: event.machineId,
        id: event.id,
        deviceType: event.deviceType,
      );

      if (data != null) {
        print(
          '✅ RealTimeThermalBloc: Success for machineId=${event.machineId}, components=${data.data.keys.length}',
        );
        emit(RealTimeThermalLoaded(data: data));
      } else {
        print('⚠️  RealTimeThermalBloc: No data for machineId=${event.machineId}');
        emit(const RealTimeThermalError(message: 'Failed to load real-time thermal data'));
      }
    } catch (e) {
      print('❌ RealTimeThermalBloc: Error for machineId=${event.machineId}: $e');
      emit(RealTimeThermalError(message: 'Error: $e'));
    }
  }

  Future<void> _onRefreshRealTimeThermalData(
    RefreshRealTimeThermalData event,
    Emitter<RealTimeThermalState> emit,
  ) async {
    try {
      final data = await _getRealTimeThermalDataUseCase.execute(
        machineId: event.machineId,
        id: event.id,
        deviceType: event.deviceType,
      );

      if (data != null) {
        emit(RealTimeThermalLoaded(data: data));
      } else {
        emit(const RealTimeThermalError(message: 'Failed to refresh real-time thermal data'));
      }
    } catch (e) {
      emit(RealTimeThermalError(message: 'Error: $e'));
    }
  }
}
