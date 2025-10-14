# Real-Time Thermal Data Bloc

This bloc manages the state for fetching real-time thermal data for machines/devices.

## API Endpoint

`GET /api/ThermalDatas/realTimeThermalData?machineId={machineId}&id={id}&deviceType={deviceType}`

## Usage Example

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_bloc.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_event.dart';
import 'package:flutter_camera/presentation/bloc/real_time_thermal/real_time_thermal_state.dart';

// In your widget
class ThermalDataView extends StatelessWidget {
  final int machineId;
  final int id;
  final String deviceType; // e.g., "Machine" or "Sensor"

  const ThermalDataView({
    Key? key,
    required this.machineId,
    required this.id,
    required this.deviceType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RealTimeThermalBloc>()
        ..add(FetchRealTimeThermalData(
          machineId: machineId,
          id: id,
          deviceType: deviceType,
        )),
      child: BlocBuilder<RealTimeThermalBloc, RealTimeThermalState>(
        builder: (context, state) {
          if (state is RealTimeThermalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RealTimeThermalLoaded) {
            // Access thermal data
            final data = state.data.data; // Map<String, List<ThermalDataItem>>

            // Example: Display data for each component
            return ListView(
              children: data.entries.map((entry) {
                final componentName = entry.key; // e.g., "TI112_A"
                final items = entry.value; // List<ThermalDataItem>

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Component: $componentName'),
                    ...items.map((item) => ListTile(
                      title: Text('Temperature: ${item.temperature}°C'),
                      subtitle: Text(
                        'Min: ${item.minTemperature}°C, '
                        'Max: ${item.maxTemperature}°C, '
                        'Avg: ${item.aveTemperature}°C'
                      ),
                    )),
                  ],
                );
              }).toList(),
            );
          } else if (state is RealTimeThermalError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
```

## Data Structure

The response contains thermal data grouped by component names (e.g., "TI112_A", "TI112_B", "TI112_C").

Each component has a list of thermal data items containing:

- Temperature readings (current, min, max, average)
- Comparison results (with environment, min phase, global min phase)
- Monitor point information
- Time and date of measurement

## Refresh Data

To refresh the data:

```dart
context.read<RealTimeThermalBloc>().add(RefreshRealTimeThermalData(
  machineId: machineId,
  id: id,
  deviceType: deviceType,
));
```

## Notes

- The API automatically uses the auth token from `AuthLocalPreference`
- Headers are not hardcoded and follow the project's pattern
- Device type should be "Machine" or "Sensor" based on the device
