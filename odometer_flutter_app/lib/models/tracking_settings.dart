
enum TrackingMode { distance, interval }

class TrackingSettings {
  final int distanceFilter; // メートル
  final int intervalSeconds; // 秒
  final TrackingMode selectedMode;

  TrackingSettings({
    required this.distanceFilter,
    required this.intervalSeconds,
    required this.selectedMode,
  });
}
