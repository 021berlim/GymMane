import 'dart:math' as math;

const String kDefaultName = 'InlitX';
const String kDefaultHandle = 'inlitx';

class Profile {
  Profile({
    this.name = kDefaultName,
    this.sex = 'male',
    this.age = 28,
    this.heightCm = 175,
    this.weightKg = 75,
    this.activity = 1.55,
    this.weeklyGoal = 4,
    this.photo = '',
    this.trainingFocus = 'health',
    this.handle = '',
    this.badge = 'blue',
    this.banner = '',
    this.since,
    int? recommendationSeed,
  }) : recommendationSeed = recommendationSeed ?? _generateSeed();

  String name;
  String sex;
  int age;
  double heightCm;
  double weightKg;
  double activity;
  int weeklyGoal;
  String photo;
  String trainingFocus;
  String handle;
  String badge;
  String banner;
  DateTime? since;
  int recommendationSeed;

  static int _generateSeed() {
    final r = math.Random();
    return (r.nextInt(1 << 30) ^ DateTime.now().microsecondsSinceEpoch) & 0x7FFFFFFF;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sex': sex,
        'age': age,
        'h': heightCm,
        'w': weightKg,
        'act': activity,
        'goal': weeklyGoal,
        'focus': trainingFocus,
        'recommendationSeed': recommendationSeed,
        if (photo.isNotEmpty) 'photo': photo,
        if (handle.isNotEmpty) 'handle': handle,
        'badge': badge,
        if (banner.isNotEmpty) 'banner': banner,
        if (since != null) 'since': since!.toIso8601String(),
      };
  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: (j['name'] as String?) ?? kDefaultName,
        sex: (j['sex'] as String?) ?? 'male',
        age: (j['age'] as num?)?.toInt() ?? 28,
        heightCm: (j['h'] as num?)?.toDouble() ?? 175,
        weightKg: (j['w'] as num?)?.toDouble() ?? 75,
        activity: (j['act'] as num?)?.toDouble() ?? 1.55,
        weeklyGoal: (j['goal'] as num?)?.toInt() ?? 4,
        trainingFocus: (j['focus'] as String?) ?? 'health',
        photo: (j['photo'] as String?) ?? '',
        handle: (j['handle'] as String?) ?? '',
        badge: (j['badge'] as String?) ?? 'blue',
        banner: (j['banner'] as String?) ?? '',
        since: DateTime.tryParse((j['since'] as String?) ?? ''),
        recommendationSeed: (j['recommendationSeed'] ?? j['seed'] as num?)?.toInt(),
      );
}
