import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controlador Atômico de Áudio configurado estritamente com AudioAttributes AOSP.
class AlarmController {
  AlarmController._();
  static final AlarmController instance = AlarmController._();

  AudioPlayer? _player;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  Future<void> init() async {
    if (_player != null) return;
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setPlayerMode(PlayerMode.mediaPlayer);

      // Roteamento nativo AOSP para stream USAGE_ALARM furando modo silencioso e DND
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.duckOthers},
          ),
        ),
      );
      _player = player;
    } catch (e) {
      debugPrint('[AlarmController] Erro ao inicializar AudioPlayer: $e');
    }
  }

  /// Inicia a reprodução contínua do alarme
  Future<void> playAlarm({Source? source}) async {
    if (_isPlaying) return;
    _isPlaying = true;
    isPlayingNotifier.value = true;

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    final player = _player;
    if (player == null) return;

    try {
      await player.stop();
      final effectiveSource = source ?? AssetSource('audio/rest_over.wav');
      await player.play(effectiveSource, volume: 1.0);
    } catch (e) {
      debugPrint('[AlarmController] Falha ao tocar áudio: $e');
      _isPlaying = false;
      isPlayingNotifier.value = false;
    }
  }

  /// Interrupção atômica instantânea
  Future<void> stopAlarm() async {
    if (!_isPlaying && _player == null) return;
    _isPlaying = false;
    isPlayingNotifier.value = false;

    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('[AlarmController] Falha ao parar áudio: $e');
    }
  }
}
