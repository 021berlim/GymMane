import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/services/live_workout.dart';
import 'package:fitiron/services/local_store.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> liveCalls = [];

  setUp(() async {
    liveCalls.clear();
    SharedPreferences.setMockInitialValues({});
    await Store.instance.init();
    fit.saveAndExit();
    fit.sessions.clear();

    LiveWorkout.supportedOverride = true;
    LiveWorkout.isAndroidOverride = true;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gymmane/live'), (call) async {
      liveCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    LiveWorkout.supportedOverride = null;
    LiveWorkout.isAndroidOverride = null;
    fit.saveAndExit();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gymmane/live'), null);
  });

  test('LiveWorkout sync sends update payload when workout is active', () async {
    fit.startWorkout();
    fit.startCustomWorkout();
    fit.toggleMuscle('chest');
    fit.trainContinue();
    fit.startSession();

    await LiveWorkout.sync();

    expect(liveCalls.any((c) => c.method == 'update'), isTrue);
    final updateCall = liveCalls.firstWhere((c) => c.method == 'update');
    final args = updateCall.arguments as Map;

    expect(args['title'], isNotEmpty);
    expect(args['channel'], isNotNull);
    expect(args['segments'], isNotEmpty);
    expect(args['actions'], isNotEmpty);
  });

  test('LiveWorkout handles action triggers from notification actions', () async {
    fit.startWorkout();
    fit.startCustomWorkout();
    fit.toggleMuscle('chest');
    fit.trainContinue();
    fit.startSession();

    await LiveWorkout.sync();

    // Trigger action 'done' through the native bridge
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final codec = const StandardMethodCodec();
    final byteData = codec.encodeMethodCall(const MethodCall('action', 'done'));

    await messenger.handlePlatformMessage(
      'gymmane/live',
      byteData,
      (ByteData? data) {},
    );

    // Verify first set is marked done
    expect(fit.session!.exercises[0].sets[0].done, isTrue);
  });

  test('LiveWorkout end clears the native notification', () async {
    fit.startWorkout();
    fit.startCustomWorkout();
    fit.toggleMuscle('chest');
    fit.trainContinue();
    fit.startSession();

    await LiveWorkout.sync();
    liveCalls.clear();

    await LiveWorkout.end();

    expect(liveCalls.any((c) => c.method == 'end'), isTrue);
  });
}
