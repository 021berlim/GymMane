/// Dicionários Anatômicos e Motor de Tradução Taxonômico de Fitness (PT-BR Autêntico)
class FitnessTranslator {
  FitnessTranslator._();

  static const Map<String, String> bodyPartsPt = {
    'waist': 'Abdômen',
    'back': 'Costas',
    'chest': 'Peitoral',
    'upper legs': 'Pernas (Coxas)',
    'lower legs': 'Panturrilhas',
    'shoulders': 'Ombros',
    'upper arms': 'Braços',
    'lower arms': 'Antebraços',
    'neck': 'Pescoço',
    'cardio': 'Cardio / Aeróbico',
  };

  static const Map<String, String> targetMusclesPt = {
    'abs': 'Abdominais',
    'lats': 'Dorsais / Grande Dorsal',
    'pectorals': 'Peitoral Maior',
    'hamstrings': 'Posteriores de Coxa',
    'quads': 'Quadríceps',
    'glutes': 'Glúteos',
    'delts': 'Deltoides',
    'traps': 'Trapézio',
    'triceps': 'Tríceps',
    'biceps': 'Bíceps',
    'upper back': 'Costas Superior / Trapézio',
    'serratus anterior': 'Serrátil Anterior',
    'forearms': 'Antebraços',
    'calves': 'Panturrilhas',
    'adductors': 'Adutores',
    'abductors': 'Abdutores',
    'levator scapulae': 'Elevador da Escápula',
    'spine': 'Eretores da Espinha',
    'cardiovascular system': 'Sistema Cardiovascular',
  };

  static const Map<String, String> secondaryMusclesPt = {
    // Músculos base
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

    // Inclusão mandatória dos 50 músculos auditados pela SBA e Agente 5:
    'abdominals': 'Abdominais',
    'ankle stabilizers': 'Estabilizadores do Tornozelo',
    'ankles': 'Tornozelos',
    'back': 'Costas',
    'deep cervical flexors': 'Flexores Cervicais Profundos',
    'deltoids': 'Deltoides',
    'delts': 'Deltoides',
    'extensor digitorum longus': 'Extensor Longo dos Dedos',
    'extensor hallucis longus': 'Extensor Longo do Hálux',
    'feet': 'Pés',
    'flexor digitorum longus': 'Flexor Longo dos Dedos',
    'flexor hallucis longus': 'Flexor Longo do Hálux',
    'gemellus superior/inferior': 'Gêmeos Pélvicos (Superior e Inferior)',
    'gluteus medius': 'Glúteo Médio',
    'gluteus medius (posterior fibers)': 'Glúteo Médio (Fibras Posteriores)',
    'gluteus minimus': 'Glúteo Mínimo',
    'grip muscles': 'Músculos da Pegada (Preensão)',
    'groin': 'Adutores da Coxa (Virilha)',
    'hands': 'Mãos',
    'inner thighs': 'Adutores da Coxa (Parte Interna)',
    'latissimus dorsi': 'Grande Dorsal (Dorsais)',
    'levator scapulae': 'Elevador da Escápula',
    'longus capitis': 'Longo da Cabeça',
    'longus colli': 'Longo do Pescoço',
    'lower abs': 'Abdominal Infra (Inferior)',
    'obturator internus': 'Obturador Interno',
    'obturator internus/externus': 'Obturador Interno e Externo',
    'pectorals': 'Peitorais',
    'peroneus brevis': 'Fibular Curto',
    'peroneus longus': 'Fibular Longo',
    'peroneus tertius': 'Fibular Terceiro',
    'piriformis': 'Piriforme',
    'quadriceps': 'Quadríceps',
    'rear deltoids': 'Deltoide Posterior',
    'scalenes': 'Escalenos',
    'semispinalis capitis': 'Semiespinal da Cabeça',
    'serratus anterior': 'Serrátil Anterior',
    'shins': 'Tibiais (Canelas)',
    'spine': 'Eretores da Espinha',
    'splenius capitis': 'Esplênio da Cabeça',
    'splenius cervicis': 'Esplênio do Pescoço',
    'sternocleidomastoid': 'Esternocleidomastoideo',
    'suboccipitals': 'Suboccipitais',
    'tibialis anterior': 'Tibial Anterior',
    'tibialis posterior': 'Tibial Posterior',
    'trapezius': 'Trapézio',
    'upper back': 'Costas Superior / Trapézio',
    'upper chest': 'Peitoral Superior (Clavicular)',
    'upper trapezius': 'Trapézio Superior',
    'wrists': 'Punhos',
  };

  static const Map<String, String> equipmentPt = {
    'body weight': 'Peso Corporal',
    'cable': 'Polia / Cabo',
    'leverage machine': 'Máquina Articulada',
    'assisted': 'Graviton / Assistido',
    'assisted (towel)': 'Assistido com Toalha',
    'medicine ball': 'Medicine Ball',
    'barbell': 'Barra',
    'dumbbell': 'Halter',
    'ez barbell': 'Barra W',
    'kettlebell': 'Kettlebell',
    'olympic barbell': 'Barra Olímpica',
    'weighted': 'Com Carga Adicional',
    'bosu ball': 'Bosu',
    'sled machine': 'Trenó (Sled)',
    'smith machine': 'Smith',
    'wheel roller': 'Roda Abdominal',
    'trap bar': 'Barra Hexagonal',
    'band': 'Elástico',
    'resistance band': 'Faixa Elástica',
    'body weight (with resistance band)': 'Peso Corporal com Faixa Elástica',
    'rope': 'Corda',
    'stability ball': 'Bola Suíça',
    'exercise ball': 'Bola Suíça',
    'dumbbell, exercise ball': 'Halter e Bola Suíça',
    'ez barbell, exercise ball': 'Barra W e Bola Suíça',
    'dumbbell, exercise ball, tennis ball': 'Halter e Bola Suíça',
    'dumbbell (used as handles for deeper range)': 'Halter como Apoio',
    'stationary bike': 'Bicicleta Ergométrica',
    'upper body ergometer': 'Cicloergômetro de Braço',
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

  /// Mapeamento canônico da musculação brasileira (desambiguação exata)
  static final Map<String, String> _canonicalExact = {
    // Abdominais e Core
    '3/4 sit-up': 'Abdominal 3/4 (Sit-up)',
    '45° side bend': 'Inclinação Lateral 45°',
    'hanging leg raise': 'Elevação de Pernas Suspenso',
    'hanging knee raise': 'Elevação de Joelhos Suspenso',
    'lying leg raise': 'Elevação de Pernas Deitado',
    'plank': 'Prancha Abdominal',
    'side plank': 'Prancha Lateral',
    'russian twist': 'Giro Russo (Russian Twist)',
    'ab roller': 'Abdominal com Roda (Ab Wheel)',
    'wheel roller crunch': 'Abdominal com Roda',
    'jackknife sit-up': 'Abdominal Canivete (Jackknife)',
    'janda sit-up': 'Abdominal Janda',
    'cross body crunch': 'Abdominal Cruzado (Oblíquos)',
    'bicycle crunch': 'Abdominal Bicicleta',
    'reverse crunch': 'Abdominal Infra (Invertido)',
    'cable crunch': 'Abdominal na Polia Alta (Cable Crunch)',
    'dead bug': 'Bicho Morto (Dead Bug)',
    'bird dog': 'Perdigueiro (Bird Dog)',
    'potty squat': 'Agachamento Profundo Corporal',

    // Supinos e Peitoral
    'barbell bench press': 'Supino Reto com Barra',
    'dumbbell bench press': 'Supino Reto com Halteres',
    'barbell incline bench press': 'Supino Inclinado com Barra',
    'dumbbell incline bench press': 'Supino Inclinado com Halteres',
    'barbell decline bench press': 'Supino Declinado com Barra',
    'dumbbell decline bench press': 'Supino Declinado com Halteres',
    'smith machine bench press': 'Supino Reto no Smith',
    'smith machine incline bench press': 'Supino Inclinado no Smith',
    'smith machine decline bench press': 'Supino Declinado no Smith',
    'close-grip bench press': 'Supino com Pegada Fechada',
    'close grip bench press': 'Supino com Pegada Fechada',
    'barbell close grip bench press': 'Supino Fechado com Barra',
    'reverse grip bench press': 'Supino com Pegada Invertida',
    'cable crossover': 'Crossover na Polia',
    'cable cross-over': 'Crossover na Polia',
    'pec deck': 'Peck Deck (Voador)',
    'butterfly': 'Voador / Borboleta',
    'cable fly': 'Crucifixo na Polia',
    'dumbbell fly': 'Crucifixo Reto com Halteres',
    'incline dumbbell fly': 'Crucifixo Inclinado com Halteres',
    'decline dumbbell fly': 'Crucifixo Declinado com Halteres',
    'pullover': 'Pullover com Halter',
    'dumbbell pullover': 'Pullover com Halter',
    'barbell pullover': 'Pullover com Barra',
    'push-up': 'Flexão de Braço',
    'diamond push-up': 'Flexão Diamante',
    'close-grip push-up': 'Flexão com Pegada Fechada',
    'handstand push-up': 'Flexão na Parada de Mão (Handstand)',
    'decline push-up': 'Flexão Declinada (Pés Elevados)',
    'incline push-up': 'Flexão Inclinada (Mãos Elevadas)',
    'clock push-up': 'Flexão Relógio (Clock Push-up)',
    'outside leg kick push-up': 'Flexão com Chute Lateral',
    'push-up (wall)': 'Flexão na Parede',
    'push-up (wall) v. 2': 'Flexão na Parede (Variação 2)',
    'plyo push-up': 'Flexão Pliométrica (com Palmas)',
    'clap push-up': 'Flexão com Palma (Clap Push-up)',
    'spiderman push-up': 'Flexão Homem-Aranha (Spiderman)',
    'archer push-up': 'Flexão Arqueiro',
    'pike push-up': 'Flexão Pike para Ombros',
    'hindu push-up': 'Flexão Hindu (Mergulho)',
    'pseudo planche push-up': 'Flexão Pseudo Planche',
    'push-up to side plank': 'Flexão com Transição para Prancha Lateral',

    // Paralelas e Tríceps
    'dip': 'Mergulho nas Paralelas',
    'triceps dip': 'Mergulho nas Paralelas (Tríceps)',
    'bench dip': 'Mergulho no Banco',
    'bench dip (knees bent)': 'Mergulho no Banco com Joelhos Flexionados',
    'triceps dip (bench leg)': 'Mergulho no Banco com Pernas Apoiadas',
    'triceps dip (between benches)': 'Mergulho entre Bancos',
    'assisted triceps dip (kneeling)': 'Mergulho no Graviton Ajoelhado',
    'assisted chest dip (kneeling)': 'Mergulho para Peitoral no Graviton',
    'cable pushdown': 'Tríceps Pulley na Polia',
    'triceps pushdown': 'Tríceps Pulley',
    'cable rope pushdown': 'Tríceps Corda na Polia',
    'rope pushdown': 'Tríceps Corda na Polia',
    'cable pushdown (with rope attachment)': 'Tríceps Corda na Polia',
    'cable pushdown (straight arm)': 'Pulldown na Polia (Braços Estendidos)',
    'cable pushdown (straight arm) v. 2': 'Pulldown na Polia com Barra Reta',
    'cable reverse-grip pushdown': 'Tríceps Pulley com Pegada Invertida',
    'skull crusher': 'Tríceps Testa com Barra',
    'barbell skull crusher': 'Tríceps Testa com Barra',
    'ez barbell skull crusher': 'Tríceps Testa com Barra W',
    'lying triceps extension': 'Tríceps Testa Deitado',
    'dumbbell lying triceps extension': 'Tríceps Testa com Halteres',
    'dumbbell overhead triceps extension': 'Tríceps Francês com Halter',
    'cable overhead triceps extension': 'Tríceps Francês na Polia',
    'kickback': 'Tríceps Coice com Halter',
    'dumbbell kickback': 'Tríceps Coice com Halter',
    'cable kickback': 'Tríceps Coice na Polia',
    'tate press': 'Tríceps Tate Press com Halteres',

    // Bíceps e Antebraço
    'barbell curl': 'Rosca Direta com Barra',
    'ez barbell curl': 'Rosca Direta com Barra W',
    'dumbbell biceps curl': 'Rosca Direta com Halteres',
    'dumbbell alternate biceps curl': 'Rosca Alternada com Halteres',
    'dumbbell hammer curl': 'Rosca Martelo com Halteres',
    'incline dumbbell curl': 'Rosca no Banco Inclinado com Halteres',
    'preacher curl': 'Rosca Scott',
    'barbell preacher curl': 'Rosca Scott com Barra',
    'ez barbell preacher curl': 'Rosca Scott com Barra W',
    'dumbbell preacher curl': 'Rosca Scott com Halter',
    'concentration curl': 'Rosca Concentrada com Halter',
    'dumbbell concentration curl': 'Rosca Concentrada com Halter',
    'spider curl': 'Rosca Spider com Barra',
    'dumbbell spider curl': 'Rosca Spider com Halteres',
    'barbell drag curl': 'Rosca Drag com Barra',
    'reverse curl': 'Rosca Inversa',
    'barbell reverse curl': 'Rosca Inversa com Barra',
    'ez barbell reverse curl': 'Rosca Inversa com Barra W',
    'wrist curl': 'Rosca Punho',
    'barbell wrist curl': 'Rosca Punho com Barra',
    'dumbbell wrist curl': 'Rosca Punho com Halteres',
    'barbell reverse wrist curl': 'Rosca Punho Inversa com Barra',
    'barbell reverse wrist curl v. 2': 'Rosca Punho Inversa com Barra (Variação 2)',
    'cable curl': 'Rosca na Polia',
    'cable reverse curl': 'Rosca Inversa na Polia',
    'cable wrist curl': 'Rosca Punho na Polia',
    'cable reverse wrist curl': 'Rosca Punho Inversa na Polia',

    // Costas e Puxadas
    'lat pulldown': 'Puxada Alta na Polia',
    'cable lat pulldown': 'Puxada Alta na Polia',
    'wide grip lat pulldown': 'Puxada Alta com Pegada Aberta',
    'cable wide grip lat pulldown': 'Puxada Alta com Pegada Aberta na Polia',
    'close grip lat pulldown': 'Puxada Alta com Triângulo (Pegada Fechada)',
    'v-bar lat pulldown': 'Puxada Alta com Triângulo (Barra V)',
    'reverse grip lat pulldown': 'Puxada Alta com Pegada Supinada',
    'underhand lat pulldown': 'Puxada Alta Supinada',
    'straight arm pulldown': 'Pulldown na Polia (Braços Estendidos)',
    'behind neck lat pulldown': 'Puxada Alta Atrás da Nuca',
    'cable bar lateral pulldown': 'Puxada Alta com Barra na Polia',
    'cable cross-over lateral pulldown': 'Puxada Alta Cruzada na Polia (Crossover Pulldown)',
    'cable pulldown (pro lat bar)': 'Puxada Alta com Barra Pro Lat',
    'cable seated row': 'Remada Baixa na Polia',
    'barbell bent over row': 'Remada Curvada com Barra',
    'dumbbell bent over row': 'Remada Curvada com Halteres',
    't-bar row': 'Remada Cavalinho (Barra T)',
    'barbell t-bar row': 'Remada Cavalinho com Barra',
    'dumbbell one arm bent-over row': 'Remada Unilateral com Halter (Serrote)',
    'one arm dumbbell row': 'Remada Unilateral com Halter (Serrote)',
    'inverted row': 'Remada Invertida (Peso Corporal)',
    'inverted row v. 2': 'Remada Invertida com Pés Elevados',
    'inverted row with straps': 'Remada Invertida nas Fitas de Suspensão (TRX)',
    'smith narrow row': 'Remada com Pegada Fechada no Smith',
    'cable high row (kneeling)': 'Remada Alta na Polia Ajoelhado',
    'cable rear delt row (stirrups)': 'Remada Posterior com Estribos na Polia',
    'cable rear delt row (with rope)': 'Remada Posterior com Corda na Polia',
    'cable palm rotational row': 'Remada com Rotação de Punho na Polia',
    'cable upper row': 'Remada Alta na Polia',
    'pull-up': 'Barra Fixa (Pronada)',
    'chin-up': 'Barra Fixa (Supinada)',
    'assisted pull-up': 'Barra Fixa no Graviton',
    'biceps pull-up': 'Barra Fixa com Pegada Fechada (Bíceps Pull-up)',
    'scapular pull-up': 'Elevação Escapular na Barra Fixa',
    'rear pull-up': 'Barra Fixa Atrás da Nuca',
    'reverse grip pull-up': 'Barra Fixa com Pegada Supinada',

    // Pernas, Glúteos e Agachamentos
    'barbell full squat': 'Agachamento Livre com Barra',
    'barbell squat': 'Agachamento Livre com Barra',
    'bodyweight squat': 'Agachamento Livre Corporal',
    'dumbbell goblet squat': 'Agachamento Taça (Goblet) com Halter',
    'smith machine squat': 'Agachamento no Smith',
    'smith squat': 'Agachamento no Smith',
    'smith chair squat': 'Agachamento Cadeira no Smith',
    'smith low bar squat': 'Agachamento Barra Baixa no Smith',
    'smith full squat': 'Agachamento Completo no Smith',
    'bulgarian split squat': 'Agachamento Búlgaro com Halteres',
    'hack squat': 'Agachamento Hack',
    'sled hack squat': 'Agachamento Hack no Trenó',
    'sled closer hack squat': 'Agachamento Hack com Pés Fechados',
    'front squat': 'Agachamento Frontal com Barra',
    'barbell front squat': 'Agachamento Frontal com Barra',
    'barbell front chest squat': 'Agachamento Frontal no Peito com Barra',
    'barbell clean-grip front squat': 'Agachamento Frontal com Pegada de Clean',
    'barbell bench squat': 'Agachamento com Barra até o Banco',
    'barbell bench front squat': 'Agachamento Frontal no Banco com Barra',
    'barbell jefferson squat': 'Agachamento Jefferson com Barra',
    'barbell speed squat': 'Agachamento de Velocidade com Barra',
    'barbell side split squat': 'Agachamento Lateral (Side Split) com Barra',
    'barbell side split squat v. 2': 'Agachamento Lateral com Barra (Variação 2)',
    'barbell split squat (version 2)': 'Agachamento Split com Barra',
    'barbell low bar squat': 'Agachamento Livre Barra Baixa (Low Bar)',
    'barbell high bar squat': 'Agachamento Livre Barra Alta (High Bar)',
    'barbell wide squat': 'Agachamento com Base Aberta e Barra',
    'barbell squat (on knees)': 'Agachamento de Joelhos com Barra',
    'sumo squat': 'Agachamento Sumô',
    'dumbbell sumo squat': 'Agachamento Sumô com Halter',
    'barbell sumo squat': 'Agachamento Sumô com Barra',
    'jump squat': 'Agachamento com Salto (Jump Squat)',
    'jump squat v. 2': 'Agachamento com Salto Pliométrico',
    'sissy squat': 'Agachamento Sissy',
    'zercher squat': 'Agachamento Zercher com Barra',
    'box squat': 'Agachamento na Caixa (Box Squat)',
    'pistol squat': 'Agachamento Pistola (Pistol Squat Unilateral)',
    'squat jerk': 'Squat Jerk (Arremesso em Agachamento)',
    'squat to overhead reach': 'Agachamento com Extensão dos Braços',
    'frankenstein squat': 'Agachamento Frankenstein (Braços Estendidos)',
    'semi squat jump (male)': 'Meio Agachamento com Salto',
    'potty squat with support': 'Agachamento Profundo com Apoio',
    'quads (bodyweight squat)': 'Agachamento Livre Corporal (Ênfase em Quadríceps)',
    'dumbbell plyo squat': 'Agachamento Pliométrico com Halteres',
    'dumbbell supported squat': 'Agachamento Apoiado com Halteres',
    'dumbbell biceps curl squat': 'Agachamento com Rosca Bíceps e Halteres',

    // Supinos e Peitoral Específicos
    'barbell guillotine bench press': 'Supino Guilhotina com Barra',
    'barbell jm bench press': 'Supino JM Press com Barra',
    'barbell wide bench press': 'Supino Reto com Pegada Aberta e Barra',
    'chest press': 'Supino Máquina Sentado',
    'lever seated chest press': 'Supino Reto Sentado na Máquina Articulada',

    // Puxadas e Remadas Específicas
    'cable pulldown': 'Puxada Alta na Polia',
    'cable rear pulldown': 'Puxada Alta Atrás da Nuca na Polia',
    'cable lat pulldown full range of motion': 'Puxada Alta com Amplitude Máxima',
    'cable lateral pulldown with v-bar': 'Puxada Alta com Barra V na Polia',
    'cable overhead curl': 'Rosca Bíceps na Polia Alta (Duplo Bíceps)',
    'cable squatting curl': 'Rosca em Agachamento na Polia',
    'cable assisted inverse leg curl': 'Flexão Nórdica Assistida na Polia',
    'cable triceps pushdown (v-bar)': 'Tríceps Pulley com Barra V na Polia',
    'cable triceps pushdown (v-bar) (with arm blaster)': 'Tríceps Pulley com Barra V e Arm Blaster',

    // Leg Press e Panturrilha
    'sled calf press on leg press': 'Panturrilha no Leg Press 45°',
    'sled 45 degrees one leg press': 'Leg Press 45° Unilateral',
    'sled 45° leg press (side pov)': 'Leg Press 45° no Trenó',
    'sled 45° leg press (back pov)': 'Leg Press 45° no Trenó (Visão Posterior)',

    // Roscas
    'dumbbell preacher hammer curl': 'Rosca Martelo no Banco Scott',
    'dumbbell prone incline curl': 'Rosca no Banco Inclinado em Decúbito Ventral',
    'dumbbell rear lateral raise': 'Crucifixo Inverso com Halteres (Posterior de Ombro)',
    'dumbbell rear lateral raise (support head)': 'Crucifixo Inverso com Apoio de Cabeça',
    'dumbbell full can lateral raise': 'Elevação Lateral Full Can com Halteres',
    'dumbbell lateral to front raise': 'Elevação Lateral Combinada com Frontal',

    // Flexões Específicas
    'push-up inside leg kick': 'Flexão com Chute Cruzado',
    'push-up medicine ball': 'Flexão com Apoio na Medicine Ball',
    'shoulder tap push-up': 'Flexão com Toque no Ombro',
    'chest dip on straight bar': 'Mergulho na Barra Reta (Straight Bar Dip)',
    'side push-up': 'Flexão Lateral',
    'superman push-up': 'Flexão Superman',
    'suspended push-up': 'Flexão Suspensa no TRX',

    // Abdominais Específicos
    'tuck crunch': 'Abdominal Tuck Crunch',
    'groin crunch': 'Abdominal com Pernas em Borboleta',
    'negative crunch': 'Abdominal Negativo (Fase Excêntrica)',
    'quarter sit-up': 'Abdominal Quarto de Subida (Quarter Sit-up)',
    'half sit-up (male)': 'Meio Abdominal Sit-up',
    'prisoner half sit-up (male)': 'Meio Abdominal Prisioneiro',
    'captains chair straight leg raise': 'Elevação de Pernas na Cadeira do Capitão',
    'vertical leg raise (on parallel bars)': 'Elevação de Pernas nas Barras Paralelas',

    // Remadas e Máquinas Específicas
    'lever gripless shrug': 'Encolhimento sem Pegada na Máquina (Apoio nos Ombros)',
    'lever gripless shrug v. 2': 'Encolhimento sem Pegada na Máquina (Variação 2)',
    'lever shrug': 'Encolhimento de Ombros na Máquina Articulada',
    'lever t bar row': 'Remada Cavalinho na Máquina Articulada',
    'lever high row': 'Remada Alta na Máquina Articulada',
    'lever unilateral row': 'Remada Unilateral na Máquina Articulada',
    'cable straight back seated row': 'Remada Baixa com Coluna Reta na Polia',
    'cable low seated row': 'Remada Baixa na Polia com Puxador',
    'barbell upright row v. 2': 'Remada Alta com Barra (Pegada Aberta)',
    'barbell upright row v. 3': 'Remada Alta com Barra (Pegada Fechada)',
    'barbell bent arm pullover': 'Pullover com Barra e Braços Flexionados',
    'barbell pullover to press': 'Pullover Combinado com Supino e Barra',
    'barbell lateral lunge': 'Afundo Lateral com Barra',
    'barbell rear lunge': 'Afundo para Trás (Reverse Lunge) com Barra',
    'barbell rear lunge v. 2': 'Afundo para Trás com Barra (Variação 2)',
    'barbell full squat (side pov)': 'Agachamento Livre com Barra (Vista Lateral)',
    'barbell squat jump step rear lunge': 'Agachamento com Salto e Afundo com Barra',

    // Roscas e Ombros Específicos
    'dumbbell zottman preacher curl': 'Rosca Scott Zottman com Halteres',
    'dumbbell reverse preacher curl': 'Rosca Scott Inversa com Halteres',
    'dumbbell preacher curl over exercise ball': 'Rosca Scott com Halter na Bola Suíça',
    'dumbbell seated one leg calf raise - hammer grip': 'Panturrilha Sentado Unilateral com Halter (Pegada Neutra)',
    'dumbbell seated one leg calf raise - palm up': 'Panturrilha Sentado Unilateral com Halter (Palma para Cima)',
    'dumbbell seated shoulder press (parallel grip)': 'Desenvolvimento Sentado com Halteres (Pegada Neutra)',
    'dumbbell seated bent arm lateral raise': 'Elevação Lateral Sentado com Braços Dobrados',
    'dumbbell rotation reverse fly': 'Crucifixo Inverso com Rotação de Punho',

    'barbell deadlift': 'Levantamento Terra com Barra',
    'deadlift': 'Levantamento Terra',
    'sumo deadlift': 'Levantamento Terra Sumô',
    'romanian deadlift': 'Levantamento Terra Romeno (RDL)',
    'stiff leg deadlift': 'Stiff com Barra',
    'dumbbell romanian deadlift': 'Stiff com Halteres',
    'dumbbell stiff leg deadlift': 'Stiff com Halteres',
    'hip thrust': 'Elevação Pélvica com Barra',
    'barbell hip thrust': 'Elevação Pélvica com Barra',
    'glute bridge': 'Ponte para Glúteos',
    'leg press': 'Leg Press 45°',
    'sled 45° leg press': 'Leg Press 45° no Trenó',
    'horizontal leg press': 'Leg Press Horizontal',
    'leg extension': 'Cadeira Extensora',
    'seated leg curl': 'Cadeira Flexora',
    'lying leg curl': 'Mesa Flexora',
    'standing leg curl': 'Flexora em Pé',
    'self assisted inverse leg curl': 'Flexão Nórdica Assistida',
    'standing calf raise': 'Panturrilha em Pé',
    'seated calf raise': 'Panturrilha Sentado (Gêmeos)',
    'donkey calf raise': 'Panturrilha Burrinho (Donkey)',
    'weighted donkey calf raise': 'Panturrilha Burrinho com Carga',
    'exercise ball on the wall calf raise': 'Panturrilha na Parede com Bola Suíça',
    'sled forward angled calf raise': 'Panturrilha Inclinada no Leg Press / Trenó',
    'dumbbell lunge': 'Afundo com Halteres',
    'dumbbell rear lunge': 'Afundo para Trás com Halteres',
    'dumbbell step up lunge': 'Subida no Banco com Afundo e Halteres',
    'walking lunge': 'Passada (Avanço Caminhando)',
    'forward lunge (male)': 'Avanço / Afundo para Frente',
    'lunge with twist': 'Avanço com Rotação de Tronco',

    // Ombros e Trapézio
    'barbell standing military press': 'Desenvolvimento Militar com Barra',
    'standing military press': 'Desenvolvimento Militar em Pé',
    'overhead press': 'Desenvolvimento para Ombros com Barra',
    'dumbbell shoulder press': 'Desenvolvimento com Halteres',
    'arnold press': 'Desenvolvimento Arnold com Halteres',
    'dumbbell lateral raise': 'Elevação Lateral com Halteres',
    'cable lateral raise': 'Elevação Lateral na Polia',
    'dumbbell front raise': 'Elevação Frontal com Halteres',
    'barbell front raise': 'Elevação Frontal com Barra',
    'rear delt fly': 'Crucifixo Inverso',
    'reverse fly': 'Crucifixo Inverso com Halteres',
    'face pull': 'Face Pull na Polia',
    'cable face pull': 'Face Pull na Polia',
    'shrug': 'Encolhimento de Ombros',
    'dumbbell shrug': 'Encolhimento com Halteres',
    'barbell shrug': 'Encolhimento com Barra',
    'smith machine shrug': 'Encolhimento no Smith',
  };

  /// Tradução inteligente de títulos de exercícios
  static String translateExerciseName(String enName) {
    final lower = enName.trim().toLowerCase();
    if (_canonicalExact.containsKey(lower)) {
      return _canonicalExact[lower]!;
    }

    var working = lower;

    // Prefixo de Equipamento
    String equipStr = '';
    if (working.startsWith('barbell ')) {
      equipStr = 'com Barra';
      working = working.substring('barbell '.length);
    } else if (working.startsWith('olympic barbell ')) {
      equipStr = 'com Barra Olímpica';
      working = working.substring('olympic barbell '.length);
    } else if (working.startsWith('ez barbell ')) {
      equipStr = 'com Barra W';
      working = working.substring('ez barbell '.length);
    } else if (working.startsWith('dumbbell ')) {
      equipStr = 'com Halteres';
      working = working.substring('dumbbell '.length);
    } else if (working.startsWith('cable ')) {
      equipStr = 'na Polia';
      working = working.substring('cable '.length);
    } else if (working.startsWith('smith machine ')) {
      equipStr = 'no Smith';
      working = working.substring('smith machine '.length);
    } else if (working.startsWith('smith ')) {
      equipStr = 'no Smith';
      working = working.substring('smith '.length);
    } else if (working.startsWith('leverage machine ') || working.startsWith('lever ')) {
      equipStr = 'na Máquina Articulada';
      working = working.replaceFirst(RegExp(r'^(lever|leverage machine)\s+'), '');
    } else if (working.startsWith('sled machine ') || working.startsWith('sled ')) {
      equipStr = 'no Trenó (Sled)';
      working = working.replaceFirst(RegExp(r'^(sled machine|sled)\s+'), '');
    } else if (working.startsWith('kettlebell ')) {
      equipStr = 'com Kettlebell';
      working = working.substring('kettlebell '.length);
    } else if (working.startsWith('band ') || working.startsWith('resistance band ')) {
      equipStr = 'com Elástico';
      working = working.replaceFirst(RegExp(r'^(band|resistance band)\s+'), '');
    } else if (working.startsWith('bodyweight ') || working.startsWith('body weight ')) {
      equipStr = 'Corporal';
      working = working.replaceFirst(RegExp(r'^(bodyweight|body weight)\s+'), '');
    } else if (working.startsWith('assisted ')) {
      equipStr = 'Assistido';
      working = working.substring('assisted '.length);
    } else if (working.startsWith('weighted ')) {
      equipStr = 'com Carga Adicional';
      working = working.substring('weighted '.length);
    } else if (working.startsWith('wheel roller ') || working.startsWith('roller wheel ')) {
      equipStr = 'com Roda Abdominal';
      working = working.replaceFirst(RegExp(r'^(wheel roller|roller wheel)\s+'), '');
    } else if (working.startsWith('medicine ball ')) {
      equipStr = 'com Medicine Ball';
      working = working.substring('medicine ball '.length);
    } else if (working.startsWith('stability ball ') || working.startsWith('exercise ball ')) {
      equipStr = 'na Bola Suíça';
      working = working.replaceFirst(RegExp(r'^(stability ball|exercise ball)\s+'), '');
    } else if (working.startsWith('bosu ball ') || working.startsWith('bosu ')) {
      equipStr = 'no Bosu';
      working = working.replaceFirst(RegExp(r'^(bosu ball|bosu)\s+'), '');
    }

    if (_canonicalExact.containsKey(working)) {
      final base = _canonicalExact[working]!;
      if (equipStr.isNotEmpty &&
          !base.toLowerCase().contains(equipStr
              .toLowerCase()
              .replaceAll('com ', '')
              .replaceAll('na ', '')
              .replaceAll('no ', ''))) {
        return '$base $equipStr'.trim();
      }
      return base;
    }

    final actions = <RegExp, String>{
      RegExp(r'\bincline bench press\b'): 'Supino Inclinado',
      RegExp(r'\bdecline bench press\b'): 'Supino Declinado',
      RegExp(r'\bbench press\b'): 'Supino Reto',
      RegExp(r'\bchest press\b'): 'Supino Reto na Máquina',
      RegExp(r'\bfloor press\b'): 'Supino no Chão (Floor Press)',
      RegExp(r'\boverhead press\b'): 'Desenvolvimento para Ombros',
      RegExp(r'\bshoulder press\b'): 'Desenvolvimento para Ombros',
      RegExp(r'\bmilitary press\b'): 'Desenvolvimento Militar',
      RegExp(r'\barnold press\b'): 'Desenvolvimento Arnold',
      RegExp(r'\bpush press\b'): 'Push Press',

      RegExp(r'\bgoblet squat\b'): 'Agachamento Taça (Goblet)',
      RegExp(r'\bfront squat\b'): 'Agachamento Frontal',
      RegExp(r'\bhack squat\b'): 'Agachamento Hack',
      RegExp(r'\bbulgarian split squat\b'): 'Agachamento Búlgaro',
      RegExp(r'\bsplit squat\b'): 'Agachamento Búlgaro / Unilateral',
      RegExp(r'\bsumo squat\b'): 'Agachamento Sumô',
      RegExp(r'\bjump squat\b'): 'Agachamento com Salto',
      RegExp(r'\bbox squat\b'): 'Agachamento na Caixa',
      RegExp(r'\boverhead squat\b'): 'Agachamento com Barra Acima da Cabeça',
      RegExp(r'\bsissy squat\b'): 'Agachamento Sissy',
      RegExp(r'\bzercher squat\b'): 'Agachamento Zercher',
      RegExp(r'\bpistol squat\b'): 'Agachamento Pistola Unilateral',
      RegExp(r'\bsquat\b'): 'Agachamento',

      RegExp(r'\bromanian deadlift\b'): 'Levantamento Terra Romeno (RDL)',
      RegExp(r'\bstiff leg deadlift\b'): 'Stiff',
      RegExp(r'\bsumo deadlift\b'): 'Levantamento Terra Sumô',
      RegExp(r'\bdeadlift\b'): 'Levantamento Terra',

      RegExp(r'\bhammer curl\b'): 'Rosca Martelo',
      RegExp(r'\bpreacher curl\b'): 'Rosca Scott',
      RegExp(r'\bconcentration curl\b'): 'Rosca Concentrada',
      RegExp(r'\bspider curl\b'): 'Rosca Spider',
      RegExp(r'\bdrag curl\b'): 'Rosca Drag',
      RegExp(r'\breverse wrist curl\b'): 'Rosca Punho Inversa',
      RegExp(r'\bwrist curl\b'): 'Rosca Punho',
      RegExp(r'\breverse curl\b'): 'Rosca Inversa',
      RegExp(r'\bbiceps curl\b'): 'Rosca Bíceps',
      RegExp(r'\bbicep curl\b'): 'Rosca Bíceps',
      RegExp(r'\bcurl\b'): 'Rosca',

      RegExp(r'\blyng triceps extension\b'): 'Tríceps Testa',
      RegExp(r'\blying triceps extension\b'): 'Tríceps Testa',
      RegExp(r'\boverhead triceps extension\b'): 'Tríceps Francês',
      RegExp(r'\btriceps extension\b'): 'Extensão de Tríceps',
      RegExp(r'\btriceps pushdown\b'): 'Tríceps Pulley',
      RegExp(r'\bpushdown\b'): 'Tríceps Pulley',
      RegExp(r'\bkickback\b'): 'Tríceps Coice',
      RegExp(r'\btate press\b'): 'Tríceps Tate Press',

      RegExp(r'\blateral raise\b'): 'Elevação Lateral',
      RegExp(r'\bfront raise\b'): 'Elevação Frontal',
      RegExp(r'\brear delt fly\b'): 'Crucifixo Inverso',
      RegExp(r'\brear delt raise\b'): 'Crucifixo Inverso',
      RegExp(r'\breverse fly\b'): 'Crucifixo Inverso',
      RegExp(r'\bchest fly\b'): 'Crucifixo',
      RegExp(r'\bfly\b'): 'Crucifixo',
      RegExp(r'\bpullover\b'): 'Pullover',

      RegExp(r'\blat pulldown\b'): 'Puxada Alta',
      RegExp(r'\bpulldown\b'): 'Puxada Alta',
      RegExp(r'\bbent over row\b'): 'Remada Curvada',
      RegExp(r'\bbent-over row\b'): 'Remada Curvada',
      RegExp(r'\bseated row\b'): 'Remada Baixa',
      RegExp(r'\bupright row\b'): 'Remada Alta',
      RegExp(r'\binverted row\b'): 'Remada Invertida',
      RegExp(r'\bt-bar row\b'): 'Remada Cavalinho (Barra T)',
      RegExp(r'\brow\b'): 'Remada',
      RegExp(r'\bshrug\b'): 'Encolhimento de Ombros',

      RegExp(r'\bleg press\b'): 'Leg Press',
      RegExp(r'\bleg extension\b'): 'Cadeira Extensora',
      RegExp(r'\bseated leg curl\b'): 'Cadeira Flexora',
      RegExp(r'\blying leg curl\b'): 'Mesa Flexora',
      RegExp(r'\bleg curl\b'): 'Mesa Flexora',
      RegExp(r'\bcalf raise\b'): 'Elevação de Panturrilha',
      RegExp(r'\bwalking lunge\b'): 'Passada (Avanço Caminhando)',
      RegExp(r'\blunge\b'): 'Afundo',
      RegExp(r'\bstep-up\b'): 'Subida no Banco (Step-up)',
      RegExp(r'\bstep up\b'): 'Subida no Banco (Step-up)',
      RegExp(r'\bhip thrust\b'): 'Elevação Pélvica',
      RegExp(r'\bglute bridge\b'): 'Ponte para Glúteos',

      RegExp(r'\breverse crunch\b'): 'Abdominal Infra',
      RegExp(r'\bbicycle crunch\b'): 'Abdominal Bicicleta',
      RegExp(r'\bcrunch\b'): 'Abdominal Supra',
      RegExp(r'\bsit-up\b'): 'Abdominal Sit-up',
      RegExp(r'\bplank\b'): 'Prancha Abdominal',
      RegExp(r'\bhanging leg raise\b'): 'Elevação de Pernas Suspenso',
      RegExp(r'\bleg raise\b'): 'Elevação de Pernas',
      RegExp(r'\bface pull\b'): 'Face Pull',
      RegExp(r'\bpull-up\b'): 'Barra Fixa',
      RegExp(r'\bchin-up\b'): 'Barra Fixa Supinada',
      RegExp(r'\bpush-up\b'): 'Flexão de Braço',
      RegExp(r'\bdip\b'): 'Mergulho nas Paralelas',
    };

    String coreAction = '';
    for (final entry in actions.entries) {
      if (entry.key.hasMatch(working)) {
        coreAction = entry.value;
        working = working.replaceFirst(entry.key, '').trim();
        break;
      }
    }

    if (coreAction.isEmpty) {
      coreAction = _fallbackTranslate(working);
      return '$coreAction $equipStr'.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    final qualifiers = <String>[];
    if (working.contains('incline') && !coreAction.contains('Inclinad')) qualifiers.add('Inclinado');
    if (working.contains('decline') && !coreAction.contains('Declinad')) qualifiers.add('Declinado');
    if (working.contains('seated') && !coreAction.contains('Sentad')) qualifiers.add('Sentado');
    if (working.contains('standing') && !coreAction.contains('em Pé')) qualifiers.add('em Pé');
    if (working.contains('lying') && !coreAction.contains('Deitad')) qualifiers.add('Deitado');
    if (working.contains('kneeling') && !coreAction.contains('Ajoelhad')) qualifiers.add('Ajoelhado');
    if (working.contains('single arm') || working.contains('one arm') || working.contains('one-arm')) qualifiers.add('Unilateral');
    if (working.contains('single leg') || working.contains('one leg') || working.contains('one-leg')) qualifiers.add('Unilateral');
    if (working.contains('alternating') || working.contains('alternate')) qualifiers.add('Alternado');
    if (working.contains('close grip') || working.contains('close-grip') || working.contains('narrow')) qualifiers.add('Pegada Fechada');
    if (working.contains('wide grip') || working.contains('wide-grip')) qualifiers.add('Pegada Aberta');
    if (working.contains('reverse grip') || working.contains('reverse-grip') || working.contains('underhand')) qualifiers.add('Pegada Supinada');
    if (working.contains('neutral grip') || working.contains('neutral')) qualifiers.add('Pegada Neutra');
    if (working.contains('cross body') || working.contains('cross-body')) qualifiers.add('Cruzado');
    if (working.contains('twist') || working.contains('twisting')) qualifiers.add('com Giro');
    if (working.contains('with rope') || working.contains('rope')) qualifiers.add('com Corda');
    if (working.contains('straight arm') || working.contains('straight-arm')) qualifiers.add('com Braços Estendidos');
    if (working.contains('behind neck') || working.contains('behind head')) qualifiers.add('Atrás da Nuca');
    if (working.contains('on exercise ball') || working.contains('on stability ball') || working.contains('stability ball')) qualifiers.add('na Bola Suíça');
    if (working.contains('on bosu ball') || working.contains('bosu')) qualifiers.add('no Bosu');
    if (working.contains('bench') && !qualifiers.contains('no Banco')) qualifiers.add('no Banco');
    if (working.contains('floor') && !qualifiers.contains('no Chão')) qualifiers.add('no Chão');

    final qText = qualifiers.isEmpty ? '' : ' ${qualifiers.join(' ')}';
    var res = '$coreAction$qText $equipStr'.replaceAll(RegExp(r'\s+'), ' ').trim();

    return res
        .replaceAll('Agachamento com Barra com Barra', 'Agachamento Livre com Barra')
        .replaceAll('na Polia na Polia', 'na Polia')
        .replaceAll('no Smith no Smith', 'no Smith')
        .replaceAll('com Halteres com Halteres', 'com Halteres')
        .replaceAll('Agachamento com Barra Acima da Cabeça com Barra', 'Agachamento com Barra Acima da Cabeça (Overhead Squat)')
        .replaceAll('Unilateral Unilateral', 'Unilateral')
        .replaceAll('Unilateral com Halteres', 'Unilateral com Halter')
        .replaceAll('com Barra com Barra W', 'com Barra W')
        .replaceAll('Supino Reto na Máquina Inclinado na Máquina Articulada', 'Supino Inclinado na Máquina Articulada')
        .replaceAll('Supino Reto na Máquina Declinado na Máquina Articulada', 'Supino Declinado na Máquina Articulada')
        .replaceAll('Supino Reto na Máquina em Pé na Máquina Articulada', 'Supino em Pé na Máquina Articulada')
        .replaceAll('Rosca Inclinado', 'Rosca Inclinada')
        .replaceAll('Remada Inclinado', 'Remada Inclinada')
        .replaceAll('Elevação Inclinado', 'Elevação Inclinada')
        .replaceAll('Extensão Inclinado', 'Extensão Inclinada')
        .replaceAll('Flexão Inclinado', 'Flexão Inclinada')
        .replaceAll('Puxada Alternado', 'Puxada Alternada')
        .replaceAll('Remada Alternado', 'Remada Alternada')
        .replaceAll('Rosca Deitado', 'Rosca Deitada')
        .replaceAll('Remada Deitado', 'Remada Deitada')
        .replaceAll('Elevação Deitado', 'Elevação Deitada')
        .replaceAll('Extensão Deitado', 'Extensão Deitada')
        .replaceAll('Prancha Abdominal Inclinado', 'Prancha Abdominal Inclinada')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _fallbackTranslate(String s) {
    if (s.isEmpty) return 'Exercício';
    final words = s.split(' ');
    final ptWords = words.map((w) {
      final map = {
        'walk': 'Caminhada',
        'run': 'Corrida',
        'jog': 'Trote',
        'jump': 'Salto',
        'stretch': 'Alongamento',
        'swing': 'Balanço (Swing)',
        'clean': 'Clean',
        'snatch': 'Snatch',
        'jerk': 'Jerk',
        'arm': 'Braço',
        'leg': 'Perna',
        'hand': 'Mão',
        'back': 'Costas',
        'chest': 'Peitoral',
        'foot': 'Pé',
        'toe': 'Ponta dos Pés',
        'heel': 'Calcanhar',
      };
      return map[w] ?? (w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w);
    });
    return ptWords.join(' ');
  }

  /// Tradução automática contextual e gramatical das instruções de treino (PT-BR Autêntico)
  static List<String> translateInstructions(List<dynamic> rawSteps) {
    if (rawSteps.isEmpty) return const [];
    return rawSteps.map((s) => _InstructionTranslator.translate(s.toString())).toList();
  }
}

/// Motor Canônico de Tradução de Instruções de Fitness em 4 Camadas
class _InstructionTranslator {
  _InstructionTranslator._();

  static bool _initialized = false;
  static final Map<String, String> _exact = {};
  static final List<MapEntry<Pattern, String>> _clausePatterns = [];
  static final List<MapEntry<Pattern, String>> _phrasePatterns = [];
  static final List<MapEntry<Pattern, String>> _vocabPatterns = [];

  static Pattern _u(String text) {
    return RegExp('(?<![a-zA-ZÀ-ÿ])$text(?![a-zA-ZÀ-ÿ])', caseSensitive: false);
  }

  static void _addClause(Pattern pat, String repl) => _clausePatterns.add(MapEntry(pat, repl));
  static void _addPhrase(Pattern pat, String repl) => _phrasePatterns.add(MapEntry(pat, repl));
  static void _addVocab(Pattern pat, String repl) => _vocabPatterns.add(MapEntry(pat, repl));

  static void _init() {
    if (_initialized) return;
    _initialized = true;

    _exact['Repeat for the desired number of repetitions.'] = 'Repita pelo número desejado de repetições.';
    _exact['Continue alternating sides for the desired number of repetitions.'] = 'Continue alternando os lados pelo número desejado de repetições.';
    _exact['Hold the contracted position for a brief pause as you squeeze your biceps.'] = 'Sustente a posição contraída por um instante, contraindo ao máximo os bíceps.';
    _exact['Repeat for the desired number of repetitions, then switch arms.'] = 'Repita pelo número desejado de repetições e troque de braço.';
    _exact['Repeat for the desired number of repetitions, then switch sides.'] = 'Repita pelo número desejado de repetições e troque de lado.';
    _exact['Repeat for the desired number of repetitions, then switch to the other arm.'] = 'Repita pelo número desejado de repetições e passe para o outro braço.';
    _exact['Repeat for the desired number of repetitions, then switch legs.'] = 'Repita pelo número desejado de repetições e troque de perna.';
    _exact['Repeat for the desired number of repetitions, then switch to the other leg.'] = 'Repita pelo número desejado de repetições e passe para a outra perna.';
    _exact['Repeat for the desired number of repetitions, then switch to the other side.'] = 'Repita pelo número desejado de repetições e passe para o outro lado.';
    _exact['Repeat on the other side.'] = 'Repita do outro lado.';
    _exact['Repeat on the opposite side.'] = 'Repita no lado oposto.';
    _exact['Repeat the movement for the desired number of repetitions.'] = 'Repita o movimento pelo número desejado de repetições.';
    _exact['Repeat for the desired number of sets and repetitions.'] = 'Repita pelo número desejado de séries e repetições.';
    _exact['Repeat for the desired amount of repetitions.'] = 'Repita pela quantidade desejada de repetições.';
    _exact['Repeat for the desired duration or repetitions.'] = 'Repita pela duração ou número de repetições desejado.';
    _exact['Continue this movement for the desired number of repetitions.'] = 'Continue esse movimento pelo número desejado de repetições.';
    _exact['Continue alternating for the desired number of repetitions.'] = 'Continue alternando pelo número desejado de repetições.';
    _exact['Continue alternating legs for the desired number of repetitions.'] = 'Continue alternando as pernas pelo número desejado de repetições.';
    _exact['Continue alternating arms for the desired number of repetitions.'] = 'Continue alternando os braços pelo número desejado de repetições.';
    _exact['Repeat the exercise for the desired number of repetitions.'] = 'Repita o exercício pelo número desejado de repetições.';
    _exact['Repeat the process for the desired number of repetitions.'] = 'Repita o processo pelo número desejado de repetições.';
    _exact['Lie flat on your back with your knees bent and feet flat on the ground.'] = 'Deite-se de costas no chão com os joelhos flexionados e os pés apoiados.';
    _exact['Lie flat on your back with your knees bent and feet flat on the floor.'] = 'Deite-se de costas no chão com os joelhos flexionados e os pés apoiados.';
    _exact['Lie flat on a bench with your feet flat on the ground.'] = 'Deite-se no banco reto com os pés firmes no chão.';
    _exact['Lie flat on a bench with your feet flat on the floor.'] = 'Deite-se no banco reto com os pés apoiados no chão.';
    _exact['Stand with your feet shoulder-width apart and your knees slightly bent.'] = 'Fique em pé com os pés na largura dos ombros e joelhos levemente flexionados.';
    _exact['Stand with your feet shoulder-width apart.'] = 'Fique em pé com os pés afastados na largura dos ombros.';
    _exact['Stand with your feet hip-width apart and your knees slightly bent.'] = 'Fique em pé com os pés na largura do quadril e joelhos levemente flexionados.';
    _exact['Stand with your feet hip-width apart.'] = 'Fique em pé com os pés afastados na largura do quadril.';
    _exact['Stand facing the machine with your feet shoulder-width apart.'] = 'Fique de frente para o aparelho com os pés na largura dos ombros.';
    _exact['Stand facing the cable machine with your feet shoulder-width apart.'] = 'Fique de frente para a polia com os pés afastados na largura dos ombros.';
    _exact['Sit on a bench with your back straight and feet flat on the ground.'] = 'Sente-se no banco com as costas retas e os pés firmes no chão.';
    _exact['Sit on a bench with your back straight and feet flat on the floor.'] = 'Sente-se no banco com as costas retas e os pés apoiados no chão.';
    _exact['Set up an incline bench at a 45-degree angle.'] = 'Ajuste o banco inclinado a um ângulo de 45 graus.';
    _exact['Set an incline bench to a 45-degree angle.'] = 'Ajuste um banco inclinado em um ângulo de 45 graus.';
    _exact['Adjust an incline bench to a 45-degree angle.'] = 'Ajuste o banco inclinado para um ângulo de 45 graus.';
    _exact['Place your hands behind your head with your elbows pointing outwards.'] = 'Posicione as mãos suavemente atrás da cabeça com os cotovelos abertos para fora (sem puxar a cervical).';
    _exact['Bend your knees slightly and hinge forward at the hips, keeping your back straight.'] = 'Flexione levemente os joelhos e incline o tronco à frente a partir do quadril, mantendo a coluna ereta.';
    _exact['Keep your back straight and your core engaged.'] = 'Mantenha as costas retas e o abdômen contraído.';
    _exact['Keeping your upper arms stationary, exhale and curl the weights while contracting your biceps.'] = 'Mantendo os braços firmes e imóveis, expire e flexione os antebraços contraindo os bíceps.';
    _exact['Continue to raise the dumbbells until your biceps are fully contracted and the dumbbells are at shoulder level.'] = 'Continue elevando os halteres até a contração máxima dos bíceps com os pesos na altura dos ombros.';
    _exact['Inhale and slowly begin to lower the dumbbells back to the starting position.'] = 'Inspire e comece a descer lentamente os halteres de volta à posição inicial.';
    _exact['Inhale and slowly lower the dumbbells back to the starting position.'] = 'Inspire e desça lentamente os halteres de volta à posição inicial.';
    _exact['Inhale and slowly lower the dumbbell back to the starting position.'] = 'Inspire e desça lentamente o halter de volta à posição inicial.';
    _exact['Inhale and slowly lower the barbell back to the starting position.'] = 'Inspire e desça lentamente a barra de volta à posição inicial.';
    _exact['Inhale and slowly lower the bar back to the starting position.'] = 'Inspire e desça lentamente a barra de volta à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower your upper body back down to the starting position.'] = 'Faça uma breve pausa no topo e desça lentamente o tronco à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower your heels back down to the starting position.'] = 'Faça uma pausa no topo e desça lentamente os calcanhares à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower your legs back down to the starting position.'] = 'Faça uma pausa no topo e desça lentamente as pernas à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower your arms back down to the starting position.'] = 'Faça uma pausa no topo e desça lentamente os braços de volta à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower your body back down to the starting position.'] = 'Faça uma pausa no topo e retorne o corpo controladamente à posição inicial.';
    _exact['Pause for a moment at the bottom, then push through your heels to return to the starting position.'] = 'Faça uma breve pausa embaixo e empurre pelos calcanhares para retornar à posição inicial.';
    _exact['Pause for a moment at the top, squeezing your biceps.'] = 'Faça uma breve pausa no topo, contraindo bem os bíceps.';
    _exact['Pause for a moment at the top, squeezing your glutes.'] = 'Faça uma breve pausa no topo, contraindo bem os glúteos.';
    _exact['Pause for a moment at the top, then slowly lower the dumbbell back to the starting position.'] = 'Faça uma breve pausa no topo e desça lentamente o halter de volta à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower the dumbbells back to the starting position.'] = 'Faça uma pausa no topo e desça lentamente os halteres à posição inicial.';
    _exact['Pause for a moment at the top, then slowly lower the dumbbells back down to the starting position.'] = 'Faça uma pausa no topo e desça lentamente os halteres à posição inicial.';
    _exact['Exhale as you push and inhale as you return.'] = 'Expire ao empurrar e inspire ao retornar à posição inicial.';
    _exact['Grasp the barbell with an overhand grip slightly wider than shoulder-width apart.'] = 'Segure a barra com pegada pronada um pouco mais aberta que a largura dos ombros.';
    _exact['Hold a dumbbell in each hand.'] = 'Segure um halter em cada mão.';
    _exact['Hold a dumbbell in each hand with an overhand grip.'] = 'Segure um halter em cada mão com pegada pronada.';
    _exact['Hold a dumbbell in each hand with a neutral grip.'] = 'Segure um halter em cada mão com pegada neutra.';
    _exact['Hold a dumbbell in each hand with your palms facing your body.'] = 'Segure um halter em cada mão com as palmas voltadas para o corpo.';
    _exact['Twist your torso to the right, bringing the cable handle towards your right hip.'] = 'Gire o tronco para a direita, trazendo a manopla da polia em direção ao quadril direito.';
    _exact['Pause for a moment, then twist your torso to the left, bringing the cable handle towards your left hip.'] = 'Faça uma breve pausa e gire o tronco para a esquerda, trazendo a manopla da polia em direção ao quadril esquerdo.';
    _exact['Lower your torso until you feel a stretch in your left hamstring and your right arm is pointing towards the ground.'] = 'Desça o tronco até sentir o alongamento nos posteriores da coxa esquerda e o braço direito apontar para o chão.';
    _exact['Repeat the exercise on the other side, starting with the kettlebell in your left hand.'] = 'Repita o exercício do outro lado, começando com o kettlebell na mão esquerda.';
    _exact['Bend your knees slightly and rotate your torso to the right, swinging the barbell down towards your right hip.'] = 'Flexione levemente os joelhos e gire o tronco para a direita, conduzindo a barra para baixo em direção ao quadril direito.';
    _exact['Continue alternating between lifting your right and left foot for the desired number of repetitions.'] = 'Continue alternando a elevação do pé direito e esquerdo pelo número desejado de repetições.';
    _exact['Slowly tilt your head to the right, bringing your right ear toward your right shoulder without lifting or shrugging the shoulder.'] = 'Incline suavemente a cabeça para a direita, aproximando a orelha direita do ombro direito sem elevar ou encolher os ombros.';
    _exact['Tilt your head to the right, bringing your right ear towards your right shoulder.'] = 'Incline a cabeça para a direita, aproximando a orelha direita do ombro direito.';
    _exact['With your left hand, grab your right hand and gently pull it towards your body, feeling a stretch in your right forearm.'] = 'Com a mão esquerda, segure a mão direita e puxe-a suavemente em direção ao corpo, sentindo o alongamento no antebraço direito.';
    _exact['Keeping your back straight, slowly lean to the right side, feeling a stretch in your left lat muscle.'] = 'Mantendo a coluna ereta, incline o tronco lentamente para o lado direito até sentir o alongamento na grande dorsal esquerda.';
    _exact['Repeat the stretch on the left side, leaning to the left and feeling a stretch in your right lat muscle.'] = 'Repita o alongamento do lado esquerdo, inclinando-se para a esquerda até sentir o alongamento na grande dorsal direita.';
    _exact['Lean forward, pushing your hips towards the stability ball, until you feel a stretch in your right hip flexor.'] = 'Incline-se à frente, projetando o quadril em direção à bola suíça até sentir o alongamento nos flexores de quadril direitos.';
    _exact['Slowly pull your right foot towards your glutes, feeling a stretch in your right quad.'] = 'Puxe lentamente o pé direito em direção aos glúteos até sentir o alongamento no quadríceps direito.';
    _exact['Gently pull your left foot towards your glutes, feeling a stretch in your left quad.'] = 'Puxe suavemente o pé esquerdo em direção aos glúteos até sentir o alongamento no quadríceps esquerdo.';
    _exact['Initiate from the ground: push off the ball of the right foot and rotate the right hip and shoulder forward.'] = 'Inicie o movimento pelo chão: empurre com a ponta do pé direito e rotacione o quadril e o ombro direitos para a frente.';
    _exact['Drive the right fist straight from your chin to the target, turning the palm down at extension with a neutral wrist.'] = 'Lance o punho direito em linha reta do queixo até o alvo, girando a palma para baixo no final da extensão com o punho alinhado.';
    _exact['Settle a bit into the right hip with the right heel light and core braced.'] = 'Apoie o peso suavemente sobre o quadril direito com o calcanhar direito livre e o abdômen travado.';
    _exact['As you rotate, bring the right fist up close to your body in a vertical arc, palm facing you, elbow ~90°, exhaling on the punch.'] = 'Ao girar, suba o punho direito junto ao corpo em arco vertical, palma virada para você, cotovelo a ~90°, expirando no golpe.';
    _exact['Dip slightly by bending the knees and loading the lead (left) hip without collapsing your torso.'] = 'Flexione levemente os joelhos e apoie a carga sobre o quadril de base (esquerdo) sem perder o alinhamento do tronco.';
    _exact['Position the left head pad on the bony side of your skull above the ear (not on the jaw or ear).'] = 'Posicione o apoio esquerdo da cabeça na parte óssea lateral do crânio acima da orelha (não na mandíbula ou orelha).';
    _exact['Maintain smooth breathing and consistent tension; complete all reps on the right, then train the left for balance.'] = 'Mantenha a respiração fluida e tensão constante; complete todas as repetições à direita e depois treine o lado esquerdo.';
    _exact['Re-chamber the leg immediately, then place it back to the starting stance under control.'] = 'Recolha a perna imediatamente e retorne à posição inicial de guarda com controle.';
    _exact['Retract the leg immediately along the same path and place the foot down to the starting stance.'] = 'Recolha a perna imediatamente pela mesma trajetória e apoie o pé no chão na base inicial.';
    _exact['Lower the dumbbell until you feel a stretch in your right hamstring, then return to the starting position.'] = 'Desça o halter até sentir o alongamento nos posteriores da coxa direita e retorne à posição inicial.';
    _exact['Continue alternating between your right and left foot for the desired number of repetitions.'] = 'Continue alternando entre os pés direito e esquerdo pelo número desejado de repetições.';
    _exact['Shift weight to your right forefoot and press through the ball of the foot to lift the right heel high; keep the knee soft, not locked.'] = 'Transfira o peso para o antepé direito e empurre pela ponta do pé para elevar bem o calcanhar direito; mantenha o joelho destravado.';
    _exact['Land softly on your left forefoot with a slight bend in the ankle, knee, and hip; keep your torso upright.'] = 'Aterrisse suavemente sobre o antepé esquerdo com leve flexão no tornozelo, joelho e quadril, mantendo o tronco ereto.';
    _exact['As you land, swing your left leg behind your right leg and tap the ground with your left toes.'] = 'Ao aterrissar, cruze a perna esquerda por trás da perna direita e toque o chão com a ponta do pé esquerdo.';
    _exact['As you land, swing your right leg behind your left leg and tap the ground with your right toes.'] = 'Ao aterrissar, cruze a perna direita por trás da perna esquerda e toque o chão com a ponta do pé direito.';
    _exact['Continue the movement by lowering your hips back down towards the ground, returning to the starting push-up position.'] = 'Continue o movimento descendo o quadril de volta em direção ao chão, retornando à posição inicial de flexão de braço.';
    _exact['Shift weight slightly and row the right dumbbell toward your ribs without rotating the torso; return it to the floor and repeat with the left.'] = 'Transfira levemente o peso e reme o halter direito em direção às costelas sem girar o tronco; retorne ao chão e repita com o lado esquerdo.';

    // 1. CLAUSES
    _addClause(_u(r'Lie flat on your back with your knees bent and feet flat on the (ground|floor)'), 'Deite-se de costas no chão com os joelhos flexionados e os pés apoiados');
    _addClause(_u(r'Lie flat on your back with your hands placed behind your head'), 'Deite-se de costas no chão com as mãos posicionadas atrás da cabeça (sem puxar o pescoço)');
    _addClause(_u(r'Lie flat on your back with your arms by your sides'), 'Deite-se de costas no chão com os braços ao lado do corpo');
    _addClause(_u(r'Lie flat on your back with your arms extended'), 'Deite-se de costas no chão com os braços estendidos');
    _addClause(_u(r'Lie flat on your back'), 'Deite-se de costas no chão');
    _addClause(_u(r'Lie flat on a bench with (your )?feet flat on the (ground|floor)'), 'Deite-se no banco reto com os pés firmes no chão');
    _addClause(_u(r'Lie flat on a bench'), 'Deite-se no banco reto');
    _addClause(_u(r'Lie face down on a bench'), 'Deite-se de bruços no banco');
    _addClause(_u(r'Lie face down on the (floor|ground)'), 'Deite-se de bruços no chão');
    _addClause(_u(r'Lie face down'), 'Deite-se de bruços');
    _addClause(_u(r'Lie on your back'), 'Deite-se de costas');
    _addClause(_u(r'Lie on your side'), 'Deite-se de lado');
    _addClause(_u(r'Lie on an incline bench'), 'Deite-se no banco inclinado');
    _addClause(_u(r'Lie on a decline bench'), 'Deite-se no banco declinado');
    _addClause(_u(r'Lie down on a decline bench'), 'Deite-se no banco declinado');
    _addClause(_u(r'Lie down on an incline bench'), 'Deite-se no banco inclinado');
    _addClause(_u(r'Lie down on a bench'), 'Deite-se no banco');
    _addClause(_u(r'Lie down on the (floor|ground)'), 'Deite-se no chão');
    _addClause(_u(r'Lie down on'), 'Deite-se em');

    _addClause(_u(r'Stand tall with your feet shoulder-width apart'), 'Fique em pé ereto com os pés na largura dos ombros');
    _addClause(_u(r'Stand up straight with your feet shoulder-width apart'), 'Fique em pé ereto com os pés na largura dos ombros');
    _addClause(_u(r'Stand up straight with a dumbbell in each hand'), 'Fique em pé ereto com um halter em cada mão');
    _addClause(_u(r'Stand up straight'), 'Fique em pé ereto');
    _addClause(_u(r'Stand with your feet shoulder-width apart and your arms extended straight down by your sides'), 'Fique em pé com os pés na largura dos ombros e os braços estendidos para baixo ao lado do corpo');
    _addClause(_u(r'Stand with your feet shoulder-width apart, holding a dumbbell in each hand'), 'Fique em pé com os pés na largura dos ombros, segurando um halter em cada mão');
    _addClause(_u(r'Stand with your feet shoulder-width apart and hold a dumbbell in each hand'), 'Fique em pé com os pés na largura dos ombros e segure um halter em cada mão');
    _addClause(_u(r'Stand with your feet shoulder-width apart and hold a barbell'), 'Fique em pé com os pés na largura dos ombros e segure uma barra');
    _addClause(_u(r'Stand with your feet shoulder-width apart'), 'Fique em pé com os pés na largura dos ombros');
    _addClause(_u(r'Stand with your feet hip-width apart'), 'Fique em pé com os pés na largura do quadril');
    _addClause(_u(r'Stand with your feet'), 'Fique em pé com os pés');
    _addClause(_u(r'Stand facing the cable machine with your feet shoulder-width apart'), 'Fique de frente para a polia com os pés na largura dos ombros');
    _addClause(_u(r'Stand facing the machine with your feet shoulder-width apart'), 'Fique de frente para o aparelho com os pés na largura dos ombros');
    _addClause(_u(r'Stand facing the cable machine'), 'Fique de frente para a polia');
    _addClause(_u(r'Stand facing the machine'), 'Fique de frente para o aparelho');
    _addClause(_u(r'Stand facing away from the cable machine'), 'Fique de costas para a polia');
    _addClause(_u(r'Stand facing away from the machine'), 'Fique de costas para o aparelho');
    _addClause(_u(r'Stand facing away from the rack'), 'Fique de costas para o suporte');
    _addClause(_u(r'Stand facing'), 'Fique de frente para');
    _addClause(_u(r'Stand on'), 'Fique em pé sobre');

    _addClause(_u(r'Sit on a bench with your back straight and feet flat on the (ground|floor)'), 'Sente-se no banco com as costas retas e os pés firmes no chão');
    _addClause(_u(r'Sit on a bench with your back straight'), 'Sente-se no banco com as costas retas');
    _addClause(_u(r'Sit on the edge of a bench'), 'Sente-se na ponta do banco');
    _addClause(_u(r'Sit on a bench'), 'Sente-se no banco');
    _addClause(_u(r'Sit on the machine with your back flat against the pad'), 'Sente-se no aparelho com as costas bem apoiadas no encosto');
    _addClause(_u(r'Sit on the machine'), 'Sente-se no aparelho');
    _addClause(_u(r'Sit on the cable machine'), 'Sente-se no aparelho de polia');
    _addClause(_u(r'Sit facing the cable machine'), 'Sente-se de frente para a polia');
    _addClause(_u(r'Sit facing'), 'Sente-se de frente para');
    _addClause(_u(r'Sit on the floor with your legs extended'), 'Sente-se no chão com as pernas estendidas');
    _addClause(_u(r'Sit on the (floor|ground)'), 'Sente-se no chão');
    _addClause(_u(r'Sit tall'), 'Sente-se ereto');
    _addClause(_u(r'Sit upright'), 'Sente-se ereto');

    _addClause(_u(r'Kneel down on the pad facing the machine'), 'Ajoelhe-se no apoio de frente para o aparelho');
    _addClause(_u(r'Kneel on the (floor|ground|pad)'), 'Ajoelhe-se no chão');
    _addClause(_u(r'Kneel down on'), 'Ajoelhe-se em');

    // 2. PHRASES
    _addPhrase(_u(r'with a dumbbell in each hand'), 'com um halter em cada mão');
    _addPhrase(_u(r'holding a dumbbell in each hand'), 'segurando um halter em cada mão');
    _addPhrase(_u(r'hold a dumbbell in each hand'), 'segure um halter em cada mão');
    _addPhrase(_u(r'holding a barbell with'), 'segurando uma barra com');
    _addPhrase(_u(r'holding the barbell with'), 'segurando a barra com');
    _addPhrase(_u(r'holding the dumbbells'), 'segurando os halteres');
    _addPhrase(_u(r'holding a dumbbell'), 'segurando um halter');
    _addPhrase(_u(r'holding the handles'), 'segurando as manoplas');
    _addPhrase(_u(r'holding the handle'), 'segurando a manopla');
    _addPhrase(_u(r'holding the bar'), 'segurando a barra');
    _addPhrase(_u(r'holding a weight'), 'segurando um peso');
    _addPhrase(_u(r'holding onto'), 'segurando-se em');
    _addPhrase(_u(r'hold onto'), 'segure-se em');

    _addPhrase(_u(r'at shoulder height'), 'na altura dos ombros');
    _addPhrase(_u(r'at shoulder level'), 'na altura dos ombros');
    _addPhrase(_u(r'to shoulder height'), 'até a altura dos ombros');
    _addPhrase(_u(r'to shoulder level'), 'até a altura dos ombros');
    _addPhrase(_u(r'to shoulder width'), 'na largura dos ombros');
    _addPhrase(_u(r'at chest height'), 'na altura do peito');
    _addPhrase(_u(r'at chest level'), 'na altura do peito');
    _addPhrase(_u(r'to chest height'), 'até a altura do peito');
    _addPhrase(_u(r'to chest level'), 'até a altura do peito');

    _addPhrase(_u(r'by bending at the knees and hips'), 'flexionando os joelhos e o quadril');
    _addPhrase(_u(r'by bending your knees and hips'), 'flexionando os joelhos e o quadril');
    _addPhrase(_u(r'by bending at the hips and knees'), 'flexionando o quadril e os joelhos');
    _addPhrase(_u(r'by bending your hips and knees'), 'flexionando o quadril e os joelhos');
    _addPhrase(_u(r'by bending your knees'), 'flexionando os joelhos');
    _addPhrase(_u(r'by bending your elbows'), 'flexionando os cotovelos');
    _addPhrase(_u(r'by bending the knees'), 'flexionando os joelhos');
    _addPhrase(_u(r'by bending the elbows'), 'flexionando os cotovelos');
    _addPhrase(_u(r'bending at the hips and knees'), 'flexionando o quadril e os joelhos');
    _addPhrase(_u(r'bending at the knees and hips'), 'flexionando os joelhos e o quadril');
    _addPhrase(_u(r'bending at the hips'), 'flexionando o quadril');
    _addPhrase(_u(r'bending at the knees'), 'flexionando os joelhos');
    _addPhrase(_u(r'bending your knees'), 'flexionando os joelhos');
    _addPhrase(_u(r'bending your elbows'), 'flexionando os cotovelos');

    _addPhrase(_u(r'into a squat position'), 'em posição de agachamento');
    _addPhrase(_u(r'in a squat position'), 'em posição de agachamento');
    _addPhrase(_u(r'in a seated position'), 'na posição sentada');
    _addPhrase(_u(r'in a standing position'), 'na posição em pé');
    _addPhrase(_u(r'in a neutral position'), 'em posição neutra');

    _addPhrase(_u(r'cable machine'), 'máquina de polia');
    _addPhrase(_u(r'squat rack'), 'suporte de agachamento (rack)');
    _addPhrase(_u(r'medicine ball'), 'medicine ball');
    _addPhrase(_u(r'exercise ball'), 'bola suíça');
    _addPhrase(_u(r'stability ball'), 'bola suíça');
    _addPhrase(_u(r'resistance band'), 'elástico de resistência');

    _addPhrase(_u(r'chest up'), 'peito estufado');
    _addPhrase(_u(r'and your chest up'), 'e o peito erguido');
    _addPhrase(_u(r'and chest up'), 'e o peito erguido');

    _addPhrase(_u(r'with both hands'), 'com ambas as mãos');
    _addPhrase(_u(r'with your hands'), 'com as mãos');
    _addPhrase(_u(r'hands slightly wider than shoulder-width apart'), 'mãos ligeiramente mais afastadas que a largura dos ombros');
    _addPhrase(_u(r'hands shoulder-width apart'), 'mãos na largura dos ombros');

    _addPhrase(_u(r'palms facing each other'), 'palmas voltadas uma para a outra');
    _addPhrase(_u(r'palms facing forward'), 'palmas voltadas para a frente');
    _addPhrase(_u(r'palms facing towards you'), 'palmas voltadas para você');
    _addPhrase(_u(r'palms facing your body'), 'palmas voltadas para o corpo');
    _addPhrase(_u(r'palms facing away from you'), 'palmas voltadas para a frente');
    _addPhrase(_u(r'palms facing inward'), 'palmas voltadas para dentro');
    _addPhrase(_u(r'palms facing down'), 'palmas voltadas para baixo');
    _addPhrase(_u(r'palms facing up'), 'palmas voltadas para cima');
    _addPhrase(_u(r'palms facing towards your feet'), 'palmas voltadas para os pés');
    _addPhrase(_u(r'palms facing'), 'palmas voltadas para');

    _addPhrase(_u(r'an overhand grip, slightly wider than shoulder-width apart'), 'uma pegada pronada, um pouco mais aberta que a largura dos ombros');
    _addPhrase(_u(r'an overhand grip slightly wider than shoulder-width apart'), 'uma pegada pronada um pouco mais aberta que a largura dos ombros');
    _addPhrase(_u(r'with an overhand grip, slightly wider than shoulder-width apart'), 'com pegada pronada, um pouco mais aberta que a largura dos ombros');
    _addPhrase(_u(r'with an overhand grip slightly wider than shoulder-width apart'), 'com pegada pronada um pouco mais aberta que a largura dos ombros');
    _addPhrase(_u(r'with an overhand grip'), 'com pegada pronada');
    _addPhrase(_u(r'with an underhand grip'), 'com pegada supinada');
    _addPhrase(_u(r'with a neutral grip'), 'com pegada neutra');
    _addPhrase(_u(r'with a wide grip'), 'com pegada aberta');
    _addPhrase(_u(r'with a close grip'), 'com pegada fechada');
    _addPhrase(_u(r'an overhand grip'), 'uma pegada pronada');
    _addPhrase(_u(r'an underhand grip'), 'uma pegada supinada');
    _addPhrase(_u(r'a neutral grip'), 'uma pegada neutra');
    _addPhrase(_u(r'overhand grip'), 'pegada pronada');
    _addPhrase(_u(r'underhand grip'), 'pegada supinada');
    _addPhrase(_u(r'neutral grip'), 'pegada neutra');
    _addPhrase(_u(r'wide grip'), 'pegada aberta');
    _addPhrase(_u(r'close grip'), 'pegada fechada');
    _addPhrase(_u(r'shoulder-width apart'), 'na largura dos ombros');
    _addPhrase(_u(r'hip-width apart'), 'na largura do quadril');

    _addPhrase(_u(r'keeping your back straight and your core engaged'), 'mantendo a coluna ereta e o abdômen contraído');
    _addPhrase(_u(r'keeping your back straight and core engaged'), 'mantendo a coluna ereta e o abdômen contraído');
    _addPhrase(_u(r'keeping your core engaged and your back straight'), 'mantendo o abdômen contraído e a coluna ereta');
    _addPhrase(_u(r'keeping your core engaged and back straight'), 'mantendo o abdômen contraído e a coluna ereta');
    _addPhrase(_u(r'keeping your back straight'), 'mantendo a coluna ereta');
    _addPhrase(_u(r'keeping your core engaged'), 'mantendo o abdômen contraído');
    _addPhrase(_u(r'keeping your upper arms stationary'), 'mantendo os braços firmes e imóveis');
    _addPhrase(_u(r'keeping your arms straight'), 'mantendo os braços estendidos');
    _addPhrase(_u(r'keeping your arms slightly bent'), 'mantendo os braços levemente flexionados');
    _addPhrase(_u(r'keeping your elbows close to your body'), 'mantendo os cotovelos junto ao corpo');
    _addPhrase(_u(r'keeping your elbows tucked in'), 'mantendo os cotovelos fechados');
    _addPhrase(_u(r'keeping your elbows slightly bent'), 'mantendo os cotovelos levemente flexionados');
    _addPhrase(_u(r'keeping your chest up'), 'mantendo o peito erguido');
    _addPhrase(_u(r'keeping your head in a neutral position'), 'mantendo a cabeça em posição neutra');
    _addPhrase(_u(r'keeping your knees slightly bent'), 'mantendo os joelhos levemente flexionados');
    _addPhrase(_u(r'keeping your lower body stable'), 'mantendo os membros inferiores estáveis');
    _addPhrase(_u(r'keeping your legs together'), 'mantendo as pernas unidas');
    _addPhrase(_u(r'keeping them straight'), 'mantendo-os estendidos');
    _addPhrase(_u(r'keeping it straight'), 'mantendo-o reto');
    _addPhrase(_u(r'keeping it close to your body'), 'mantendo o peso junto ao corpo');
    _addPhrase(_u(r'keeping your'), 'mantendo seu');
    _addPhrase(_u(r'keeping the'), 'mantendo o');
    _addPhrase(_u(r'keeping'), 'mantendo');

    _addPhrase(_u(r'engage your core muscles'), 'contraia os músculos do core');
    _addPhrase(_u(r'engage your core'), 'contraia o abdômen');
    _addPhrase(_u(r'engaging your core'), 'contraindo o abdômen');
    _addPhrase(_u(r'engage your abs'), 'contraia o abdômen');
    _addPhrase(_u(r'engaging your abs'), 'contraindo o abdômen');

    _addPhrase(_u(r'push through your heels to stand back up'), 'empurre pelos calcanhares para ficar em pé novamente');
    _addPhrase(_u(r'push through your heels to return to the starting position'), 'empurre pelos calcanhares para retornar à posição inicial');
    _addPhrase(_u(r'push through your heels'), 'empurre pelos calcanhares');
    _addPhrase(_u(r'drive through your heels to stand back up'), 'empurre com força pelos calcanhares para ficar em pé novamente');
    _addPhrase(_u(r'drive through your heels to return to the starting position'), 'empurre com força pelos calcanhares para retornar à posição inicial');
    _addPhrase(_u(r'drive through your heels'), 'empurre com força pelos calcanhares');
    _addPhrase(_u(r'pushing through your heels'), 'empurrando pelos calcanhares');

    _addPhrase(_u(r'until your arms are fully extended, but do not lock your elbows'), 'até a extensão completa dos braços, sem travar os cotovelos');
    _addPhrase(_u(r'until your arms are fully extended, without locking your elbows'), 'até a extensão completa dos braços, sem travar os cotovelos');
    _addPhrase(_u(r'until your legs are fully extended, without locking your knees'), 'até a extensão completa das pernas, sem travar os joelhos');
    _addPhrase(_u(r'without locking your elbows'), 'sem travar os cotovelos');
    _addPhrase(_u(r'without locking your knees'), 'sem travar os joelhos');
    _addPhrase(_u(r'without locking the elbows'), 'sem travar os cotovelos');
    _addPhrase(_u(r'without locking the knees'), 'sem travar os joelhos');
    _addPhrase(_u(r'do not lock your elbows'), 'não trave os cotovelos');
    _addPhrase(_u(r'do not lock your knees'), 'não trave os joelhos');

    _addPhrase(_u(r'to stand back up'), 'para ficar em pé novamente');
    _addPhrase(_u(r'stand back up'), 'fique em pé novamente');

    _addPhrase(_u(r'squeeze your shoulder blades together'), 'aproxime bem as escápulas');
    _addPhrase(_u(r'squeezing your shoulder blades together'), 'aproximando bem as escápulas');
    _addPhrase(_u(r'squeeze your shoulder blades'), 'aproxime as escápulas');
    _addPhrase(_u(r'squeezing your shoulder blades'), 'aproximando as escápulas');
    _addPhrase(_u(r'squeezing your biceps'), 'contraindo os bíceps');
    _addPhrase(_u(r'squeezing your triceps'), 'contraindo os tríceps');
    _addPhrase(_u(r'squeezing your glutes'), 'contraindo os glúteos');
    _addPhrase(_u(r'squeezing your chest'), 'contraindo o peitoral');
    _addPhrase(_u(r'squeeze your biceps'), 'contraia os bíceps');
    _addPhrase(_u(r'squeeze your triceps'), 'contraia os tríceps');
    _addPhrase(_u(r'squeeze your glutes'), 'contraia os glúteos');
    _addPhrase(_u(r'squeeze your chest'), 'contraia o peitoral');
    _addPhrase(_u(r'squeeze'), 'contraia');
    _addPhrase(_u(r'squeezing'), 'contraindo');

    _addPhrase(_u(r'pause for a moment at the peak of the movement'), 'faça uma breve pausa no pico do movimento');
    _addPhrase(_u(r'pause for a moment at the peak'), 'faça uma breve pausa no pico');
    _addPhrase(_u(r'pause for a moment at the bottom'), 'faça uma breve pausa embaixo');
    _addPhrase(_u(r'pause for a moment at the top'), 'faça uma breve pausa no topo');
    _addPhrase(_u(r'pause for a moment'), 'faça uma breve pausa');
    _addPhrase(_u(r'pause briefly at the top'), 'faça uma pausa breve no topo');
    _addPhrase(_u(r'pause briefly at the bottom'), 'faça uma pausa breve embaixo');
    _addPhrase(_u(r'pause briefly'), 'faça uma breve pausa');
    _addPhrase(_u(r'pause'), 'faça uma pausa');
    _addPhrase(_u(r'pausing'), 'pausando');

    _addPhrase(_u(r'hold for a moment at the top'), 'segure por um instante no topo');
    _addPhrase(_u(r'hold for a moment'), 'segure por um instante');
    _addPhrase(_u(r'hold for a second'), 'segure por um segundo');
    _addPhrase(_u(r'hold for a brief pause'), 'faça uma breve pausa');
    _addPhrase(_u(r'hold the contracted position'), 'sustente a posição contraída');
    _addPhrase(_u(r'hold this position'), 'sustente essa posição');
    _addPhrase(_u(r'hold the position'), 'sustente a posição');

    _addPhrase(_u(r'slowly return to the starting position'), 'retorne lentamente à posição inicial');
    _addPhrase(_u(r'slowly return to starting position'), 'retorne lentamente à posição inicial');
    _addPhrase(_u(r'to return to the starting position'), 'para retornar à posição inicial');
    _addPhrase(_u(r'to return to starting position'), 'para retornar à posição inicial');
    _addPhrase(_u(r'return to the starting position'), 'retorne à posição inicial');
    _addPhrase(_u(r'return to starting position'), 'retorne à posição inicial');
    _addPhrase(_u(r'slowly lower back down to the starting position'), 'desça lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower back to the starting position'), 'desça lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower down to the starting position'), 'desça lentamente à posição inicial');
    _addPhrase(_u(r'slowly lower the weights back to the starting position'), 'desça os pesos lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower the dumbbells back to the starting position'), 'desça os halteres lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower the dumbbell back to the starting position'), 'desça o halter lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower the barbell back to the starting position'), 'desça a barra lentamente de volta à posição inicial');
    _addPhrase(_u(r'slowly lower the bar back to the starting position'), 'desça a barra lentamente de volta à posição inicial');
    _addPhrase(_u(r'back down to the starting position'), 'de volta à posição inicial');
    _addPhrase(_u(r'back to the starting position'), 'de volta à posição inicial');
    _addPhrase(_u(r'to the starting position'), 'à posição inicial');
    _addPhrase(_u(r'to starting position'), 'à posição inicial');
    _addPhrase(_u(r'starting position'), 'posição inicial');

    _addPhrase(_u(r'Repeat on the other side'), 'Repita do outro lado');
    _addPhrase(_u(r'repeat on the other side'), 'repita do outro lado');
    _addPhrase(_u(r'Repeat on the opposite side'), 'Repita no lado oposto');
    _addPhrase(_u(r'repeat on the opposite side'), 'repita no lado oposto');
    _addPhrase(_u(r'Repeat the movement to the other side'), 'Repita o movimento para o outro lado');
    _addPhrase(_u(r'Repeat the movement on the opposite side'), 'Repita o movimento no lado oposto');
    _addPhrase(_u(r'Repeat the movement'), 'Repita o movimento');
    _addPhrase(_u(r'repeat the movement'), 'repita o movimento');
    _addPhrase(_u(r'Repeat with the other'), 'Repita com o outro');
    _addPhrase(_u(r'repeat with the other'), 'repita com o outro');
    _addPhrase(_u(r'Repeat with the opposite'), 'Repita com o lado oposto');
    _addPhrase(_u(r'Repeat for the desired'), 'Repita pelo número desejado');
    _addPhrase(_u(r'repeat for the desired'), 'repita pelo número desejado');
    _addPhrase(_u(r'for the desired number of repetitions'), 'pelo número desejado de repetições');
    _addPhrase(_u(r'desired number of repetitions'), 'número desejado de repetições');
    _addPhrase(_u(r'desired repetitions'), 'repetições desejadas');
    _addPhrase(_u(r'desired weight and height settings'), 'ajustes desejados de carga e altura');
    _addPhrase(_u(r'desired weight and height'), 'carga e altura desejadas');
    _addPhrase(_u(r'desired height'), 'altura desejada');
    _addPhrase(_u(r'desired weight'), 'carga desejada');

    _addPhrase(_u(r'press one dumbbell overhead while keeping the other dumbbell at shoulder height'), 'empurre um halter acima da cabeça enquanto mantém o outro na altura do ombro');

    _addPhrase(_u(r'twist your torso to the right'), 'gire o tronco para a direita');
    _addPhrase(_u(r'twist your torso to the left'), 'gire o tronco para a esquerda');
    _addPhrase(_u(r'to the right side of your body'), 'para o lado direito do corpo');
    _addPhrase(_u(r'to the left side of your body'), 'para o lado esquerdo do corpo');
    _addPhrase(_u(r'towards the right side of your body'), 'em direção ao lado direito do corpo');
    _addPhrase(_u(r'towards the left side of your body'), 'em direção ao lado esquerdo do corpo');
    _addPhrase(_u(r'towards the right side'), 'em direção ao lado direito');
    _addPhrase(_u(r'towards the left side'), 'em direção ao lado esquerdo');
    _addPhrase(_u(r'towards your right heel'), 'em direção ao calcanhar direito');
    _addPhrase(_u(r'towards your left heel'), 'em direção ao calcanhar esquerdo');
    _addPhrase(_u(r'towards your right knee'), 'em direção ao joelho direito');
    _addPhrase(_u(r'towards your left knee'), 'em direção ao joelho esquerdo');
    _addPhrase(_u(r'towards your right side'), 'em direção ao lado direito');
    _addPhrase(_u(r'towards your left side'), 'em direção ao lado esquerdo');
    _addPhrase(_u(r'towards your chest'), 'em direção ao peitoral');
    _addPhrase(_u(r'towards your hips'), 'em direção ao quadril');
    _addPhrase(_u(r'towards your shoulders'), 'em direção aos ombros');
    _addPhrase(_u(r'towards your glutes'), 'em direção aos glúteos');
    _addPhrase(_u(r'towards the floor'), 'em direção ao chão');
    _addPhrase(_u(r'towards the ground'), 'em direção ao chão');
    _addPhrase(_u(r'to the right'), 'para a direita');
    _addPhrase(_u(r'to the left'), 'para a esquerda');
    _addPhrase(_u(r'on the right'), 'à direita');
    _addPhrase(_u(r'on the left'), 'à esquerda');
    _addPhrase(_u(r'on the right side'), 'no lado direito');
    _addPhrase(_u(r'on the left side'), 'no lado esquerdo');

    _addPhrase(_u(r'right hand'), 'mão direita');
    _addPhrase(_u(r'left hand'), 'mão esquerda');
    _addPhrase(_u(r'right leg'), 'perna direita');
    _addPhrase(_u(r'left leg'), 'perna esquerda');
    _addPhrase(_u(r'right arm'), 'braço direito');
    _addPhrase(_u(r'left arm'), 'braço esquerdo');
    _addPhrase(_u(r'right foot'), 'pé direito');
    _addPhrase(_u(r'left foot'), 'pé esquerdo');
    _addPhrase(_u(r'right knee'), 'joelho direito');
    _addPhrase(_u(r'left knee'), 'joelho esquerdo');
    _addPhrase(_u(r'right elbow'), 'cotovelo direito');
    _addPhrase(_u(r'left elbow'), 'cotovelo esquerdo');
    _addPhrase(_u(r'right heel'), 'calcanhar direito');
    _addPhrase(_u(r'left heel'), 'calcanhar esquerdo');
    _addPhrase(_u(r'right thigh'), 'coxa direita');
    _addPhrase(_u(r'left thigh'), 'coxa esquerda');
    _addPhrase(_u(r'right ankle'), 'tornozelo direito');
    _addPhrase(_u(r'left ankle'), 'tornozelo esquerdo');
    _addPhrase(_u(r'right side'), 'lado direito');
    _addPhrase(_u(r'left side'), 'lado esquerdo');
    _addPhrase(_u(r'right shoulder'), 'ombro direito');
    _addPhrase(_u(r'left shoulder'), 'ombro esquerdo');

    _addPhrase(_u(r'opposite side'), 'lado oposto');
    _addPhrase(_u(r'opposite leg'), 'perna oposta');
    _addPhrase(_u(r'opposite arm'), 'braço oposto');
    _addPhrase(_u(r'opposite knee'), 'joelho oposto');
    _addPhrase(_u(r'opposite hand'), 'mão oposta');
    _addPhrase(_u(r'opposite foot'), 'pé oposto');
    _addPhrase(_u(r'opposite'), 'oposto');

    _addPhrase(_u(r'simultaneously'), 'simultaneamente');
    _addPhrase(_u(r'pedaling motion'), 'movimento de pedalada');
    _addPhrase(_u(r'have a partner or use a resistance band to secure your ankles'), 'peça a um parceiro de treino ou use um elástico para prender os tornozelos');
    _addPhrase(_u(r'have a partner or use a resistance band'), 'peça a um parceiro ou use um elástico');
    _addPhrase(_u(r'have a partner'), 'peça a um parceiro de treino');
    _addPhrase(_u(r'secure your ankles'), 'prenda os tornozelos');
    _addPhrase(_u(r'secure your knees on the pad'), 'trave os joelhos no apoio');
    _addPhrase(_u(r'secure your knees'), 'trave os joelhos');
    _addPhrase(_u(r'secure your feet'), 'trave os pés');
    _addPhrase(_u(r'secured under the pads'), 'travados sob os apoios');
    _addPhrase(_u(r'secured'), 'travado');
    _addPhrase(_u(r'securing'), 'travando');
    _addPhrase(_u(r'secure'), 'trave');
    _addPhrase(_u(r'partner'), 'parceiro de treino');
    _addPhrase(_u(r'ankles'), 'tornozelos');
    _addPhrase(_u(r'ankle'), 'tornozelo');
    _addPhrase(_u(r'thighs'), 'coxas');
    _addPhrase(_u(r'thigh'), 'coxa');
    _addPhrase(_u(r'pivoting on'), 'girando sobre');

    _addPhrase(_u(r'push yourself back up to the starting position'), 'empurre o corpo para cima de volta à posição inicial');
    _addPhrase(_u(r'push yourself back up'), 'empurre o corpo para cima novamente');
    _addPhrase(_u(r'push yourself up'), 'empurre o corpo para cima');
    _addPhrase(_u(r'push yourself'), 'empurre o corpo');
    _addPhrase(_u(r'parallel bars'), 'barras paralelas');
    _addPhrase(_u(r'parallel bar'), 'barra paralela');

    _addPhrase(_u(r'off the ground'), 'do chão');
    _addPhrase(_u(r'off the floor'), 'do chão');
    _addPhrase(_u(r'off the bench'), 'do banco');
    _addPhrase(_u(r'off the rack'), 'do suporte');
    _addPhrase(_u(r'off the ball'), 'da bola');
    _addPhrase(_u(r'off the pad'), 'do apoio');
    _addPhrase(_u(r'off the kettlebells'), 'dos kettlebells');
    _addPhrase(_u(r'off the kettlebell'), 'do kettlebell');
    _addPhrase(_u(r'hanging off the edge'), 'livres para fora da borda');
    _addPhrase(_u(r'hang off the edge'), 'livres para fora da borda');
    _addPhrase(_u(r'hanging off'), 'livres para fora');
    _addPhrase(_u(r'hang off'), 'livres para fora');
    _addPhrase(_u(r'off the edge'), 'da borda');
    _addPhrase(_u(r'push off with'), 'impulsione-se com');
    _addPhrase(_u(r'push off the'), 'impulsione-se a partir de');
    _addPhrase(_u(r'push off'), 'impulsione-se');
    _addPhrase(_u(r'jump off'), 'salte de');
    _addPhrase(_u(r'off the'), 'do');
    _addVocab(_u(r'off'), 'de');

    _addPhrase(_u(r'then slowly lower'), 'em seguida desça lentamente');
    _addPhrase(_u(r'then slowly return'), 'em seguida retorne lentamente');
    _addPhrase(_u(r'then slowly release'), 'em seguida solte lentamente');
    _addPhrase(_u(r'then slowly'), 'em seguida lentamente');
    _addPhrase(_u(r'then push'), 'em seguida empurre');
    _addPhrase(_u(r'then pull'), 'em seguida puxe');
    _addPhrase(_u(r'then return'), 'em seguida retorne');
    _addPhrase(_u(r'then lower'), 'em seguida desça');
    _addPhrase(_u(r'then lift'), 'em seguida levante');
    _addPhrase(_u(r'then raise'), 'em seguida eleve');
    _addPhrase(_u(r'then twist'), 'em seguida gire');
    _addPhrase(_u(r'then rotate'), 'em seguida gire');
    _addPhrase(_u(r'then pause'), 'em seguida faça uma pausa');
    _addPhrase(_u(r'then repeat'), 'em seguida repita');
    _addPhrase(_u(r'then switch'), 'em seguida troque');
    _addPhrase(_u(r'then'), 'em seguida');

    // 3. VOCABULARY & POSSESSIVES
    final possessives = [
      ['knees', 'os joelhos'], ['knee', 'o joelho'],
      ['elbows', 'os cotovelos'], ['elbow', 'o cotovelo'],
      ['arms', 'os braços'], ['arm', 'o braço'],
      ['legs', 'as pernas'], ['leg', 'a perna'],
      ['chest', 'o peitoral'], ['back', 'as costas'],
      ['hips', 'o quadril'], ['hip', 'o quadril'],
      ['feet', 'os pés'], ['foot', 'o pé'],
      ['hands', 'as mãos'], ['hand', 'a mão'],
      ['head', 'a cabeça'], ['neck', 'o pescoço'],
      ['shoulders', 'os ombros'], ['shoulder', 'o ombro'],
      ['core', 'o core'], ['abs', 'o abdômen'],
      ['body', 'o corpo'], ['torso', 'o tronco'],
      ['heels', 'os calcanhares'], ['heel', 'o calcanhar'],
      ['toes', 'as pontas dos pés'], ['toe', 'a ponta do pé'],
      ['biceps', 'os bíceps'], ['triceps', 'os tríceps'],
      ['glutes', 'os glúteos'], ['quadriceps', 'os quadríceps'],
      ['quads', 'os quadríceps'], ['hamstrings', 'os posteriores de coxa'],
      ['calves', 'as panturrilhas'], ['lats', 'as dorsais'],
      ['upper body', 'o tronco'], ['lower body', 'os membros inferiores'],
      ['upper arms', 'os braços'], ['upper arm', 'o braço'],
      ['forearms', 'os antebraços'], ['forearm', 'o antebraço'],
      ['thighs', 'as coxas'], ['thigh', 'a coxa'],
      ['wrists', 'os punhos'], ['wrist', 'o punho'],
      ['shoulder blades', 'as escápulas'], ['spine', 'a coluna'],
      ['chin', 'o queixo'], ['face', 'o rosto'],
    ];

    for (final p in possessives) {
      _addVocab(_u('your ${p[0]}'), p[1]);
    }

    _addVocab(_u(r'your'), 'seu');

    _addVocab(_u(r'the barbell'), 'a barra');
    _addVocab(_u(r'a barbell'), 'uma barra');
    _addVocab(_u(r'the dumbbells'), 'os halteres');
    _addVocab(_u(r'the dumbbell'), 'o halter');
    _addVocab(_u(r'a dumbbell'), 'um halter');
    _addVocab(_u(r'dumbbells'), 'halteres');
    _addVocab(_u(r'dumbbell'), 'halter');
    _addVocab(_u(r'barbells'), 'barras');
    _addVocab(_u(r'barbell'), 'barra');
    _addVocab(_u(r'the bar'), 'a barra');
    _addVocab(_u(r'a bar'), 'uma barra');
    _addVocab(_u(r'the handles'), 'as manoplas');
    _addVocab(_u(r'the handle'), 'a manopla');
    _addVocab(_u(r'handles'), 'manoplas');
    _addVocab(_u(r'handle'), 'manopla');
    _addVocab(_u(r'the cable'), 'o cabo');
    _addVocab(_u(r'cables'), 'cabos');
    _addVocab(_u(r'cable'), 'cabo');
    _addVocab(_u(r'the machine'), 'o aparelho');
    _addVocab(_u(r'machines'), 'aparelhos');
    _addVocab(_u(r'machine'), 'aparelho');
    _addVocab(_u(r'the bench'), 'o banco');
    _addVocab(_u(r'a bench'), 'um banco');
    _addVocab(_u(r'bench'), 'banco');
    _addVocab(_u(r'the pad'), 'o apoio');
    _addVocab(_u(r'pads'), 'apoios');
    _addVocab(_u(r'pad'), 'apoio');
    _addVocab(_u(r'the rope'), 'a corda');
    _addVocab(_u(r'ropes'), 'cordas');
    _addVocab(_u(r'rope'), 'corda');
    _addVocab(_u(r'the floor'), 'o chão');
    _addVocab(_u(r'the ground'), 'o chão');
    _addVocab(_u(r'floor'), 'chão');
    _addVocab(_u(r'ground'), 'chão');
    _addVocab(_u(r'the weights'), 'os pesos');
    _addVocab(_u(r'the weight'), 'a carga');
    _addVocab(_u(r'weights'), 'pesos');
    _addVocab(_u(r'weight'), 'peso');

    _addVocab(_u(r'knees'), 'joelhos');
    _addVocab(_u(r'knee'), 'joelho');
    _addVocab(_u(r'elbows'), 'cotovelos');
    _addVocab(_u(r'elbow'), 'cotovelo');
    _addVocab(_u(r'arms'), 'braços');
    _addVocab(_u(r'arm'), 'braço');
    _addVocab(_u(r'legs'), 'pernas');
    _addVocab(_u(r'leg'), 'perna');
    _addVocab(_u(r'hands'), 'mãos');
    _addVocab(_u(r'hand'), 'mão');
    _addVocab(_u(r'feet'), 'pés');
    _addVocab(_u(r'foot'), 'pé');
    _addVocab(_u(r'shoulders'), 'ombros');
    _addVocab(_u(r'shoulder'), 'ombro');
    _addVocab(_u(r'hips'), 'quadril');
    _addVocab(_u(r'hip'), 'quadril');
    _addVocab(_u(r'chest'), 'peitoral');
    _addVocab(_u(r'heels'), 'calcanhares');
    _addVocab(_u(r'heel'), 'calcanhar');
    _addVocab(_u(r'toes'), 'pontas dos pés');
    _addVocab(_u(r'toe'), 'ponta do pé');
    _addVocab(_u(r'torso'), 'tronco');
    _addVocab(_u(r'body'), 'corpo');
    _addVocab(_u(r'head'), 'cabeça');
    _addVocab(_u(r'neck'), 'pescoço');

    _addVocab(_u(r'stand'), 'fique em pé');
    _addVocab(_u(r'sit'), 'sente-se');
    _addVocab(_u(r'lie'), 'deite-se');
    _addVocab(_u(r'hold'), 'segure');
    _addVocab(_u(r'holding'), 'segurando');
    _addVocab(_u(r'grasp'), 'segure');
    _addVocab(_u(r'place'), 'posicione');
    _addVocab(_u(r'position'), 'posição');
    _addVocab(_u(r'lower'), 'desça');
    _addVocab(_u(r'lowers'), 'desce');
    _addVocab(_u(r'lowering'), 'descendo');
    _addVocab(_u(r'raise'), 'eleve');
    _addVocab(_u(r'raising'), 'elevando');
    _addVocab(_u(r'lift'), 'levante');
    _addVocab(_u(r'lifting'), 'levantando');
    _addVocab(_u(r'push'), 'empurre');
    _addVocab(_u(r'pushing'), 'empurrando');
    _addVocab(_u(r'pull'), 'puxe');
    _addVocab(_u(r'pulling'), 'puxando');
    _addVocab(_u(r'press'), 'empurre');
    _addVocab(_u(r'pressing'), 'empurrando');
    _addVocab(_u(r'curl'), 'flexione');
    _addVocab(_u(r'curling'), 'flexionando');
    _addVocab(_u(r'bend'), 'flexione');
    _addVocab(_u(r'bending'), 'flexionando');
    _addVocab(_u(r'extend'), 'estenda');
    _addVocab(_u(r'extending'), 'estendendo');
    _addVocab(_u(r'reach'), 'alcance');
    _addVocab(_u(r'reaching'), 'alcançando');
    _addVocab(_u(r'touch'), 'toque');
    _addVocab(_u(r'touching'), 'tocando');
    _addVocab(_u(r'rotate'), 'gire');
    _addVocab(_u(r'rotating'), 'girando');
    _addVocab(_u(r'twist'), 'gire');
    _addVocab(_u(r'twisting'), 'girando');
    _addVocab(_u(r'lean'), 'incline');
    _addVocab(_u(r'leaning'), 'inclinando');
    _addVocab(_u(r'step'), 'dê um passo');
    _addVocab(_u(r'jump'), 'salte');
    _addVocab(_u(r'jumping'), 'saltando');
    _addVocab(_u(r'land'), 'aterrisse');
    _addVocab(_u(r'landing'), 'aterrissando');
    _addVocab(_u(r'rest'), 'apoie');
    _addVocab(_u(r'resting'), 'apoiando');
    _addVocab(_u(r'switch'), 'troque');
    _addVocab(_u(r'alternate'), 'alterne');
    _addVocab(_u(r'alternating'), 'alternando');
    _addVocab(_u(r'reverse'), 'inverta');
    _addVocab(_u(r'maintain'), 'mantenha');
    _addVocab(_u(r'maintaining'), 'mantendo');
    _addVocab(_u(r'contract'), 'contraia');
    _addVocab(_u(r'contracting'), 'contraindo');
    _addVocab(_u(r'release'), 'solte');
    _addVocab(_u(r'releasing'), 'soltando');
    _addVocab(_u(r'continue'), 'continue');
    _addVocab(_u(r'repeat'), 'repita');
    _addVocab(_u(r'exhale'), 'expire');
    _addVocab(_u(r'inhale'), 'inspire');
    _addVocab(_u(r'drive'), 'empurre com força');
    _addVocab(_u(r'hinge'), 'incline o tronco');
    _addVocab(_u(r'facing'), 'virado para');
    _addVocab(_u(r'adjust'), 'ajuste');
    _addVocab(_u(r'attach'), 'prenda');
    _addVocab(_u(r'attached'), 'preso');
    _addVocab(_u(r'engage'), 'contraia');
    _addVocab(_u(r'engaging'), 'contraindo');
    _addVocab(_u(r'bring'), 'aproxime');
    _addVocab(_u(r'bringing'), 'aproximando');
    _addVocab(_u(r'return'), 'retorne');
    _addVocab(_u(r'returning'), 'retornando');
    _addVocab(_u(r'straightening'), 'estendendo');
    _addVocab(_u(r'crossing'), 'cruzando');
    _addVocab(_u(r'cross'), 'cruze');

    _addPhrase(_u(r'as you slowly lower'), 'enquanto desce lentamente');
    _addPhrase(_u(r'as you slowly return'), 'enquanto retorna lentamente');
    _addPhrase(_u(r'as you slowly'), 'enquanto lentamente');
    _addPhrase(_u(r'as you'), 'ao');
    _addVocab(_u(r'contraction'), 'contração');
    _addVocab(_u(r'brief'), 'breve');

    _addPhrase(_u(r'keep your back straight and your core engaged'), 'mantenha a coluna ereta e o abdômen contraído');
    _addPhrase(_u(r'keep your back straight and chest lifted'), 'mantenha a coluna ereta e o peito erguido');
    _addPhrase(_u(r'keep your back straight and chest up'), 'mantenha a coluna ereta e o peito erguido');
    _addPhrase(_u(r'keep your back straight'), 'mantenha a coluna ereta');
    _addPhrase(_u(r'keep your core engaged'), 'mantenha o abdômen contraído');
    _addPhrase(_u(r'keep your core tight'), 'mantenha o abdômen firme');
    _addPhrase(_u(r'keep your chest up'), 'mantenha o peito erguido');
    _addPhrase(_u(r'keep your arms straight'), 'mantenha os braços estendidos');
    _addPhrase(_u(r'keep your elbows close to your body'), 'mantenha os cotovelos junto ao corpo');
    _addPhrase(_u(r'keep your elbows close to your ears'), 'mantenha os cotovelos próximos às orelhas');
    _addPhrase(_u(r'keep your elbows tucked in'), 'mantenha os cotovelos fechados');
    _addPhrase(_u(r'keep your'), 'mantenha seu');
    _addPhrase(_u(r'keep the'), 'mantenha o');
    _addPhrase(_u(r'keep'), 'mantenha');

    _addPhrase(_u(r'fully extended'), 'totalmente estendido');
    _addPhrase(_u(r'extended straight'), 'estendido em linha reta');
    _addPhrase(_u(r'arms extended'), 'braços estendidos');
    _addPhrase(_u(r'legs extended'), 'pernas estendidas');
    _addPhrase(_u(r'extended'), 'estendido');

    _addPhrase(_u(r'slightly bent'), 'levemente flexionados');
    _addPhrase(_u(r'bent at a 90-degree angle'), 'flexionado a 90 graus');
    _addPhrase(_u(r'bent'), 'flexionado');

    _addPhrase(_u(r'until your torso is at a 45-degree angle'), 'até o tronco formar um ângulo de 45 graus');
    _addPhrase(_u(r'until your torso is parallel to the ground'), 'até o tronco ficar paralelo ao chão');
    _addPhrase(_u(r'until your torso is parallel to the floor'), 'até o tronco ficar paralelo ao chão');
    _addPhrase(_u(r'until your thighs are parallel to the ground'), 'até as coxas ficarem paralelas ao chão');
    _addPhrase(_u(r'until your thighs are parallel to the floor'), 'até as coxas ficarem paralelas ao chão');
    _addPhrase(_u(r'until your thigh is parallel to the ground'), 'até a coxa ficar paralela ao chão');
    _addPhrase(_u(r'until your thigh is parallel to the floor'), 'até a coxa ficar paralela ao chão');
    _addPhrase(_u(r'is parallel to the ground'), 'está paralelo ao chão');
    _addPhrase(_u(r'is parallel to the floor'), 'está paralelo ao chão');
    _addPhrase(_u(r'is parallel to'), 'está paralelo a');
    _addPhrase(_u(r'is at a 45-degree angle'), 'forma um ângulo de 45 graus');
    _addPhrase(_u(r'is at a'), 'está em um');

    _addPhrase(_u(r'to one side'), 'para um lado');
    _addPhrase(_u(r'on one side'), 'de um lado');
    _addPhrase(_u(r'one side'), 'um lado');
    _addPhrase(_u(r'one hand'), 'uma mão');
    _addPhrase(_u(r'one arm'), 'um braço');
    _addPhrase(_u(r'one leg'), 'uma perna');
    _addPhrase(_u(r'one foot'), 'um pé');
    _addPhrase(_u(r'one dumbbell'), 'um halter');
    _addPhrase(_u(r'one at a time'), 'um de cada vez');

    _addPhrase(_u(r'in front of your chest'), 'em frente ao peitoral');
    _addPhrase(_u(r'in front of your body'), 'em frente ao corpo');
    _addPhrase(_u(r'in front of you'), 'à sua frente');
    _addPhrase(_u(r'in front of'), 'em frente a');

    _addPhrase(_u(r'so that your'), 'de modo que seu');
    _addPhrase(_u(r'so that the'), 'de modo que o');
    _addPhrase(_u(r'so that'), 'de modo que');

    _addPhrase(_u(r'start by'), 'comece');
    _addPhrase(_u(r'start with'), 'comece com');
    _addPhrase(_u(r'starting with'), 'começando com');

    _addPhrase(_u(r'overhead'), 'acima da cabeça');
    _addPhrase(_u(r'above your head'), 'acima da cabeça');
    _addPhrase(_u(r'behind your head'), 'atrás da cabeça');
    _addPhrase(_u(r'above'), 'acima');

    _addPhrase(_u(r'at the top of the movement'), 'no topo do movimento');
    _addPhrase(_u(r'at the bottom of the movement'), 'embaixo no movimento');
    _addPhrase(_u(r'at the top'), 'no topo');
    _addPhrase(_u(r'at the bottom'), 'embaixo');

    _addPhrase(_u(r'close to your body'), 'junto ao corpo');
    _addPhrase(_u(r'close to your ears'), 'junto às orelhas');
    _addPhrase(_u(r'close grip'), 'pegada fechada');
    _addPhrase(_u(r'close to'), 'próximo a');
    _addPhrase(_u(r'close'), 'fechado');

    _addPhrase(_u(r'through your heels'), 'pelos calcanhares');
    _addPhrase(_u(r'through your heel'), 'pelo calcanhar');
    _addPhrase(_u(r'through'), 'através de');

    _addPhrase(_u(r'feel a stretch in your'), 'sentir um alongamento em seu');
    _addPhrase(_u(r'feel a stretch'), 'sentir um alongamento');
    _addPhrase(_u(r'stretch in your'), 'alongamento em seu');
    _addPhrase(_u(r'stretch'), 'alongamento');

    _addPhrase(_u(r'resistance band'), 'elástico de resistência');
    _addPhrase(_u(r'band'), 'elástico');
    _addPhrase(_u(r'ball'), 'bola');

    _addVocab(_u(r'one'), 'um');
    _addVocab(_u(r'two'), 'dois');
    _addVocab(_u(r'three'), 'três');
    _addVocab(_u(r'four'), 'quatro');
    _addVocab(_u(r'you'), 'você');
    _addVocab(_u(r'are'), 'estão');
    _addVocab(_u(r'is'), 'está');
    _addVocab(_u(r'it'), 'o peso');
    _addVocab(_u(r'them'), 'os pesos');
    _addVocab(_u(r'of'), 'de');
    _addVocab(_u(r'top'), 'topo');
    _addVocab(_u(r'high'), 'alto');
    _addVocab(_u(r'low'), 'baixo');
    _addVocab(_u(r'start'), 'inicie');

    // Unicode safe boundaries on all short words
    _addVocab(_u(r'the'), 'o');
    _addVocab(_u(r'with'), 'com');
    _addVocab(_u(r'without'), 'sem');
    _addVocab(_u(r'until'), 'até');
    _addVocab(_u(r'while'), 'enquanto');
    _addVocab(_u(r'and'), 'e');
    _addVocab(_u(r'or'), 'ou');
    _addVocab(_u(r'back'), 'de volta');
    _addVocab(_u(r'down'), 'para baixo');
    _addVocab(_u(r'up'), 'para cima');
    _addVocab(_u(r'out'), 'para fora');
    _addVocab(_u(r'in'), 'em');
    _addVocab(_u(r'on'), 'em');
    _addVocab(_u(r'at'), 'em');
    _addVocab(_u(r'from'), 'de');
    _addVocab(_u(r'to'), 'para');
    _addVocab(_u(r'for'), 'por');
    _addVocab(_u(r'by'), 'por');
    _addVocab(_u(r'over'), 'sobre');
    _addVocab(_u(r'under'), 'sob');
    _addVocab(_u(r'across'), 'através de');
    _addVocab(_u(r'against'), 'contra');
    _addVocab(_u(r'between'), 'entre');
    _addVocab(_u(r'both'), 'ambos os');
    _addVocab(_u(r'each'), 'cada');
    _addVocab(_u(r'other'), 'outro');
    _addVocab(_u(r'forward'), 'para a frente');
    _addVocab(_u(r'backward'), 'para trás');
    _addVocab(_u(r'upward'), 'para cima');
    _addVocab(_u(r'downward'), 'para baixo');
    _addVocab(_u(r'outward'), 'para fora');
    _addVocab(_u(r'inward'), 'para dentro');
    _addVocab(_u(r'slowly'), 'lentamente');
    _addVocab(_u(r'slightly'), 'levemente');
    _addVocab(_u(r'fully'), 'totalmente');
    _addVocab(_u(r'straight'), 'reto');
    _addVocab(_u(r'flat'), 'apoiado');
    _addVocab(_u(r'apart'), 'afastados');
    _addVocab(_u(r'together'), 'juntos');
    _addVocab(_u(r'parallel'), 'paralelo');
    _addVocab(_u(r'height'), 'altura');
    _addVocab(_u(r'degrees'), 'graus');
    _addVocab(_u(r'movement'), 'movimento');
    _addVocab(_u(r'motion'), 'movimento');
    _addVocab(_u(r'contracted'), 'contraído');
    _addVocab(_u(r'level'), 'altura');
    _addVocab(_u(r'width'), 'largura');
    _addVocab(_u(r'angle'), 'ângulo');
    _addVocab(_u(r'grip'), 'pegada');
    _addVocab(_u(r'sides'), 'lados');
    _addVocab(_u(r'side'), 'lado');
    _addVocab(_u(r'front'), 'frente');
    _addVocab(_u(r'away'), 'longe');
    _addVocab(_u(r'behind'), 'atrás');
    _addVocab(_u(r'towards'), 'em direção a');
    _addVocab(_u(r'moment'), 'instante');
    _addVocab(_u(r'desired'), 'desejado');
    _addVocab(_u(r'repetitions'), 'repetições');
  }


  static String translate(String s) {
    _init();
    final text = s.trim();
    if (text.isEmpty) return text;
    if (_exact.containsKey(text)) return _exact[text]!;
    var res = text;
    for (final e in _clausePatterns) {
      res = res.replaceAll(e.key, e.value);
    }
    for (final e in _phrasePatterns) {
      res = res.replaceAll(e.key, e.value);
    }
    for (final e in _vocabPatterns) {
      res = res.replaceAll(e.key, e.value);
    }
    return _postProcess(res);
  }

  static String _postProcess(String text) {
    var res = text;
    res = res.replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])de o(?![a-zA-ZÀ-ÿ])'), 'do')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])de a(?![a-zA-ZÀ-ÿ])'), 'da')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])de os(?![a-zA-ZÀ-ÿ])'), 'dos')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])de as(?![a-zA-ZÀ-ÿ])'), 'das')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])em o(?![a-zA-ZÀ-ÿ])'), 'no')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])em a(?![a-zA-ZÀ-ÿ])'), 'na')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])em os(?![a-zA-ZÀ-ÿ])'), 'nos')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])em as(?![a-zA-ZÀ-ÿ])'), 'nas')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])a o(?![a-zA-ZÀ-ÿ])'), 'ao')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])a os(?![a-zA-ZÀ-ÿ])'), 'aos')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])a a(?![a-zA-ZÀ-ÿ])'), 'à')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])a as(?![a-zA-ZÀ-ÿ])'), 'às')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])por o(?![a-zA-ZÀ-ÿ])'), 'pelo')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])por a(?![a-zA-ZÀ-ÿ])'), 'pela')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])por os(?![a-zA-ZÀ-ÿ])'), 'pelos')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])por as(?![a-zA-ZÀ-ÿ])'), 'pelas')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])para o(?![a-zA-ZÀ-ÿ])'), 'para o')
             .replaceAll(RegExp(r'(?<![a-zA-ZÀ-ÿ])para a(?![a-zA-ZÀ-ÿ])'), 'para a');

    res = res.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (res.isNotEmpty) {
      res = res[0].toUpperCase() + res.substring(1);
    }
    return res;
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
