# odometer_flutter_app

Flutter version: 3.29.0

flutter build apk --release
build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
build/app/outputs/bundle/release/app-release.aab

adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk

## 機能説明

1. **位置情報権限の確認と要求**:
  - アプリ起動時に位置情報権限を確認
  - 権限がない場合は設定画面を開くダイアログを表示

2. **位置情報の追跡**:
  - 開始ボタンで位置情報の取得を開始
  - 5メートル移動するごとに位置情報を更新
  - 前回の位置との距離を計算して総移動距離に加算

3. **データ表示**:
  - 総移動距離をカード形式で表示
  - 取得した位置情報のリストを表示

4. **計測の停止**:
  - 停止ボタンで位置情報の取得を停止
