/// Dicionários Anatômicos e Motor de Tradução de Fitness (PT-BR)
class FitnessTranslator {
  FitnessTranslator._();

  static const Map<String, String> bodyPartsPt = {
    'waist': 'Abdômen / Cintura',
    'back': 'Costas',
    'chest': 'Peitoral',
    'upper legs': 'Pernas (Coxas)',
    'upper arms': 'Braços (Bíceps / Tríceps)',
    'shoulders': 'Ombros',
    'lower arms': 'Antebraços',
    'lower legs': 'Panturrilhas',
    'neck': 'Pescoço',
    'cardio': 'Cardio / Aeróbico',
  };

  static const Map<String, String> targetMusclesPt = {
    'abs': 'Abdominais',
    'lats': 'Dorsais (Lats)',
    'pectorals': 'Peitorais',
    'hamstrings': 'Posteriores de Coxa',
    'triceps': 'Tríceps',
    'quads': 'Quadríceps',
    'biceps': 'Bíceps',
    'upper back': 'Costas Superior / Trapézio',
    'glutes': 'Glúteos',
    'delts': 'Deltoides (Ombros)',
    'serratus anterior': 'Serrátil Anterior',
    'forearms': 'Antebraços',
    'calves': 'Panturrilhas',
    'traps': 'Trapézio',
    'adductors': 'Adutores',
    'abductors': 'Abdutores',
    'levator scapulae': 'Elevador da Escápula',
    'spine': 'Eretores da Espinha',
    'cardiovascular system': 'Sistema Cardiovascular',
  };

  static const Map<String, String> secondaryMusclesPt = {
    'hip flexors': 'Flexores do Quadril',
    'lower back': 'Lombar',
    'obliques': 'Oblíquos',
    'rhomboids': 'Romboides',
    'brachialis': 'Braquial',
    'wrist flexors': 'Flexores do Punho',
    'wrist extensors': 'Extensores do Punho',
    'rotator cuff': 'Manguito Rotador',
    'soleus': 'Sóleo',
    'gastrocnemius': 'Gastrocnêmio',
    'core': 'Core',
    'chest': 'Peitoral',
    'shoulders': 'Ombros',
    'biceps': 'Bíceps',
    'triceps': 'Tríceps',
    'glutes': 'Glúteos',
    'hamstrings': 'Posteriores de Coxa',
    'quads': 'Quadríceps',
    'calves': 'Panturrilhas',
    'forearms': 'Antebraços',
    'traps': 'Trapézio',
    'lats': 'Dorsais',
    'abs': 'Abdominais',
    'adductors': 'Adutores',
    'abductors': 'Abdutores',
  };

  static const Map<String, String> equipmentPt = {
    'body weight': 'Peso Corporal',
    'cable': 'Cabo / Polia',
    'leverage machine': 'Máquina com Alavanca',
    'assisted': 'Assistido',
    'medicine ball': 'Medicine Ball',
    'barbell': 'Barra',
    'dumbbell': 'Halteres',
    'ez barbell': 'Barra W (EZ)',
    'kettlebell': 'Kettlebell',
    'olympic barbell': 'Barra Olímpica',
    'weighted': 'Com Carga / Anilha',
    'bosu ball': 'Meia Bola (Bosu)',
    'sled machine': 'Trenó (Sled)',
    'smith machine': 'Máquina Smith',
    'wheel roller': 'Roda Abdominal',
    'trap bar': 'Barra Hexagonal',
    'band': 'Elástico / Faixa',
    'resistance band': 'Faixa Elástica',
    'rope': 'Corda',
    'stability ball': 'Bola Suíça / Pilates',
    'exercise ball': 'Bola de Exercício',
    'stationary bike': 'Bicicleta Ergométrica',
    'upper body ergometer': 'Ergômetro Superior',
    'elliptical machine': 'Elíptico',
    'skierg machine': 'SkiErg',
    'stepmill machine': 'Simulador de Escada',
    'roller': 'Rolo de Liberação',
    'tire': 'Pneu',
    'hammer': 'Marreta',
  };

  static const Map<String, String> difficultyPt = {
    'beginner': 'Iniciante',
    'intermediate': 'Intermediário',
    'advanced': 'Avançado',
  };

  /// Tradução inteligente de títulos de exercícios
  static String translateExerciseName(String enName) {
    var name = enName.trim().toLowerCase();

    final exactMatches = {
      '3/4 sit-up': 'Abdominal 3/4 (Sit-up)',
      '45° side bend': 'Inclinação Lateral 45°',
      'barbell bench press': 'Supino Reto com Barra',
      'dumbbell bench press': 'Supino Reto com Halteres',
      'barbell incline bench press': 'Supino Inclinado com Barra',
      'dumbbell incline bench press': 'Supino Inclinado com Halteres',
      'barbell decline bench press': 'Supino Declinado com Barra',
      'dumbbell decline bench press': 'Supino Declinado com Halteres',
      'cable pushdown': 'Tríceps Pulley na Polia',
      'triceps pushdown': 'Tríceps Pulley',
      'skull crusher': 'Tríceps Testa',
      'lying triceps extension': 'Tríceps Testa Deitado',
      'barbell curl': 'Rosca Direta com Barra',
      'dumbbell biceps curl': 'Rosca Direta com Halteres',
      'dumbbell hammer curl': 'Rosca Martelo com Halteres',
      'preacher curl': 'Rosca Scott',
      'concentration curl': 'Rosca Concentrada',
      'lat pulldown': 'Puxada Alta na Polia',
      'cable seated row': 'Remada Baixa na Polia',
      'barbell bent over row': 'Remada Curvada com Barra',
      'dumbbell bent over row': 'Remada Curvada com Halteres',
      'pull-up': 'Barra Fixa (Pronada)',
      'chin-up': 'Barra Fixa (Supinada)',
      'push-up': 'Flexão de Braço',
      'barbell full squat': 'Agachamento Livre com Barra',
      'bodyweight squat': 'Agachamento Livre Corporal',
      'barbell deadlift': 'Levantamento Terra com Barra',
      'romanian deadlift': 'Levantamento Terra Romeno (Stiff)',
      'stiff leg deadlift': 'Stiff com Barra',
      'barbell standing military press': 'Desenvolvimento Militar com Barra',
      'dumbbell lateral raise': 'Elevação Lateral com Halteres',
      'dumbbell front raise': 'Elevação Frontal com Halteres',
      'standing calf raise': 'Panturrilha em Pé',
      'seated calf raise': 'Panturrilha Sentado',
      'hanging leg raise': 'Elevação de Pernas Suspenso',
      'plank': 'Prancha Abdominal',
      'side plank': 'Prancha Lateral',
      'russian twist': 'Giro Russo (Russian Twist)',
      'bulgarian split squat': 'Agachamento Búlgaro',
      'hip thrust': 'Elevação Pélvica',
      'glute bridge': 'Ponte para Glúteos',
      'face pull': 'Face Pull na Polia',
    };

    if (exactMatches.containsKey(name)) return exactMatches[name]!;

    String eqSuffix = '';
    if (name.startsWith('barbell ')) {
      eqSuffix = ' com Barra';
      name = name.substring('barbell '.length);
    } else if (name.startsWith('dumbbell ')) {
      eqSuffix = ' com Halteres';
      name = name.substring('dumbbell '.length);
    } else if (name.startsWith('cable ')) {
      eqSuffix = ' na Polia';
      name = name.substring('cable '.length);
    } else if (name.startsWith('kettlebell ')) {
      eqSuffix = ' com Kettlebell';
      name = name.substring('kettlebell '.length);
    } else if (name.startsWith('band ') || name.startsWith('resistance band ')) {
      eqSuffix = ' com Elástico';
      name = name.replaceFirst(RegExp(r'^(band|resistance band)\s+'), '');
    } else if (name.startsWith('smith machine ')) {
      eqSuffix = ' no Smith';
      name = name.substring('smith machine '.length);
    } else if (name.startsWith('leverage machine ') || name.startsWith('lever ')) {
      eqSuffix = ' na Máquina';
      name = name.replaceFirst(RegExp(r'^(lever|leverage machine)\s+'), '');
    } else if (name.startsWith('bodyweight ')) {
      eqSuffix = ' Corporal';
      name = name.substring('bodyweight '.length);
    }

    final actions = <RegExp, String>{
      RegExp(r'\bbench press\b'): 'Supino Reto',
      RegExp(r'\bincline bench press\b'): 'Supino Inclinado',
      RegExp(r'\bdecline bench press\b'): 'Supino Declinado',
      RegExp(r'\boverhead press\b'): 'Desenvolvimento',
      RegExp(r'\bshoulder press\b'): 'Desenvolvimento',
      RegExp(r'\bmilitary press\b'): 'Desenvolvimento Militar',
      RegExp(r'\barnold press\b'): 'Desenvolvimento Arnold',
      RegExp(r'\bbiceps curl\b'): 'Rosca Bíceps',
      RegExp(r'\bbicep curl\b'): 'Rosca Bíceps',
      RegExp(r'\bhammer curl\b'): 'Rosca Martelo',
      RegExp(r'\bpreacher curl\b'): 'Rosca Scott',
      RegExp(r'\bcurl\b'): 'Rosca',
      RegExp(r'\btriceps pushdown\b'): 'Tríceps Pulley',
      RegExp(r'\bpushdown\b'): 'Tríceps Pulley',
      RegExp(r'\blying triceps extension\b'): 'Tríceps Testa',
      RegExp(r'\bkickback\b'): 'Tríceps Coice',
      RegExp(r'\blateral raise\b'): 'Elevação Lateral',
      RegExp(r'\bfront raise\b'): 'Elevação Frontal',
      RegExp(r'\brear delt fly\b'): 'Crucifixo Inverso',
      RegExp(r'\bfly\b'): 'Crucifixo',
      RegExp(r'\blat pulldown\b'): 'Puxada Alta',
      RegExp(r'\bpulldown\b'): 'Puxada Alta',
      RegExp(r'\bseated row\b'): 'Remada Sentada',
      RegExp(r'\bbent over row\b'): 'Remada Curvada',
      RegExp(r'\bupright row\b'): 'Remada Alta',
      RegExp(r'\brow\b'): 'Remada',
      RegExp(r'\bshrug\b'): 'Encolhimento de Ombros',
      RegExp(r'\bdeadlift\b'): 'Levantamento Terra',
      RegExp(r'\bsquat\b'): 'Agachamento',
      RegExp(r'\bleg press\b'): 'Leg Press',
      RegExp(r'\bleg extension\b'): 'Cadeira Extensora',
      RegExp(r'\bleg curl\b'): 'Mesa Flexora',
      RegExp(r'\blunge\b'): 'Afundo',
      RegExp(r'\bwalking lunge\b'): 'Avanço Caminhando',
      RegExp(r'\bcalf raise\b'): 'Elevação de Panturrilha',
      RegExp(r'\bhip thrust\b'): 'Elevação Pélvica',
      RegExp(r'\bcrunch\b'): 'Abdominal Supra',
      RegExp(r'\bsit-up\b'): 'Abdominal Sit-up',
      RegExp(r'\bplank\b'): 'Prancha Abdominal',
      RegExp(r'\bpull-up\b'): 'Barra Fixa',
      RegExp(r'\bpush-up\b'): 'Flexão de Braço',
      RegExp(r'\bdip\b'): 'Mergulho nas Paralelas',
    };

    String coreAction = '';
    for (final entry in actions.entries) {
      if (entry.key.hasMatch(name)) {
        coreAction = entry.value;
        name = name.replaceFirst(entry.key, '').trim();
        break;
      }
    }

    if (coreAction.isEmpty) {
      coreAction = enName.isNotEmpty ? enName[0].toUpperCase() + enName.substring(1) : enName;
      return '$coreAction$eqSuffix'.trim();
    }

    final qualifiers = <String>[];
    if (name.contains('seated')) qualifiers.add('Sentado');
    if (name.contains('standing')) qualifiers.add('em Pé');
    if (name.contains('lying')) qualifiers.add('Deitado');
    if (name.contains('incline')) qualifiers.add('Inclinado');
    if (name.contains('decline')) qualifiers.add('Declinado');
    if (name.contains('single arm') || name.contains('one arm')) qualifiers.add('Unilateral');
    if (name.contains('single leg') || name.contains('one leg')) qualifiers.add('Unilateral');
    if (name.contains('close grip')) qualifiers.add('Pegada Fechada');
    if (name.contains('wide grip')) qualifiers.add('Pegada Aberta');

    final qText = qualifiers.isEmpty ? '' : ' ${qualifiers.join(' ')}';
    return '$coreAction$qText$eqSuffix'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Tradução automática das instruções de execução
  static List<String> translateInstructions(List<dynamic> rawSteps) {
    if (rawSteps.isEmpty) return const [];
    return rawSteps.map((s) => _translateSentence(s.toString())).toList();
  }

  static String _translateSentence(String text) {
    var s = text.trim();

    final replacements = <RegExp, String>{
      RegExp(r'Lie flat on your back with your knees bent and feet flat on the ground\.', caseSensitive: false):
          'Deite-se de costas no chão com os joelhos dobrados e os pés apoiados.',
      RegExp(r'Lie flat on a bench with your feet flat on the ground\.', caseSensitive: false):
          'Deite-se no banco reto com os pés firmes no chão.',
      RegExp(r'Stand with your feet shoulder-width apart\.', caseSensitive: false):
          'Fique em pé com os pés afastados na largura dos ombros.',
      RegExp(r'Place your hands behind your head with your elbows pointing outwards\.', caseSensitive: false):
          'Posicione as mãos atrás da cabeça com os cotovelos apontando para fora.',
      RegExp(r'Grasp the barbell with an overhand grip slightly wider than shoulder-width apart\.', caseSensitive: false):
          'Segure a barra com pegada pronada um pouco mais aberta que a largura dos ombros.',
      RegExp(r'Hold a dumbbell in each hand\.', caseSensitive: false):
          'Segure um halter em cada mão.',
      RegExp(r'Slowly lower the (weights|barbell|dumbbells|body) towards your chest\.', caseSensitive: false):
          'Desça lentamente o peso em direção ao peitoral.',
      RegExp(r'Pause for a moment at the top\.', caseSensitive: false):
          'Faça uma breve pausa no topo do movimento.',
      RegExp(r'Pause for a moment at the bottom\.', caseSensitive: false):
          'Faça uma breve pausa no ponto mais baixo.',
      RegExp(r'Repeat for the desired number of repetitions\.', caseSensitive: false):
          'Repita pelo número desejado de repetições.',
      RegExp(r'Engaging your abs, slowly lift your upper body\.', caseSensitive: false):
          'Contraindo o abdômen, levante lentamente a parte superior do tronco.',
      RegExp(r'Keep your back straight and your core engaged\.', caseSensitive: false):
          'Mantenha as costas retas e o abdômen bem contraído.',
      RegExp(r'Exhale as you push and inhale as you return\.', caseSensitive: false):
          'Expire ao empurrar e inspire ao retornar à posição inicial.',
    };

    for (final entry in replacements.entries) {
      if (entry.key.hasMatch(s)) {
        s = s.replaceAll(entry.key, entry.value);
      }
    }
    return s;
  }
}

/// Normalizador de texto para buscas insensíveis a acentos e maiúsculas/minúsculas
String normalizeSearchText(String input) {
  if (input.isEmpty) return '';
  final sb = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    switch (rune) {
      case 224 || 225 || 226 || 227 || 228 || 229 || 257 || 259 || 261:
        sb.write('a');
      case 232 || 233 || 234 || 235 || 275 || 277 || 279 || 281 || 283:
        sb.write('e');
      case 236 || 237 || 238 || 239 || 297 || 299 || 301 || 464:
        sb.write('i');
      case 242 || 243 || 244 || 245 || 246 || 248 || 332 || 334 || 336 || 417:
        sb.write('o');
      case 249 || 250 || 251 || 252 || 361 || 363 || 365 || 367 || 369 || 371:
        sb.write('u');
      case 231 || 263 || 265 || 267 || 269:
        sb.write('c');
      case 241 || 324 || 326 || 328:
        sb.write('n');
      case 253 || 255 || 375:
        sb.write('y');
      default:
        final char = String.fromCharCode(rune);
        if (RegExp(r'[a-z0-9]').hasMatch(char)) {
          sb.write(char);
        } else {
          sb.write(' ');
        }
    }
  }
  return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
