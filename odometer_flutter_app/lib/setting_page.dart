import 'package:flutter/material.dart';
import '../models/tracking_settings.dart';

class TrackingSettingsScreen extends StatefulWidget {
  final TrackingSettings initialSettings;
  final ValueChanged<TrackingSettings> onSave;

  const TrackingSettingsScreen({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<TrackingSettingsScreen> createState() => _TrackingSettingsScreenState();
}

class _TrackingSettingsScreenState extends State<TrackingSettingsScreen> {
  late int _distanceFilter;
  late int _intervalSeconds;
  TrackingMode _selectedMode = TrackingMode.distance;

  @override
  void initState() {
    super.initState();
    _distanceFilter = widget.initialSettings.distanceFilter;
    _intervalSeconds = widget.initialSettings.intervalSeconds;

    // 初期設定から自動的にモード推定（距離が 0 なら interval）
    if (_distanceFilter == 0 && _intervalSeconds > 0) {
      _selectedMode = TrackingMode.interval;
    } else {
      _selectedMode = TrackingMode.distance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('追跡設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('追跡モードを選択:'),
            ListTile(
              title: const Text('距離による追跡'),
              leading: Radio<TrackingMode>(
                value: TrackingMode.distance,
                groupValue: _selectedMode,
                onChanged: (value) => setState(() => _selectedMode = value!),
              ),
            ),
            ListTile(
              title: const Text('時間による追跡'),
              leading: Radio<TrackingMode>(
                value: TrackingMode.interval,
                groupValue: _selectedMode,
                onChanged: (value) => setState(() => _selectedMode = value!),
              ),
            ),
            const Divider(height: 32),
            const Text('距離フィルター (m):'),
            Slider(
              min: 0,
              max: 100,
              divisions: 20,
              label: _distanceFilter.toString(),
              value: _distanceFilter.toDouble(),
              onChanged: _selectedMode == TrackingMode.distance
                  ? (v) => setState(() => _distanceFilter = v.toInt())
                  : null,
            ),
            Text('$_distanceFilter m'),
            const SizedBox(height: 24),
            const Text('時間間隔 (秒):'),
            Slider(
              min: 1,
              max: 60,
              divisions: 59,
              label: _intervalSeconds.toString(),
              value: _intervalSeconds.toDouble(),
              onChanged: _selectedMode == TrackingMode.interval
                  ? (v) => setState(() => _intervalSeconds = v.toInt())
                  : null,
            ),
            Text('$_intervalSeconds s'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final distance = _selectedMode == TrackingMode.distance ? _distanceFilter : 0;
                  final interval = _selectedMode == TrackingMode.interval ? _intervalSeconds : 0;

                  widget.onSave(TrackingSettings(
                    distanceFilter: distance,
                    intervalSeconds: interval,
                    selectedMode: _selectedMode,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
