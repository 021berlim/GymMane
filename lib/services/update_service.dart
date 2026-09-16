import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Metadata about an available update from GitHub Releases.
class UpdateInfo {
  final String version;
  final String changelog;
  final String apkUrl;
  final bool isForced;

  const UpdateInfo({
    required this.version,
    required this.changelog,
    required this.apkUrl,
    required this.isForced,
  });
}

/// Typed result of an update check operation.
sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

class UpdateAvailable extends UpdateCheckResult {
  final UpdateInfo info;
  const UpdateAvailable(this.info);
}

class UpToDate extends UpdateCheckResult {
  const UpToDate();
}

class CheckFailed extends UpdateCheckResult {
  final String reason;
  final String? debugDetail;
  const CheckFailed(this.reason, [this.debugDetail]);
}

/// Checks GitHub Releases for a newer APK and can download + install it.
///
/// Owner/repo come from the project's git remote origin (021berlim/GymMane).
/// The service is Android-only; callers must guard with [Platform.isAndroid].
class UpdateService {
  UpdateService._();

  static const _owner = '021berlim';
  static const _repo = 'GymMane';

  static const _installChannel = MethodChannel('com.fitiron.app/install');
  static const _updateNotificationId = 9999;
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

  static Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    try {
      const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
      await _notifications.initialize(
        settings: const InitializationSettings(android: androidInit),
        onDidReceiveNotificationResponse: (response) {
          final path = response.payload;
          if (path != null && path.isNotEmpty) {
            _installChannel.invokeMethod('installApk', {'path': path});
          }
        },
      );
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      _notificationsInitialized = true;
    } catch (_) {}
  }

  static Future<void> _showProgressNotification(String version, int percent) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'fitiron_updates',
        'App Updates',
        channelDescription: 'Notifications for app update downloads',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: percent,
        ongoing: true,
        onlyAlertOnce: true,
        icon: 'ic_notification',
      );
      await _notifications.show(
        id: _updateNotificationId,
        title: 'Baixando FIT//IRON v$version',
        body: '$percent% concluído',
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  static Future<void> _showCompletedNotification(String version, String apkPath) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'fitiron_updates',
        'App Updates',
        channelDescription: 'Notifications for app update downloads',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        icon: 'ic_notification',
      );
      await _notifications.show(
        id: _updateNotificationId,
        title: 'Atualização v$version pronta!',
        body: 'Toque para instalar a nova versão.',
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: apkPath,
      );
    } catch (_) {}
  }

  static Future<void> _showErrorNotification(String version) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'fitiron_updates',
        'App Updates',
        channelDescription: 'Notifications for app update downloads',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        ongoing: false,
        autoCancel: true,
        icon: 'ic_notification',
      );
      await _notifications.show(
        id: _updateNotificationId,
        title: 'Falha no download da v$version',
        body: 'Verifique sua conexão e tente novamente.',
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  /// Checks GitHub Releases for a newer release and returns an [UpdateCheckResult].
  static Future<UpdateCheckResult> checkForUpdate() async {
    const headers = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 FitIron-App/1.0',
    };

    http.Response? primaryResponse;
    Object? primaryException;

    try {
      final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest');
      primaryResponse = await http.get(url, headers: headers).timeout(const Duration(seconds: 8));
      if (primaryResponse.statusCode == 200) {
        final data = jsonDecode(primaryResponse.body) as Map<String, dynamic>;
        return await _parseReleaseData(data);
      }
    } on TimeoutException catch (e) {
      primaryException = e;
      return _logAndFail('Tempo esgotado ao conectar ao GitHub', e.toString());
    } on SocketException catch (e) {
      primaryException = e;
      return _logAndFail('Sem conexão ou domínio bloqueado', e.toString());
    } on http.ClientException catch (e) {
      primaryException = e;
      return _logAndFail('Sem conexão ou domínio bloqueado', e.toString());
    } on FormatException catch (e) {
      return _logAndFail('Resposta inesperada do GitHub', e.toString());
    } catch (e) {
      primaryException = e;
    }

    if (primaryResponse != null && primaryResponse.statusCode == 403) {
      final bodyLower = primaryResponse.body.toLowerCase();
      if (bodyLower.contains('rate limit') || primaryResponse.headers['x-ratelimit-remaining'] == '0') {
        return _logAndFail('Limite de requisições do GitHub atingido, tente mais tarde', 'status 403');
      }
    }

    // Try secondary fallback endpoint: releases list
    try {
      final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases');
      final fallbackResponse = await http.get(url, headers: headers).timeout(const Duration(seconds: 8));
      if (fallbackResponse.statusCode == 200) {
        final list = jsonDecode(fallbackResponse.body) as List;
        if (list.isNotEmpty) {
          return await _parseReleaseData(list.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    if (primaryResponse != null) {
      final shortBody = primaryResponse.body.length > 100
          ? primaryResponse.body.substring(0, 100)
          : primaryResponse.body;
      return _logAndFail('GitHub respondeu ${primaryResponse.statusCode}', shortBody);
    }

    if (primaryException != null) {
      return _logAndFail('Erro ao conectar ao GitHub', primaryException.toString());
    }

    return _logAndFail('GitHub não respondeu', null);
  }

  static CheckFailed _logAndFail(String reason, String? debugDetail) {
    final msg = debugDetail != null && debugDetail.isNotEmpty
        ? '[UpdateService] $reason ($debugDetail)'
        : '[UpdateService] $reason';
    debugPrint(msg);
    log(msg, name: 'UpdateService');
    return CheckFailed(reason, debugDetail);
  }

  static Future<UpdateCheckResult> _parseReleaseData(Map<String, dynamic> data) async {
    try {
      final tagName = data['tag_name'] as String? ?? '';
      final remoteVersion = tagName.replaceFirst(RegExp(r'^v'), '');

      final info = await PackageInfo.fromPlatform();
      final currentVersion = '${info.version}+${info.buildNumber}';

      if (!_isNewer(remoteVersion, currentVersion)) {
        return const UpToDate();
      }

      final abi = await _deviceAbi();
      final assets = (data['assets'] as List?) ?? [];
      String? apkUrl;
      for (final asset in assets) {
        final name = (asset['name'] as String?) ?? '';
        if (!name.endsWith('.apk')) continue;
        if (name.contains(abi)) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
        apkUrl ??= asset['browser_download_url'] as String?;
      }
      if (apkUrl == null) {
        return _logAndFail('Nenhum APK compatível encontrado no release', 'tag $tagName');
      }

      final title = (data['name'] as String?) ?? '';
      final isForced = title.startsWith('[FORCE]');
      final changelog = (data['body'] as String?) ?? '';

      return UpdateAvailable(
        UpdateInfo(
          version: remoteVersion,
          changelog: changelog,
          apkUrl: apkUrl,
          isForced: isForced,
        ),
      );
    } catch (e) {
      return _logAndFail('Resposta inesperada do GitHub', e.toString());
    }
  }

  /// Downloads the APK and triggers the Android package installer.
  static Future<void> downloadAndInstall(
    UpdateInfo info,
    void Function(double progress) onProgress,
  ) async {
    try {
      await _initNotifications();
      _showProgressNotification(info.version, 0);

      final request = http.Request('GET', Uri.parse(info.apkUrl));
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 FitIron-App/1.0';
      final streamedResponse = await request.send();

      final contentLength = streamedResponse.contentLength ?? 0;
      final bytes = <int>[];
      int received = 0;
      int lastPercent = -1;

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          final progress = received / contentLength;
          onProgress(progress);

          final percent = (progress * 100).toInt();
          if (percent - lastPercent >= 5 || percent == 100) {
            lastPercent = percent;
            _showProgressNotification(info.version, percent);
          }
        }
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fitiron_update.apk');
      await file.writeAsBytes(bytes, flush: true);

      _showCompletedNotification(info.version, file.path);

      await _installChannel.invokeMethod('installApk', {'path': file.path});
    } catch (e) {
      _showErrorNotification(info.version);
      rethrow;
    }
  }

  static Future<String> _deviceAbi() async {
    try {
      final abi = await _installChannel.invokeMethod<String>('getAbi');
      return abi ?? 'arm64-v8a';
    } catch (_) {
      return 'arm64-v8a';
    }
  }

  static bool _isNewer(String remote, String current) {
    final r = _parseSemver(remote);
    final c = _parseSemver(current);
    if (r == null || c == null) return false;
    if (r.$1 != c.$1) return r.$1 > c.$1;
    if (r.$2 != c.$2) return r.$2 > c.$2;
    if (r.$3 != c.$3) return r.$3 > c.$3;
    return r.$4 > c.$4;
  }

  static (int, int, int, int)? _parseSemver(String v) {
    final clean = v.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final parts = clean.split('+');
    final core = parts[0];
    final build = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final versionParts = core.split('.');
    if (versionParts.length < 2) return null;
    final major = int.tryParse(versionParts[0]);
    final minor = int.tryParse(versionParts[1]);
    final patch = versionParts.length > 2 ? int.tryParse(versionParts[2]) : 0;
    if (major == null || minor == null || patch == null) return null;
    return (major, minor, patch, build);
  }
}
