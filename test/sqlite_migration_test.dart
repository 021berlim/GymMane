import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitiron/services/local_store.dart';
import 'package:fitiron/services/sqlite_store.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates legacy SharedPreferences data to SQLite database without data loss', () async {
    final legacyMap = {
      'profile': {
        'name': 'Legacy User',
        'sex': 'female',
        'age': 30,
        'h': 168.0,
        'w': 62.5,
        'act': 1.4,
        'goal': 5,
        'photo': '',
        'focus': 'strength',
      },
      'dark': false,
      'units': 'lb',
      'language': 'es',
      'rest': 120,
      'onboarded': true,
      'favorites': {'bench-press': true},
      'checkins': ['2026-09-01'],
      'routines': [
        {
          'id': 'routine_1',
          'n': 'Leg Day',
          'ex': ['squat'],
          'cfg': {
            'squat': {'id': 'squat', 's': 4, 'w': 100.0, 'r': 8}
          }
        }
      ],
      'custom': [
        {
          'id': 'custom_1',
          'n': 'Custom Press',
          'p': 'chest',
          'e': 'Dumbbell',
          'd': 'Intermediate',
          'm': ''
        }
      ],
      'sessions': [
        {
          'd': '2026-09-05T10:00:00.000',
          'dur': 3600,
          'ex': [
            {
              'id': 'bench-press',
              'n': 'Supino Reto',
              'p': 'chest',
              's': [
                {'r': 10, 'w': 80.0},
                {'r': 8, 'w': 85.0}
              ]
            }
          ]
        }
      ],
      'bodyweight': [
        {'d': '2026-09-05T10:00:00.000', 'kg': 62.5}
      ],
      'exNotes': {
        'Supino Reto': [
          {'d': '2026-09-05T10:00:00.000', 't': 'Fácil, aumentar carga'}
        ]
      },
      'goals': [
        {'id': 'g1', 'type': 'sessionsWeekly', 'val': 5.0, 'exId': null, 'pri': true}
      ]
    };

    SharedPreferences.setMockInitialValues({
      'fitiron_v1': jsonEncode(legacyMap),
    });

    // Initialize Store (opens SQLite and triggers LegacyMigrator)
    await Store.instance.init();

    // Load state in fit
    fit.loadFromStore();

    expect(fit.profile.name, 'Legacy User');
    expect(fit.profile.sex, 'female');
    expect(fit.dark, false);
    expect(fit.units, 'lb');
    expect(fit.language, 'es');
    expect(fit.restSeconds, 120);
    expect(fit.onboarded, true);
    expect(fit.favorites['bench-press'], true);
    expect(fit.checkins.contains('2026-09-01'), true);

    expect(fit.routines.length, 1);
    expect(fit.routines.first.name, 'Leg Day');

    expect(fit.customExercises.length, 1);
    expect(fit.customExercises.first.name, 'Custom Press');

    expect(fit.sessions.length, 1);
    expect(fit.sessions.first.exercises.first.name, 'Supino Reto');
    expect(fit.sessions.first.exercises.first.sets.length, 2);

    expect(fit.bodyweight.length, 1);
    expect(fit.bodyweight.first.kg, 62.5);

    expect(fit.notesFor('Supino Reto').first.text, 'Fácil, aumentar carga');

    expect(fit.goals.length, 1);
    expect(fit.goals.first.target, 5.0);

    // Verify SQLite table direct state loading matches
    final loadedState = await SqliteStore.instance.loadFullState();
    expect(loadedState['dark'], false);
    expect(loadedState['units'], 'lb');
  });
}
