import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/domain/usecase/area/get_all_tree_use_case.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_event.dart';
import 'package:flutter_camera/presentation/ui/device/bloc/device_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetAllTreeUseCase getAllTreeUseCase;

  DeviceBloc(this.getAllTreeUseCase) : super(DeviceInitial()) {
    on<DeviceStartedEvent>(_onStarted);
  }

  void _onStarted(DeviceStartedEvent event, Emitter<DeviceState> emit) async {
    emit(const DeviceLoadingState());
    try {
      emit(const DeviceLoadingState());
      final result = await getAllTreeUseCase();
      result.fold(
        (failure) {
          emit(DeviceErrorState(failure.toString()));
        },
        (areaTrees) {
          emit(DeviceStartedState(areaTrees));
        },
      );
    } catch (e) {
      emit(DeviceErrorState(e.toString()));
    }
  }
}
