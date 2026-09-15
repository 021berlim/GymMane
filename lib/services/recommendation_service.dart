import '../catalog/exercise_catalog.dart';
import '../models/exercise.dart';

class RecommendationService {
  static const Map<String, List<String>> _focusToExercises = {
    'hipertrofia': [
      'EIeI8Vf', // Barbell Bench Press
      'qXTaZnJ', // Barbell Full Squat
      'eZyBC3j', // Barbell Bent Over Row
      '25GPyDY', // Barbell Curl
      '3ZflifB', // Cable Pushdown
      'ila4NZS', // Barbell Deadlift
    ],
    'forca': [
      'EIeI8Vf', // Barbell Bench Press
      'qXTaZnJ', // Barbell Full Squat
      'ila4NZS', // Barbell Deadlift
      'Kyd9Rz5', // Barbell Standing Wide Military Press
      'lBDjFxJ', // Pull-up
    ],
    'emagrecimento': [
      'burpee',
      'mountain-climber',
      'jump-rope',
      'I4hDWkc', // Push-up
      '6YUfHPL', // Bodyweight Squat
      'running',
    ],
    'resistencia': [
      'running',
      'cycling',
      'rowing',
      'VBAWRPG', // Weighted Front Plank
      'jumping-jack',
    ],
    'health': [
      'walking',
      'dead-bug',
      'bird-dog',
      '6YUfHPL', // Bodyweight Squat
      'cat-cow-stretch',
      'wall-sit',
    ],
  };

  static List<Exercise> getRecommendations(String focus) {
    final ids = _focusToExercises[focus] ?? _focusToExercises['health']!;
    return kExercises.where((e) => ids.contains(e.id)).toList();
  }
}
