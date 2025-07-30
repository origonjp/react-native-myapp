
import 'dart:async';

import 'package:odometer_flutter_app/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/tracking_settings.dart';

const kDistanceFilter = 5;
const kIntervalSeconds = 30;

class DistanceTrackerScreen extends StatefulWidget {
  const DistanceTrackerScreen({super.key});

  @override
  _DistanceTrackerScreenState createState() => _DistanceTrackerScreenState();
}

class _DistanceTrackerScreenState extends State<DistanceTrackerScreen> {
  List<Position> _positionHistory = [];
  double _totalDistance = 0.0; // 総移動距離(メートル)
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;

  // ✅ ここに tracking 設定の初期値を定義
  TrackingSettings _trackingSettings = TrackingSettings(
    distanceFilter: kDistanceFilter,         // 5メートル以上動いたら更新
    intervalSeconds: kIntervalSeconds,       // 30秒ごとに取得
    selectedMode: TrackingMode.interval,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('位置情報権限が必要です'),
        content: Text('このアプリは位置情報を使用して移動距離を計算します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  _loggingPosition(Position position) {
    debugPrint('Latitude: ${position.latitude}');
    debugPrint('Longitude: ${position.longitude}');
    debugPrint('Speed (m/s): ${position.speed}');       // 速度(m/s)
    debugPrint('Heading (deg): ${position.heading}');   // 方位(0-360度、北が0)
    setState(() {
      if (_positionHistory.isNotEmpty) {
        final lastPosition = _positionHistory.last;
        final distance = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance;
      }
      _positionHistory.add(position);
    });
  }

  void _startTracking() async {
    if (!await Permission.location.isGranted) {
      _checkLocationPermission();
      return;
    }

    setState(() {
      _isTracking = true;
      _positionHistory.clear();
      _totalDistance = 0.0;
    });

    if (_trackingSettings.selectedMode == TrackingMode.distance) {
      // 1. 距離移動でのストリーム
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: _trackingSettings.distanceFilter,
          timeLimit: Duration(seconds: _trackingSettings.intervalSeconds),
        ),
      ).listen((Position position) {
        _loggingPosition(position);
      });
    } else if (_trackingSettings.selectedMode == TrackingMode.interval) {
      // 2. 定期的なタイマー更新
      _timer = Timer.periodic(
        Duration(seconds: _trackingSettings.intervalSeconds),
            (_) async {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
          );
          _loggingPosition(position);
        },
      );
    }

  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
    });


    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('計測終了'),
        content: Text('総移動距離: ${_formatDistance(_totalDistance)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(1)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('移動距離計測'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final newSettings = await Navigator.push<TrackingSettings>(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackingSettingsScreen(
                    initialSettings: _trackingSettings,
                    onSave: (settings) {
                      setState(() {
                        _trackingSettings = settings;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '総移動距離',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      _formatDistance(_totalDistance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _positionHistory.length,
              itemBuilder: (context, index) {
                final reversedHistory = _positionHistory.reversed.toList();
                final position = reversedHistory[index];
                return ListTile(
                  title: Text('位置 ${_positionHistory.length - index}'),
                  subtitle: Text(
                    '緯度: ${position.latitude.toStringAsFixed(6)} '
                        '経度: ${position.longitude.toStringAsFixed(6)} '
                        '位置の精度: ${position.accuracy.toStringAsFixed(2)} m\n'
                        '速度: ${position.speed.toStringAsFixed(4)} m/s'
                        '速度性度: ${position.speedAccuracy.toStringAsFixed(2)} m/s'
                        '方向: ${position.heading.toStringAsFixed(2)}\n'
                        '高度: ${position.altitude.toStringAsFixed(2)} m\n'
                        '高度精度: ${position.altitudeAccuracy.toStringAsFixed(2)} m\n'
                        '時刻: ${position.timestamp.toLocal().toString() ?? '不明'}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTracking ? _stopTracking : _startTracking,
        tooltip: _isTracking ? '計測停止' : '計測開始',
        child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
