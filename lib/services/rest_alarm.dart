import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l10n.dart';
import 'alarm_controller.dart';

class RestAlarm {
  RestAlarm._();
  static final RestAlarm instance = RestAlarm._();

  static const _id = 1001;
  AndroidNotificationDetails _android(int scheduledMillis) => AndroidNotificationDetails(
    'rest_timer_v3',
    t.notifRestChannel,
    channelDescription: t.notifRestChannelWhy,
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.alarm,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    showWhen: true,
    when: scheduledMillis,
    usesChronometer: true,
    chronometerCountDown: true,
    icon: 'ic_notification',
    visibility: NotificationVisibility.public,
  );

  AndroidNotificationDetails get _androidAlert => AndroidNotificationDetails(
    'rest_timer_alert_v2',
    t.notifAlertChannel,
    channelDescription: t.notifAlertChannelWhy,
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.alarm,
    playSound: false,
    enableVibration: true,
    fullScreenIntent: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    showWhen: true,
    when: DateTime.now().millisecondsSinceEpoch,
    usesChronometer: true,
    ongoing: true,
    autoCancel: false,
    icon: 'ic_notification',
    visibility: NotificationVisibility.public,
    actions: const [
      AndroidNotificationAction(
        'stop_alarm_action',
        'Parar Alarme',
        showsUserInterface: true,
        cancelNotification: true,
      ),
    ],
  );

  AndroidNotificationDetails get _androidGoal => AndroidNotificationDetails(
    'goal_channel_v1',
    t.notifGoalChannel,
    channelDescription: t.notifGoalChannelWhy,
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: 'ic_notification',
    visibility: NotificationVisibility.public,
  );

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> showGoalReachedNotification({String? title, String? body}) async {
    if (!_ready) return;
    try {
      await ensurePermission();
      await _plugin.show(
        id: 3000 + (DateTime.now().millisecondsSinceEpoch % 10000),
        title: title ?? t.goalReachedTitle,
        body: body ?? t.goalReachedBody,
        notificationDetails: NotificationDetails(android: _androidGoal),
      );
    } catch (e) {
      debugPrint('No se pudo mostrar la notificación de meta: $e');
    }
  }

  String? customSoundPath;

  Source get _source {
    final p = customSoundPath;
    if (p != null && p.isNotEmpty) return DeviceFileSource(p);
    return AssetSource('audio/rest_over.wav');
  }
  bool _ready = false;
  bool _permissionAsked = false;
  int _generation = 0;

  Future<void> init() async {
    if (_ready) return;

    try {
      tzdata.initializeTimeZones();
      final initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: (_) => stopSound(),
      );
      _ready = initialized ?? true;
      debugPrint('[RestAlarm.init] Notificações inicializadas com sucesso (_ready: $_ready)');
    } catch (e, st) {
      _ready = false;
      debugPrint('[RestAlarm.init] Falha ao inicializar notificações: $e\n$st');
    }
    await AlarmController.instance.init();
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Sin este permiso la alarma no suena con la pantalla apagada.
  Future<bool> notificationsAllowed() async {
    if (!_ready) return true;
    try {
      return await _androidPlugin?.areNotificationsEnabled() ?? true;
    } catch (e) {
      debugPrint('[RestAlarm] Erro ao verificar areNotificationsEnabled: $e');
      return true;
    }
  }

  Future<bool> exactAlarmsAllowed() async {
    if (!_ready) return true;
    try {
      return await _androidPlugin?.canScheduleExactNotifications() ?? true;
    } catch (e) {
      debugPrint('[RestAlarm] Erro ao verificar canScheduleExactNotifications: $e');
      return true;
    }
  }

  /// Devuelve si quedó concedido. Android solo enseña el diálogo un par de
  /// veces; a partir de ahí hay que mandar al usuario a los ajustes.
  Future<bool> requestPermission() async {
    if (!_ready) return true;
    try {
      final granted = await _androidPlugin?.requestNotificationsPermission() ?? true;
      await requestExactAlarmPermission();
      return granted;
    } catch (e) {
      debugPrint('No se pudo pedir permiso de notificaciones: $e');
      return false;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (!_ready) return true;
    try {
      return await _androidPlugin?.requestExactAlarmsPermission() ?? true;
    } catch (e) {
      debugPrint('Não foi possível solicitar alarmes exatos: $e');
      return false;
    }
  }

  Future<void> ensureExactAlarmPermission() async {
    if (!_ready || await exactAlarmsAllowed()) return;
    await requestExactAlarmPermission();
  }

  Future<void> ensurePermission() async {
    if (!_ready || _permissionAsked) return;
    _permissionAsked = true;
    await requestPermission();
  }

  Future<void> fireNow() async {
    await cancel();

    if (_ready) {
      try {
        await _plugin.show(
          id: _id,
          title: t.restOverTitle,
          body: t.restOverBody,
          notificationDetails: NotificationDetails(android: _androidAlert),
        );
        debugPrint('[RestAlarm.fireNow] Notificação visual de descanso exibida com sucesso.');
      } catch (e, st) {
        debugPrint('[RestAlarm.fireNow] Erro ao exibir notificação visual: $e\n$st');
      }
    } else {
      debugPrint('[RestAlarm.fireNow] AVISO: Notificação visual NÃO exibida pois _ready == false.');
    }
    await AlarmController.instance.playAlarm(source: _source);
  }

  Future<void> preview() async {
    await AlarmController.instance.playAlarm(source: _source);
  }

  Future<Duration?> probeDuration(String path) async {
    AudioPlayer? probe;
    try {
      probe = AudioPlayer();
      await probe.setReleaseMode(ReleaseMode.stop);
      await probe.setSource(DeviceFileSource(path));

      for (var i = 0; i < 10; i++) {
        final d = await probe.getDuration();
        if (d != null && d > Duration.zero) return d;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
      return null;
    } catch (e) {
      debugPrint('No se pudo leer la duración del audio: $e');
      return null;
    } finally {
      try {
        await probe?.release();
        await probe?.dispose();
      } catch (_) {}
    }
  }

  Future<void> stopSound() async {
    await AlarmController.instance.stopAlarm();
    await cancelActiveNotification();
  }

  Future<void> cancelActiveNotification() async {
    try {
      await _plugin.cancel(id: _id);
    } catch (_) {}
  }

  Future<void> schedule(Duration after) async {
    if (!_ready) {
      debugPrint('[RestAlarm.schedule] AVISO: Notificação não agendada pois _ready == false.');
      return;
    }
    final mine = ++_generation;

    await ensurePermission();
    if (mine != _generation) return;
    await _clear();
    if (mine != _generation) return;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(after);
    try {
      await _plugin.zonedSchedule(
        id: _id,
        title: t.restOverTitle,
        body: t.restOverBody,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: _android(scheduledDate.millisecondsSinceEpoch)),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
      debugPrint('[RestAlarm.schedule] Notificação agendada com sucesso para $scheduledDate.');
    } catch (e, st) {
      debugPrint('[RestAlarm.schedule] Erro ao programar o aviso: $e\n$st');
    }
  }

  Future<void> cancel() async {
    _generation++;
    await _clear();
  }

  Future<void> _clear() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _id);
    } catch (_) {}
  }
}
