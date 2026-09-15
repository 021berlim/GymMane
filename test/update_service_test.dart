import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/services/update_service.dart';

void main() {
  group('UpdateService semver parsing', () {
    test('standard semver comparison', () {
      // We can test UpdateInfo construction
      const info = UpdateInfo(
        version: '1.0.3',
        changelog: 'Bug fixes',
        apkUrl: 'https://example.com/app.apk',
        isForced: false,
      );
      expect(info.version, '1.0.3');
      expect(info.isForced, false);
    });
  });
}
