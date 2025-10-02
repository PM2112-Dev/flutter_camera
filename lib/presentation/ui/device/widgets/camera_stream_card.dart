import 'package:flutter/material.dart';
import 'package:flutter_camera/domain/model/camera.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';
import 'package:flutter_camera/presentation/ui/device/widgets/hls_camera_stream_widget.dart';

class CameraStreamCard extends StatefulWidget {
  final Camera camera;
  final bool showStream;
  final VoidCallback? onTap;
  final VoidCallback? onPinToggle;
  final bool isPinned;
  final String? streamId;
  final bool isLoadingStreamId;

  const CameraStreamCard({
    super.key,
    required this.camera,
    this.showStream = false,
    this.onTap,
    this.onPinToggle,
    this.isPinned = false,
    this.streamId,
    this.isLoadingStreamId = false,
  });

  @override
  State<CameraStreamCard> createState() => _CameraStreamCardState();
}

class _CameraStreamCardState extends State<CameraStreamCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call super.build when using AutomaticKeepAliveClientMixin

    // Debug log để xem device status
    debugPrint(
      'CameraStreamCard: Camera ${widget.camera.name} - deviceStatus: "${widget.camera.deviceStatus}", status: "${widget.camera.status}"',
    );

    final isOnline =
        widget.camera.deviceStatus.toUpperCase() == 'ONLINE' ||
        widget.camera.status.toUpperCase() == 'ONLINE' ||
        widget.camera.deviceStatus.toUpperCase() == 'ON';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showRemoveDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video stream section
            Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Video stream
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: SizedBox.expand(
                      child: widget.showStream && isOnline
                          ? HlsCameraStreamWidget(
                              streamId: widget.streamId,
                              width: double.infinity,
                              height: 220,
                              isLoadingStreamId: widget.isLoadingStreamId,
                            )
                          : _buildVideoPlaceholder(isOnline),
                    ),
                  ),

                  // Top overlay with more button only
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () => _showMoreOptions(context),
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera name
                  Text(
                    widget.camera.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Station/Area info
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.camera.area.name,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(bool isOnline) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOnline ? Icons.videocam : Icons.videocam_off,
            color: Colors.white.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            isOnline ? 'Nhấn để xem stream' : 'Camera offline',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.camera.name,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Thông tin camera'),
              onTap: () {
                Navigator.pop(context);
                widget.onTap?.call();
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa khỏi danh sách', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onPinToggle?.call();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa camera'),
        content: Text('Bạn có muốn xóa camera "${widget.camera.name}" khỏi danh sách?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPinToggle?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
