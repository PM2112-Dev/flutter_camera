# Area Devices API

API để lấy danh sách thiết bị (machines/sensors) hiển thị trên sơ đồ 1 sợi theo khu vực.

## Endpoint

```
GET /api/ThermalDatas/machinesAndResultByArea?areaId={areaId}
```

## Response Format

```json
{
  "isSuccess": true,
  "code": "200",
  "message": null,
  "data": {
    "item1": [
      // List of devices/machines
      {
        "key": "3_Machine",
        "machineId": 3,
        "deviceType": "Machine", // "Machine" or "Sensor"
        "deviceTypeName": "Thiết bị",
        "monitorPointIcon": "Camera", // "Camera" or "Sensor"
        "longitude": 492.5, // X coordinate on diagram
        "latitude": 471.25, // Y coordinate on diagram
        "level": "Undefined",
        "code": "MC112",
        "name": "112",
        "id": 3
      }
    ],
    "item2": [] // Results (currently empty)
  }
}
```

## Sử dụng trong Flutter

### 1. Import các dependencies

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera/di/injection.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_bloc.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_event.dart';
import 'package:flutter_camera/presentation/bloc/area_devices/area_devices_state.dart';
import 'package:flutter_camera/domain/model/area_devices.dart';
```

### 2. Tạo BlocProvider

```dart
BlocProvider(
  create: (context) => getIt<AreaDevicesBloc>()
    ..add(FetchAreaDevices(areaId: 5)), // Truyền areaId của khu vực
  child: YourWidget(),
)
```

### 3. Lắng nghe state changes

```dart
BlocBuilder<AreaDevicesBloc, AreaDevicesState>(
  builder: (context, state) {
    if (state is AreaDevicesLoading) {
      return CircularProgressIndicator();
    } else if (state is AreaDevicesError) {
      return Text('Error: ${state.message}');
    } else if (state is AreaDevicesLoaded) {
      final devices = state.devices;

      // Hiển thị devices trên sơ đồ
      return Stack(
        children: [
          // Background image (sơ đồ)
          Image.network(diagramImageUrl),

          // Overlay devices với tọa độ
          ...devices.map((device) {
            return Positioned(
              left: device.longitude,
              top: device.latitude,
              child: _buildDeviceMarker(device),
            );
          }),
        ],
      );
    }
    return SizedBox.shrink();
  },
)
```

### 4. Device Properties

```dart
class DeviceItem {
  final String key;              // Unique key: "{id}_{deviceType}"
  final int machineId;           // Machine ID (0 for sensors)
  final String deviceType;       // "Machine" or "Sensor"
  final String deviceTypeName;   // Display name: "Thiết bị" or "Cảm biến"
  final String monitorPointIcon; // Icon type: "Camera" or "Sensor"
  final double longitude;        // X position on diagram
  final double latitude;         // Y position on diagram
  final String level;            // Status level
  final String code;             // Device code
  final String name;             // Device name
  final int id;                  // Device ID

  // Helpers
  bool get isMachine => deviceType.toLowerCase() == 'machine';
  bool get isSensor => deviceType.toLowerCase() == 'sensor';
  bool get hasCamera => monitorPointIcon.toLowerCase() == 'camera';
}
```

### 5. Refresh Data

```dart
// Pull to refresh
RefreshIndicator(
  onRefresh: () async {
    context.read<AreaDevicesBloc>().add(RefreshAreaDevices(areaId: areaId));
  },
  child: YourContent(),
)
```

## Events

- `FetchAreaDevices(areaId: int)` - Tải danh sách devices lần đầu
- `RefreshAreaDevices(areaId: int)` - Làm mới dữ liệu

## States

- `AreaDevicesInitial` - Trạng thái ban đầu
- `AreaDevicesLoading` - Đang tải dữ liệu
- `AreaDevicesLoaded(devices: List<DeviceItem>)` - Đã tải thành công
- `AreaDevicesError(message: String)` - Có lỗi xảy ra

## Ví dụ hiển thị marker

```dart
Widget _buildDeviceMarker(DeviceItem device) {
  return GestureDetector(
    onTap: () {
      // Navigate to device detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceDetailPage(deviceId: device.id),
        ),
      );
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: device.hasCamera ? Colors.blue : Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        device.hasCamera ? Icons.videocam : Icons.sensors,
        color: Colors.white,
        size: 20,
      ),
    ),
  );
}
```

## Notes

- Tọa độ (longitude, latitude) là vị trí pixel trên hình ảnh sơ đồ, không phải tọa độ địa lý
- API yêu cầu authentication token
- Data được cache trong bloc, sử dụng RefreshAreaDevices để cập nhật
