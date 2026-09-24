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
      equipStr = 'no Graviton / Assistido';
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

  /// Tradução automática contextual e gramatical das instruções de treino
  static List<String> translateInstructions(List<dynamic> rawSteps) {
    if (rawSteps.isEmpty) return const [];
    return rawSteps.map((s) => _translateSentence(s.toString())).toList();
  }

  static String _translateSentence(String text) {
    var s = text.trim();
    if (s.isEmpty) return s;

    final exactPhrases = <String, String>{
      'Repeat for the desired number of repetitions.':
          'Repita pelo número desejado de repetições.',
      'Continue alternating sides for the desired number of repetitions.':
          'Continue alternando os lados pelo número desejado de repetições.',
      'Hold the contracted position for a brief pause as you squeeze your biceps.':
          'Segure a posição contraída com uma breve pausa, contraindo bem os bíceps.',
      'Repeat for the desired number of repetitions, then switch arms.':
          'Repita pelo número desejado de repetições e troque de braço.',
      'Repeat for the desired number of repetitions, then switch sides.':
          'Repita pelo número desejado de repetições e troque de lado.',
      'Repeat for the desired number of repetitions, then switch to the other arm.':
          'Repita pelo número desejado de repetições e mude para o outro braço.',
      'Lie flat on your back with your knees bent and feet flat on the ground.':
          'Deite-se de costas no chão com os joelhos flexionados e os pés apoiados.',
      'Lie flat on a bench with your feet flat on the ground.':
          'Deite-se no banco reto com os pés firmes no chão.',
      'Stand with your feet shoulder-width apart and your knees slightly bent.':
          'Fique em pé com os pés na largura dos ombros e joelhos levemente flexionados.',
      'Stand with your feet shoulder-width apart.':
          'Fique em pé com os pés afastados na largura dos ombros.',
      'Stand facing the machine with your feet shoulder-width apart.':
          'Fique de frente para a máquina com os pés na largura dos ombros.',
      'Stand facing the cable machine with your feet shoulder-width apart.':
          'Fique de frente para a polia com os pés afastados na largura dos ombros.',
      'Sit on a bench with your back straight and feet flat on the ground.':
          'Sente-se no banco com as costas retas e os pés firmes no chão.',
      'Set up an incline bench at a 45-degree angle.':
          'Ajuste o banco inclinado a um ângulo de 45 graus.',
      'Place your hands behind your head with your elbows pointing outwards.':
          'Coloque as mãos atrás da cabeça com os cotovelos apontando para fora.',
      'Bend your knees slightly and hinge forward at the hips, keeping your back straight.':
          'Flexione levemente os joelhos e incline o tronco à frente a partir do quadril, mantendo a coluna ereta.',
      'Keep your back straight and your core engaged.':
          'Mantenha as costas retas e o abdômen contraído.',
      'Keeping your upper arms stationary, exhale and curl the weights while contracting your biceps.':
          'Mantendo os braços firmes, expire e flexione os antebraços contraindo os bíceps.',
      'Continue to raise the dumbbells until your biceps are fully contracted and the dumbbells are at shoulder level.':
          'Continue levantando os halteres até a contração máxima dos bíceps na altura dos ombros.',
      'Inhale and slowly begin to lower the dumbbells back to the starting position.':
          'Inspire e comece a descer lentamente os halteres de volta à posição inicial.',
      'Pause for a moment at the top, then slowly lower your upper body back down to the starting position.':
          'Faça uma breve pausa no topo e desça lentamente o tronco à posição inicial.',
      'Pause for a moment at the top, then slowly lower your heels back down to the starting position.':
          'Faça uma pausa no topo e desça lentamente os calcanhares à posição inicial.',
      'Pause for a moment at the top, then slowly lower your legs back down to the starting position.':
          'Faça uma pausa no topo e desça lentamente as pernas à posição inicial.',
      'Pause for a moment at the top, then slowly lower your arms back down to the starting position.':
          'Faça uma pausa no topo e desça lentamente os braços de volta à posição inicial.',
      'Pause for a moment at the top, then slowly lower your body back down to the starting position.':
          'Faça uma pausa no topo e retorne o corpo controladamente à posição inicial.',
      'Pause for a moment at the bottom, then push through your heels to return to the starting position.':
          'Faça uma breve pausa embaixo e empurre pelos calcanhares para retornar à posição inicial.',
      'Pause for a moment at the top, squeezing your biceps.':
          'Faça uma breve pausa no topo, contraindo bem os bíceps.',
      'Pause for a moment at the top, then slowly lower the dumbbell back to the starting position.':
          'Faça uma breve pausa no topo e desça lentamente o halter de volta à posição inicial.',
      'Pause for a moment at the top, then slowly lower the dumbbells back to the starting position.':
          'Faça uma pausa no topo e desça lentamente os halteres à posição inicial.',
      'Repeat on the other side.':
          'Repita do outro lado.',
      'Exhale as you push and inhale as you return.':
          'Expire ao empurrar e inspire ao retornar à posição inicial.',
      'Grasp the barbell with an overhand grip slightly wider than shoulder-width apart.':
          'Segure a barra com pegada pronada um pouco mais aberta que a largura dos ombros.',
      'Hold a dumbbell in each hand.':
          'Segure um halter em cada mão.',
    };

    if (exactPhrases.containsKey(s)) {
      return exactPhrases[s]!;
    }

    final replacements = <RegExp, String>{
      RegExp(r'\bstarting position\b', caseSensitive: false): 'posição inicial',
      RegExp(r'\bshoulder-width apart\b', caseSensitive: false): 'na largura dos ombros',
      RegExp(r'\bknees slightly bent\b', caseSensitive: false): 'joelhos levemente flexionados',
      RegExp(r'\bback straight\b', caseSensitive: false): 'costas retas',
      RegExp(r'\bcore engaged\b', caseSensitive: false): 'abdômen contraído',
      RegExp(r'\bupper body\b', caseSensitive: false): 'parte superior do tronco',
      RegExp(r'\blower body\b', caseSensitive: false): 'membros inferiores',
      RegExp(r'\bpause for a moment\b', caseSensitive: false): 'faça uma breve pausa',
      RegExp(r'\bslowly lower\b', caseSensitive: false): 'desça lentamente',
      RegExp(r'\bslowly return\b', caseSensitive: false): 'retorne lentamente',
      RegExp(r'\bdesired number of repetitions\b', caseSensitive: false): 'número desejado de repetições',
      RegExp(r'\boverhand grip\b', caseSensitive: false): 'pegada pronada',
      RegExp(r'\bunderhand grip\b', caseSensitive: false): 'pegada supinada',
      RegExp(r'\bneutral grip\b', caseSensitive: false): 'pegada neutra',
      RegExp(r'\bexhale as you\b', caseSensitive: false): 'expire ao',
      RegExp(r'\binhale as you\b', caseSensitive: false): 'inspire ao',
      RegExp(r'\bsqueeze your\b', caseSensitive: false): 'contraia os seus',
      RegExp(r'\bbiceps\b', caseSensitive: false): 'bíceps',
      RegExp(r'\btriceps\b', caseSensitive: false): 'tríceps',
      RegExp(r'\bchest\b', caseSensitive: false): 'peitoral',
      RegExp(r'\bglutes\b', caseSensitive: false): 'glúteos',
      RegExp(r'\bhamstrings\b', caseSensitive: false): 'posteriores de coxa',
      RegExp(r'\bquadriceps\b', caseSensitive: false): 'quadríceps',
      RegExp(r'\bquads\b', caseSensitive: false): 'quadríceps',
      RegExp(r'\bcalves\b', caseSensitive: false): 'panturrilhas',
      RegExp(r'\bshoulders\b', caseSensitive: false): 'ombros',
      RegExp(r'\bdumbbell\b', caseSensitive: false): 'halter',
      RegExp(r'\bdumbbells\b', caseSensitive: false): 'halteres',
      RegExp(r'\bbarbell\b', caseSensitive: false): 'barra',
      RegExp(r'\bbench\b', caseSensitive: false): 'banco',
      RegExp(r'\bfloor\b', caseSensitive: false): 'chão',
    };

    for (final entry in replacements.entries) {
      s = s.replaceAll(entry.key, entry.value);
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
