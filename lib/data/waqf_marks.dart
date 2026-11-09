import '../localization/app_strings.dart';

class WaqfMarkDefinition {
  const WaqfMarkDefinition({
    required this.symbol,
    required this.arabicName,
    required this.referenceBeforeExample,
    required this.quranExample,
    required this.quranReference,
    required this.referenceAfterExample,
  });

  final String symbol;
  final String arabicName;
  final String referenceBeforeExample;
  final String quranExample;
  final String quranReference;
  final String referenceAfterExample;
}

class WaqfReferenceSection {
  const WaqfReferenceSection({
    required this.title,
    required this.paragraphs,
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

class WaqfMarkReferenceDetail {
  const WaqfMarkReferenceDetail({
    required this.beforeExample,
    required this.afterExample,
  });

  final String beforeExample;
  final String afterExample;
}

class WaqfMarksContent {
  const WaqfMarksContent({
    required this.title,
    required this.intro,
    required this.note,
    required this.teacherNote,
    required this.explanations,
  });

  final String title;
  final String intro;
  final String note;
  final String teacherNote;
  final List<String> explanations;
}

const waqfMarkDefinitions = <WaqfMarkDefinition>[
  WaqfMarkDefinition(
    symbol: 'م',
    arabicName: 'وقف لازم',
    referenceBeforeExample: 'م: تعني لزوم الوقف، كقوله -تعالى-:',
    quranExample: 'إِنَّمَا يَسْتَجِيبُ ٱلَّذِينَ يَسْمَعُونَ ۘ وَٱلْمَوْتَىٰ يَبْعَثُهُمُ ٱللَّهُ ثُمَّ إِلَيْهِ يُرْجَعُونَ',
    quranReference: 'الأنعام: ٣٦',
    referenceAfterExample: 'فهنا يجب الوقوف على كلمة «يَسْمَعُونَ».',
  ),
  WaqfMarkDefinition(
    symbol: 'لا',
    arabicName: 'لا تقف',
    referenceBeforeExample:
        'لا: وتعني الوقف الممنوع، أو النهي عن الوقف، كقوله -تعالى-:',
    quranExample: 'ٱلَّذِينَ تَتَوَفَّىٰهُمُ ٱلْمَلَـٰٓئِكَةُ طَيِّبِينَ ۙ يَقُولُونَ سَلَـٰمٌ عَلَيْكُمُ ٱدْخُلُوا۟ ٱلْجَنَّةَ بِمَا كُنتُمْ تَعْمَلُونَ',
    quranReference: 'النحل: ٣٢',
    referenceAfterExample: 'فهنا يمنع الوقوف على كلمة «طَيِّبِينَ».',
  ),
  WaqfMarkDefinition(
    symbol: 'ج',
    arabicName: 'وقف جائز',
    referenceBeforeExample:
        'ج: وتعني أن القارئ يجوز له الوقف والوصل، كقوله -تعالى-:',
    quranExample: 'نَّحْنُ نَقُصُّ عَلَيْكَ نَبَأَهُم بِٱلْحَقِّ ۚ إِنَّهُمْ فِتْيَةٌ ءَامَنُوا۟ بِرَبِّهِمْ وَزِدْنَـٰهُمْ هُدًى',
    quranReference: 'الكهف: ١٣',
    referenceAfterExample: 'فهنا يجوز الوقف على كلمة «بِٱلْحَقِّ»، ويجوز عدم الوقوف عليها أو ما يُسمّى بالوصل.',
  ),
  WaqfMarkDefinition(
    symbol: 'قلى',
    arabicName: 'الوقف أولى',
    referenceBeforeExample: 'قلى أو قلي: وتعني أن القارئ يجوز له الوصل مع أن الوقف أفضل وأولى، كقوله -تعالى-:',
    quranExample: 'قُل رَّبِّىٓ أَعْلَمُ بِعِدَّتِهِم مَّا يَعْلَمُهُمْ إِلَّا قَلِيلٌ ۗ فَلَا تُمَارِ فِيهِمْ',
    quranReference: 'الكهف: ٢٢',
    referenceAfterExample:
        'فهنا يجوز عدم الوقف على كلمة «قَلِيلٌ»، مع أن الوقف عليها أولى وأفضل.',
  ),
  WaqfMarkDefinition(
    symbol: 'صلى',
    arabicName: 'الوصل أولى',
    referenceBeforeExample: 'صلى أو صلي: وتعني أن القارئ يجوز له الوقف مع كون الوصل أفضل وأولى، كقوله -تعالى-:',
    quranExample: 'وَإِن يَمْسَسْكَ ٱللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُۥٓ إِلَّا هُوَ ۖ وَإِن يَمْسَسْكَ بِخَيْرٍ فَهُوَ عَلَىٰ كُلِّ شَىْءٍ قَدِيرٌ',
    quranReference: 'الأنعام: ١٧',
    referenceAfterExample:
        'فهنا يجوز الوقف على كلمة «لَهُۥ» مع أن عدم الوقف، أي الوصل، أفضل.',
  ),
  WaqfMarkDefinition(
    symbol: 'ۛ ۛ',
    arabicName: 'وقف المعانقة',
    referenceBeforeExample: 'ثلاث نقاط مثلثة: وتُسمّى هذه بعلامة التعانق؛ وتعني أنه إذا وقف القارئ على إحداهما يصل الأخرى ولا يقف عليها، كقوله -تعالى-:',
    quranExample:
        'ذَٰلِكَ ٱلْكِتَـٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
    quranReference: 'البقرة: ٢',
    referenceAfterExample: 'فهنا إذا وقف القارئ على كلمة «رَيْبَ» لا يجوز له الوقف على كلمة «فِيهِ»، والعكس كذلك.',
  ),
];

const waqfReferenceSections = <WaqfReferenceSection>[
  WaqfReferenceSection(
    title: 'علامات الوقف في المصحف الشريف',
    paragraphs: [
      'ويحتاج القارئ إلى علامات الوقف لتقسيم الآيات، وليختار الوقف المناسب لإتمام المعنى، وقد كانت المصاحف في بدايتها تخلو من علامات الوقف، ثم قام العلماء بعد ذلك بوضع علامات الوقف والإشارة إليها برموز لها معنى خاص، وللوقف ست علامات، وقد يجد القارئ بعض الاختلاف في علامات الوقف بحسب الرواية المطبوع بها المصحف.',
    ],
  ),
  WaqfReferenceSection(
    title: 'الوقف في القرآن الكريم',
    paragraphs: [
      'تعريف الوقف وحكمه',
      'يُعرّف الوقف في اللغة بالكف والحبس، وأما في التجويد: فهو قطع الصوت عن آخر كلمة وقفًا ليتنفس القارئ خلاله، بنية إعادة القراءة، ولا يكون في وسط الكلمة، وحكمه الجواز، ما لم يوجد مانع كان يؤدي إلى تغيير المعنى المراد، ويُقدَّر وقت الوقف بمقدار الحركتين، ويكون في رؤوس الآيات أو وسطها، ولا يجوز في وسط الكلمات، أو ما كان متصلاً رسمًا كلمة: إنما.',
    ],
  ),
  WaqfReferenceSection(
    title: 'أنواع الوقف',
    paragraphs: [
      'الوقف الاختباري: وهو أن يقف القارئ على كلمة لا تصلح للوقف، ويكون ذلك من المعلّم بقصد اختبار تلميذه في حكم الكلمة من حيث القطع أو الوصل أو الإثبات أو الحذف، وغير ذلك من الأحكام، وحكمه الجواز ما دام في مقام الاختبار أو التعليم فقط.',
      'الوقف الانتظاري: وهو أن يقف القارئ على الكلمة القرآنية التي لها أكثر من وجه في القراءة؛ ليعطف عليها غيرها، وسُمّي بذلك؛ لأن المعلّم ينتظر التلميذ لبيان جميع الأوجه أو الروايات المتعلقة بالكلمة، وحكمه الجواز؛ حتى وإن لم يتم المعنى.',
      'الوقف الاضطراري: وهو أن يقف القارئ على كلمة ليست محلاً للوقف بسبب ظرف ألجأه للوقف، كضيق التنفس، أو السعال، وغير ذلك، وحكمه الجواز حتى انتهاء الضرورة، بشرط أن يعود القارئ إلى الكلمة التي وقف عليها فيصلها بما بعدها إن صلح الابتداء بها، وإلا يعود إلى ما قبلها.',
      'الوقف الاختياري: وهو أن يقف القارئ على الكلمة القرآنية بمحض إرادته، ويشترط فيه الوقوف على كلام تام المعنى، وحكمه الجواز؛ إلا إذا كان فيه تغيير للمعنى، أو فُهِم منه معنى غير المعنى المقصود، ويكون هذا الوقف مقصودًا لذاته من غير أسباب.',
    ],
  ),
  WaqfReferenceSection(
    title: 'أهمية الوقف',
    paragraphs: ['إن للوقف أهمية وفوائد عدة، ومنها ما يأتي:'],
    bullets: [
      'معرفة معاني القرآن أثناء قراءته، واستنباط الأدلة الشرعية، ومعرفة الحلال والحرام والأوامر والنواهي.',
      'معرفة القارئ دلالة ودرجات الوقوف؛ مما يشعر بفهمه للقرآن.',
    ],
  ),
];

const _content = <AppLanguage, WaqfMarksContent>{
  AppLanguage.arabic: WaqfMarksContent(
    title: 'علامات الوقف',
    intro: 'ترشد هذه العلامات إلى مواضع الوقف والوصل للمحافظة على سلامة المعنى أثناء التلاوة.',
    note: 'قد تختلف بعض الرموز قليلًا باختلاف طبعة المصحف والرواية.',
    teacherNote: 'للتصحيح العملي للتلاوة، يُنصح بالتعلّم على يد معلّم مؤهل.',
    explanations: [
      'قف هنا لتجنب وصلٍ قد يوهم معنى غير المراد.',
      'صِل القراءة؛ فالوقف هنا قد يقطع المعنى النحوي المقصود.',
      'يجوز الوقف ويجوز الوصل.',
      'الوقف أولى، مع جواز الوصل.',
      'الوصل أولى، مع جواز الوقف.',
      'عند ظهور العلامتين المتقابلتين، قف عند إحداهما فقط ولا تقف عندهما معًا.',
    ],
  ),
  AppLanguage.english: WaqfMarksContent(
    title: 'Waqf Marks',
    intro: 'These signs guide where to pause or continue so that recitation preserves the intended meaning.',
    note: 'Notation can vary slightly by Mushaf edition and recitation tradition.',
    teacherNote:
        'For practical recitation correction, learn with a qualified teacher.',
    explanations: [
      'Stop here to avoid joining the words in a way that can suggest an unintended meaning.',
      'Continue reading; stopping here may interrupt the intended grammatical meaning.',
      'You may stop or continue.',
      'Stopping is preferred, while continuing remains permitted.',
      'Continuing is preferred, while stopping remains permitted.',
      'When the paired marks appear, stop at one position only, not both.',
    ],
  ),
  AppLanguage.chinese: WaqfMarksContent(
    title: '停顿标记',
    intro: '这些标记指导诵读时应停顿或继续的位置，以保持原本的含义。',
    note: '不同版本的古兰经和诵读传统中，标记可能略有不同。',
    teacherNote: '如需实际诵读纠正，建议向合格教师学习。',
    explanations: [
      '在此停顿，以避免连读造成非预期的含义。',
      '应继续诵读；在此停顿可能会中断原本的语法含义。',
      '可以停顿，也可以继续。',
      '更推荐停顿，但继续诵读也是允许的。',
      '更推荐继续诵读，但停顿也是允许的。',
      '出现成对标记时，只在其中一处停顿，不要两处都停。',
    ],
  ),
  AppLanguage.hindi: WaqfMarksContent(
    title: 'वक़्फ़ के चिह्न',
    intro: 'ये चिह्न बताते हैं कि अर्थ को सुरक्षित रखने के लिए कहाँ रुकना या पढ़ना जारी रखना है।',
    note: 'मुस्हफ़ के संस्करण और क़िराअत की परंपरा के अनुसार चिह्न थोड़ा अलग हो सकते हैं।',
    teacherNote: 'व्यावहारिक तिलावत सुधार के लिए योग्य शिक्षक से सीखें।',
    explanations: [
      'यहाँ रुकें ताकि शब्दों को ऐसे न जोड़ा जाए जिससे गलत अर्थ निकले।',
      'पढ़ना जारी रखें; यहाँ रुकने से इच्छित व्याकरणिक अर्थ टूट सकता है।',
      'रुकना या जारी रखना, दोनों जायज़ हैं।',
      'रुकना बेहतर है, हालांकि जारी रखना भी जायज़ है।',
      'जारी रखना बेहतर है, हालांकि रुकना भी जायज़ है।',
      'जब जोड़ीदार चिह्न हों, तो केवल एक स्थान पर रुकें, दोनों पर नहीं।',
    ],
  ),
  AppLanguage.spanish: WaqfMarksContent(
    title: 'Marcas de pausa',
    intro: 'Estas marcas indican dónde pausar o continuar para conservar el significado durante la recitación.',
    note: 'La notación puede variar ligeramente según la edición del Mushaf y la tradición de recitación.',
    teacherNote: 'Para corregir la recitación en la práctica, estudie con un maestro cualificado.',
    explanations: [
      'Deténgase aquí para evitar una unión que pueda sugerir un significado no deseado.',
      'Continúe leyendo; detenerse aquí puede interrumpir el significado gramatical previsto.',
      'Puede detenerse o continuar.',
      'Es preferible detenerse, aunque continuar sigue estando permitido.',
      'Es preferible continuar, aunque detenerse sigue estando permitido.',
      'Cuando aparezcan las dos marcas, deténgase solo en una de ellas, no en ambas.',
    ],
  ),
  AppLanguage.french: WaqfMarksContent(
    title: 'Signes d’arrêt',
    intro: 'Ces signes indiquent où s’arrêter ou poursuivre afin de préserver le sens pendant la récitation.',
    note: 'La notation peut varier légèrement selon l’édition du Mushaf et la tradition de récitation.',
    teacherNote: 'Pour corriger la récitation en pratique, apprenez avec un enseignant qualifié.',
    explanations: [
      'Arrêtez-vous ici afin d’éviter une liaison pouvant suggérer un sens non voulu.',
      'Poursuivez la lecture ; s’arrêter ici peut interrompre le sens grammatical voulu.',
      'Vous pouvez vous arrêter ou continuer.',
      'S’arrêter est préférable, même si continuer reste permis.',
      'Continuer est préférable, même si s’arrêter reste permis.',
      'Lorsque les deux marques apparaissent, arrêtez-vous à un seul endroit, pas aux deux.',
    ],
  ),
  AppLanguage.bengali: WaqfMarksContent(
    title: 'ওয়াকফের চিহ্ন',
    intro: 'এই চিহ্নগুলো তিলাওয়াতে অর্থ অক্ষুণ্ণ রাখতে কোথায় থামতে বা চালিয়ে যেতে হবে তা নির্দেশ করে।',
    note: 'মুসহাফের সংস্করণ ও কিরাআতের রীতিভেদে চিহ্ন সামান্য ভিন্ন হতে পারে।',
    teacherNote:
        'তিলাওয়াতের ব্যবহারিক সংশোধনের জন্য একজন যোগ্য শিক্ষকের কাছে শিখুন।',
    explanations: [
      'এখানে থামুন, যাতে এমন সংযোগ না হয় যা অনিচ্ছাকৃত অর্থ বোঝায়।',
      'পড়া চালিয়ে যান; এখানে থামলে উদ্দেশ্যপ্রণোদিত ব্যাকরণগত অর্থ ভেঙে যেতে পারে।',
      'থামা বা চালিয়ে যাওয়া—দুটিই বৈধ।',
      'থামা উত্তম, তবে চালিয়ে যাওয়াও বৈধ।',
      'চালিয়ে যাওয়া উত্তম, তবে থামাও বৈধ।',
      'জোড়া চিহ্ন দেখা গেলে শুধু একটিতে থামুন, দুটিতে নয়।',
    ],
  ),
  AppLanguage.portuguese: WaqfMarksContent(
    title: 'Marcas de pausa',
    intro: 'Estas marcas indicam onde parar ou continuar para preservar o sentido durante a recitação.',
    note: 'A notação pode variar ligeiramente conforme a edição do Mushaf e a tradição de recitação.',
    teacherNote: 'Para corrigir a recitação na prática, aprenda com um professor qualificado.',
    explanations: [
      'Pare aqui para evitar uma ligação que possa sugerir um sentido não pretendido.',
      'Continue a leitura; parar aqui pode interromper o sentido gramatical pretendido.',
      'Pode parar ou continuar.',
      'Parar é preferível, embora continuar continue permitido.',
      'Continuar é preferível, embora parar continue permitido.',
      'Quando as marcas emparelhadas aparecerem, pare apenas numa posição, não nas duas.',
    ],
  ),
  AppLanguage.indonesian: WaqfMarksContent(
    title: 'Tanda waqaf',
    intro: 'Tanda ini menunjukkan tempat berhenti atau melanjutkan bacaan agar makna tetap terjaga.',
    note: 'Penandaan dapat sedikit berbeda menurut edisi Mushaf dan tradisi qiraat.',
    teacherNote: 'Untuk koreksi bacaan secara praktik, belajarlah dengan guru yang berkualifikasi.',
    explanations: [
      'Berhentilah di sini agar sambungan bacaan tidak menimbulkan makna yang tidak dimaksudkan.',
      'Lanjutkan bacaan; berhenti di sini dapat memutus makna tata bahasa yang dimaksudkan.',
      'Anda boleh berhenti atau melanjutkan.',
      'Berhenti lebih diutamakan, tetapi melanjutkan tetap diperbolehkan.',
      'Melanjutkan lebih diutamakan, tetapi berhenti tetap diperbolehkan.',
      'Saat tanda berpasangan muncul, berhentilah pada salah satu posisi saja, bukan keduanya.',
    ],
  ),
  AppLanguage.urdu: WaqfMarksContent(
    title: 'علاماتِ وقف',
    intro: 'یہ علامات بتاتی ہیں کہ معنی کی حفاظت کے لیے تلاوت میں کہاں رکنا یا جاری رکھنا ہے۔',
    note:
        'مصحف کے ایڈیشن اور روایت کے لحاظ سے نشانات میں معمولی فرق ہو سکتا ہے۔',
    teacherNote: 'عملی تصحیحِ تلاوت کے لیے کسی مستند استاد سے سیکھیں۔',
    explanations: [
      'یہاں رکیں تاکہ ایسا وصل نہ ہو جس سے غیر مراد معنی کا احتمال پیدا ہو۔',
      'تلاوت جاری رکھیں؛ یہاں رکنے سے مطلوبہ نحوی معنی منقطع ہو سکتا ہے۔',
      'رکنا اور وصل کرنا، دونوں جائز ہیں۔',
      'رکنا اولیٰ ہے، البتہ وصل بھی جائز ہے۔',
      'وصل اولیٰ ہے، البتہ رکنا بھی جائز ہے۔',
      'جب دو مقابل علامات ہوں تو صرف ایک جگہ رکیں، دونوں جگہ نہیں۔',
    ],
  ),
  AppLanguage.russian: WaqfMarksContent(
    title: 'Знаки остановки',
    intro: 'Эти знаки подсказывают, где остановиться или продолжить чтение, чтобы сохранить смысл.',
    note: 'Обозначения могут немного различаться в зависимости от издания Мусхафа и традиции чтения.',
    teacherNote: 'Для практической коррекции чтения обучайтесь у квалифицированного преподавателя.',
    explanations: [
      'Остановитесь здесь, чтобы не соединить слова так, что возникнет непредусмотренный смысл.',
      'Продолжайте чтение; остановка здесь может нарушить предполагаемый грамматический смысл.',
      'Можно остановиться или продолжить.',
      'Остановка предпочтительна, хотя продолжение разрешено.',
      'Продолжение предпочтительно, хотя остановка разрешена.',
      'При парных знаках остановитесь только в одном месте, а не в обоих.',
    ],
  ),
  AppLanguage.german: WaqfMarksContent(
    title: 'Pausenzeichen',
    intro: 'Diese Zeichen zeigen, wo man anhalten oder weiterlesen soll, damit der Sinn erhalten bleibt.',
    note: 'Die Notation kann je nach Mushaf-Ausgabe und Rezitationstradition leicht variieren.',
    teacherNote: 'Für praktische Korrekturen der Rezitation lernen Sie mit einer qualifizierten Lehrkraft.',
    explanations: [
      'Halten Sie hier an, damit keine Verbindung entsteht, die eine unbeabsichtigte Bedeutung nahelegt.',
      'Lesen Sie weiter; ein Halt kann hier die beabsichtigte grammatische Bedeutung unterbrechen.',
      'Sie dürfen anhalten oder weiterlesen.',
      'Anhalten ist vorzuziehen, Weiterlesen bleibt jedoch erlaubt.',
      'Weiterlesen ist vorzuziehen, Anhalten bleibt jedoch erlaubt.',
      'Bei gepaarten Zeichen halten Sie nur an einer Stelle an, nicht an beiden.',
    ],
  ),
  AppLanguage.japanese: WaqfMarksContent(
    title: '停止記号',
    intro: 'これらの記号は、意味を保つために朗誦で止める場所と続ける場所を示します。',
    note: '記号はムスハフの版や読誦伝統によってわずかに異なる場合があります。',
    teacherNote: '実際の朗誦の修正は、資格のある教師から学ぶことをおすすめします。',
    explanations: [
      '意図しない意味につながらないよう、ここで止めます。',
      '朗誦を続けます。ここで止めると、本来の文法的な意味が途切れることがあります。',
      '止めても、続けてもかまいません。',
      '止める方が望ましいですが、続けることも認められます。',
      '続ける方が望ましいですが、止めることも認められます。',
      '対になった記号では、両方ではなく一方だけで止めます。',
    ],
  ),
  AppLanguage.nigerianPidgin: WaqfMarksContent(
    title: 'Waqf Marks',
    intro: 'These signs show where you fit pause or continue so the meaning go remain correct for recitation.',
    note: 'The signs fit differ small depending on the Mushaf edition and recitation tradition.',
    teacherNote:
        'For practical recitation correction, learn with qualified teacher.',
    explanations: [
      'Stop here so you no join the words in a way wey fit bring another meaning.',
      'Continue to read; if you stop here, e fit break the grammar meaning wey dey intended.',
      'You fit stop or continue.',
      'To stop better, but to continue still allowed.',
      'To continue better, but to stop still allowed.',
      'When the paired marks show, stop for only one place, no stop for both.',
    ],
  ),
};

WaqfMarksContent waqfMarksContentFor(AppLanguage language) {
  return _content[language] ?? _content[AppLanguage.english]!;
}

const _englishMarkReferenceDetails = <WaqfMarkReferenceDetail>[
  WaqfMarkReferenceDetail(
    beforeExample:
        'م means that stopping is required. Allah, the Exalted, says:',
    afterExample: 'Here, the reader should stop at “يَسْمَعُونَ”.',
  ),
  WaqfMarkReferenceDetail(
    beforeExample: 'لا means that stopping is prohibited, or that one should not stop. Allah, the Exalted, says:',
    afterExample: 'Here, the reader should not stop at “طَيِّبِينَ”.',
  ),
  WaqfMarkReferenceDetail(
    beforeExample: 'ج means that the reader may either stop or continue. Allah, the Exalted, says:',
    afterExample:
        'Here, the reader may stop at “بِٱلْحَقِّ” or continue reading.',
  ),
  WaqfMarkReferenceDetail(
    beforeExample: 'قلى, or قلي, means that continuing is allowed, but stopping is better and more appropriate. Allah, the Exalted, says:',
    afterExample: 'Here, the reader may continue after “قَلِيلٌ”, although stopping there is preferable.',
  ),
  WaqfMarkReferenceDetail(
    beforeExample: 'صلى, or صلي, means that stopping is allowed, but continuing is better and more appropriate. Allah, the Exalted, says:',
    afterExample: 'Here, the reader may stop after “لَهُۥ”, although continuing is preferable.',
  ),
  WaqfMarkReferenceDetail(
    beforeExample: 'The paired three-dot marks are called the embracing-stop sign. If the reader stops at one of them, the other should be joined rather than stopped at. Allah, the Exalted, says:',
    afterExample: 'Here, if the reader stops at “رَيْبَ”, the reader should not also stop at “فِيهِ”, and vice versa.',
  ),
];

const _englishReferenceSections = <WaqfReferenceSection>[
  WaqfReferenceSection(
    title: 'Waqf Marks in the Noble Mushaf',
    paragraphs: [
      'Readers use Waqf marks to divide the verses and to choose a suitable pause that completes the meaning. Early copies of the Mushaf did not contain these marks. Scholars later introduced stop marks and symbols with particular meanings. There are six marks in this lesson, and a reader may find some variation according to the recitation tradition used in a printed Mushaf.',
    ],
  ),
  WaqfReferenceSection(
    title: 'Waqf in the Noble Quran',
    paragraphs: [
      'Definition and ruling of Waqf',
      'Linguistically, Waqf means holding back or stopping. In Tajwid, it means stopping the voice at the end of a word long enough to breathe, with the intention to resume recitation. It does not occur in the middle of a word. It is generally permitted unless it changes the intended meaning. Its duration is commonly estimated at two counts. It may occur at the end or within a verse, but never inside a written word, such as the word “إنما”.',
    ],
  ),
  WaqfReferenceSection(
    title: 'Types of Waqf',
    paragraphs: [
      'Testing stop: the reader stops on a word that is not normally suitable for stopping. A teacher may use it to test a student’s knowledge of joining, separating, keeping, or omitting letters and other rules. It is permitted only in a setting of testing or teaching.',
      'Waiting stop: the reader stops on a Qur’anic word that has more than one valid reading so that the alternatives can be presented. It is called a waiting stop because the teacher waits for the student to show all related readings or narrations. It is permitted even when the meaning is not yet complete.',
      'Necessary stop: the reader stops on a word that is not a normal stopping point because of a necessity such as shortness of breath or coughing. It is permitted until the necessity ends, provided the reader returns to the word where the pause occurred and connects it to what follows if beginning there is suitable; otherwise, the reader returns to an earlier point.',
      'Voluntary stop: the reader stops on a Qur’anic word by choice. It requires stopping on speech whose meaning is complete. It is permitted unless it changes the meaning or suggests an unintended meaning. This stop is made intentionally, without an external necessity.',
    ],
  ),
  WaqfReferenceSection(
    title: 'Importance of Waqf',
    paragraphs: ['Waqf has several benefits, including:'],
    bullets: [
      'Understanding Qur’anic meanings while reciting, drawing legal evidence, and recognizing what is lawful, unlawful, commanded, and prohibited.',
      'Knowing the indications and degrees of pauses, which reflects the reader’s understanding of the Quran.',
    ],
  ),
];

const _localizedReferenceSections = <AppLanguage, List<WaqfReferenceSection>>{
  AppLanguage.chinese: [
    WaqfReferenceSection(
      title: '尊贵穆斯哈夫中的停顿标记',
      paragraphs: [
        '诵读者借助停顿标记划分经文，并选择合适的停顿以完整表达含义。早期的穆斯哈夫没有这些标记，后来学者以具有特定含义的符号加以标示。不同诵读传统和版本中的标记可能略有差异。',
      ],
    ),
    WaqfReferenceSection(
      title: '古兰经中的停顿',
      paragraphs: [
        '停顿的定义与规则',
        '从语言上说，Waqf 意为停住或停止；在泰吉威德中，它是在词尾停声以便呼吸，并准备继续诵读。通常可以停顿，除非停顿会改变原意；不得在一个词的中间停顿。',
      ],
    ),
    WaqfReferenceSection(
      title: '停顿的类型',
      paragraphs: [
        '考查性停顿用于教学或考查；等待性停顿用于展示同一词的不同诵读方式；必要性停顿是因呼吸急促、咳嗽等需要而停；自愿性停顿是读者主动选择的停顿，应在含义完整处进行，且不得改变原意。',
      ],
    ),
    WaqfReferenceSection(
      title: '停顿的重要性',
      paragraphs: ['正确的停顿有助于理解古兰经的意义、分辨命令和禁令，并显示读者对诵读含义及停顿层次的理解。'],
    ),
  ],
  AppLanguage.hindi: [
    WaqfReferenceSection(
      title: 'पवित्र मुस्हफ़ में वक़्फ़ के चिह्न',
      paragraphs: [
        'क़ारी आयतों को समझदारी से बाँटने और अर्थ पूरा करने वाले स्थान पर रुकने के लिए वक़्फ़ चिह्नों का उपयोग करता है। शुरुआती मुस्हफ़ में ये चिह्न नहीं थे; बाद में विद्वानों ने विशेष अर्थ वाले संकेत जोड़े। रिवायत और मुद्रित संस्करण के अनुसार इनमें हल्का अंतर हो सकता है।',
      ],
    ),
    WaqfReferenceSection(
      title: 'क़ुरआन में वक़्फ़',
      paragraphs: [
        'वक़्फ़ की परिभाषा और हुक्म',
        'भाषा में वक़्फ़ का अर्थ रोकना है। तज्वीद में यह शब्द के अंत पर आवाज़ रोकना है ताकि क़ारी साँस लेकर तिलावत जारी कर सके। यह सामान्यतः जायज़ है जब तक अर्थ न बदले; शब्द के बीच में नहीं रुकना चाहिए।',
      ],
    ),
    WaqfReferenceSection(
      title: 'वक़्फ़ के प्रकार',
      paragraphs: [
        'परीक्षा वक़्फ़ शिक्षा या जाँच के लिए होता है; इंतिज़ारी वक़्फ़ एक शब्द की अलग क़िराअतों को दिखाने के लिए होता है; इज़्तिरारी वक़्फ़ साँस या खाँसी जैसी मजबूरी में होता है; इख़्तियारी वक़्फ़ अपनी इच्छा से पूर्ण अर्थ पर किया जाता है और अर्थ नहीं बदलना चाहिए।',
      ],
    ),
    WaqfReferenceSection(
      title: 'वक़्फ़ का महत्व',
      paragraphs: [
        'सही वक़्फ़ क़ुरआनी अर्थ को समझने, आदेश और निषेध को पहचानने तथा क़ारी की समझ को बेहतर बनाने में सहायता करता है।',
      ],
    ),
  ],
  AppLanguage.spanish: [
    WaqfReferenceSection(
      title: 'Marcas de Waqf en el Noble Mushaf',
      paragraphs: [
        'El lector usa las marcas de Waqf para dividir los versículos y escoger una pausa que complete el sentido. Los primeros ejemplares del Mushaf no incluían estas marcas; posteriormente los eruditos añadieron símbolos con significados concretos. Puede haber pequeñas variaciones según la tradición de recitación y la edición impresa.',
      ],
    ),
    WaqfReferenceSection(
      title: 'El Waqf en el Noble Corán',
      paragraphs: [
        'Definición y norma del Waqf',
        'En el idioma, Waqf significa detenerse. En tajwid es interrumpir la voz al final de una palabra para respirar con intención de reanudar la recitación. Por regla general está permitido salvo que cambie el sentido, y no se realiza en medio de una palabra.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Tipos de Waqf',
      paragraphs: [
        'La pausa de prueba se usa para enseñar o evaluar; la pausa de espera permite mostrar distintas lecturas de una palabra; la pausa necesaria ocurre por falta de aire, tos u otra necesidad; y la pausa voluntaria se hace por elección en un sentido completo, sin alterar el significado.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Importancia del Waqf',
      paragraphs: [
        'Una pausa correcta ayuda a comprender los significados coránicos, reconocer mandatos y prohibiciones, y demuestra comprensión de los grados de pausa en la recitación.',
      ],
    ),
  ],
  AppLanguage.french: [
    WaqfReferenceSection(
      title: 'Signes de Waqf dans le Noble Mushaf',
      paragraphs: [
        'Le lecteur utilise les signes de Waqf pour diviser les versets et choisir une pause qui achève le sens. Les premiers exemplaires du Mushaf ne portaient pas ces signes ; les savants ont ensuite ajouté des symboles aux sens précis. Ils peuvent varier légèrement selon la tradition de récitation et l’édition imprimée.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Le Waqf dans le Noble Coran',
      paragraphs: [
        'Définition et règle du Waqf',
        'Dans la langue, Waqf signifie s’arrêter. En tajwid, il consiste à interrompre la voix à la fin d’un mot pour respirer avec l’intention de reprendre la récitation. Il est en principe permis sauf s’il modifie le sens, et il ne se fait pas au milieu d’un mot.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Types de Waqf',
      paragraphs: [
        'L’arrêt d’évaluation sert à l’enseignement ou à l’examen ; l’arrêt d’attente sert à présenter plusieurs lectures d’un mot ; l’arrêt nécessaire survient par manque de souffle, toux ou autre nécessité ; et l’arrêt volontaire est choisi à un sens complet sans modifier le sens.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Importance du Waqf',
      paragraphs: [
        'Une pause correcte aide à comprendre les sens coraniques, à reconnaître les ordres et interdictions, et reflète la compréhension du lecteur des degrés de pause.',
      ],
    ),
  ],
  AppLanguage.bengali: [
    WaqfReferenceSection(
      title: 'পবিত্র মুসহাফে ওয়াকফের চিহ্ন',
      paragraphs: [
        'পাঠক আয়াত ভাগ করা এবং অর্থ সম্পূর্ণ হয় এমন স্থানে থামার জন্য ওয়াকফের চিহ্ন ব্যবহার করেন। প্রাথমিক মুসহাফে এসব চিহ্ন ছিল না; পরে আলেমরা নির্দিষ্ট অর্থবোধক প্রতীক যোগ করেন। কিরাআত ও মুদ্রিত সংস্করণভেদে সামান্য পার্থক্য থাকতে পারে।',
      ],
    ),
    WaqfReferenceSection(
      title: 'পবিত্র কুরআনে ওয়াকফ',
      paragraphs: [
        'ওয়াকফের সংজ্ঞা ও বিধান',
        'ভাষায় ওয়াকফ অর্থ থামা। তাজবীদে এটি শব্দের শেষে আওয়াজ থামিয়ে শ্বাস নেওয়া এবং আবার তিলাওয়াত শুরু করার ইচ্ছা করা। অর্থ পরিবর্তিত না হলে এটি সাধারণত বৈধ; শব্দের মাঝখানে থামা যায় না।',
      ],
    ),
    WaqfReferenceSection(
      title: 'ওয়াকফের প্রকার',
      paragraphs: [
        'পরীক্ষামূলক ওয়াকফ শিক্ষা বা যাচাইয়ের জন্য; অপেক্ষামূলক ওয়াকফ একই শব্দের ভিন্ন কিরাআত দেখানোর জন্য; জরুরি ওয়াকফ শ্বাসকষ্ট, কাশি বা প্রয়োজনে; আর ঐচ্ছিক ওয়াকফ পূর্ণ অর্থে নিজের ইচ্ছায় করা হয় এবং অর্থ বদলানো যাবে না।',
      ],
    ),
    WaqfReferenceSection(
      title: 'ওয়াকফের গুরুত্ব',
      paragraphs: [
        'সঠিক ওয়াকফ কুরআনের অর্থ বুঝতে, আদেশ-নিষেধ চিনতে এবং পাঠকের তিলাওয়াত-বোধ প্রকাশ করতে সাহায্য করে।',
      ],
    ),
  ],
  AppLanguage.portuguese: [
    WaqfReferenceSection(
      title: 'Marcas de Waqf no Nobre Mushaf',
      paragraphs: [
        'O leitor usa as marcas de Waqf para dividir os versículos e escolher uma pausa que complete o sentido. As primeiras cópias do Mushaf não possuíam essas marcas; mais tarde, os estudiosos acrescentaram símbolos com significados específicos. Pode haver pequenas variações conforme a tradição de recitação e a edição impressa.',
      ],
    ),
    WaqfReferenceSection(
      title: 'O Waqf no Nobre Alcorão',
      paragraphs: [
        'Definição e regra do Waqf',
        'Na língua, Waqf significa parar. No tajwid, é interromper a voz no fim de uma palavra para respirar com a intenção de retomar a recitação. Em geral é permitido, salvo se mudar o sentido, e não deve ocorrer no meio de uma palavra.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Tipos de Waqf',
      paragraphs: [
        'A pausa de teste serve ao ensino ou à avaliação; a pausa de espera mostra leituras diferentes de uma palavra; a pausa necessária ocorre por falta de ar, tosse ou outra necessidade; e a pausa voluntária é escolhida num sentido completo, sem mudar o significado.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Importância do Waqf',
      paragraphs: [
        'Uma pausa correta ajuda a compreender os significados corânicos, reconhecer ordens e proibições e demonstra o entendimento do leitor sobre os graus de pausa.',
      ],
    ),
  ],
  AppLanguage.indonesian: [
    WaqfReferenceSection(
      title: 'Tanda Waqaf dalam Mushaf Mulia',
      paragraphs: [
        'Pembaca menggunakan tanda Waqaf untuk membagi ayat dan memilih tempat berhenti yang menyempurnakan makna. Mushaf pada masa awal belum memuat tanda ini; para ulama kemudian menambahkan lambang dengan makna tertentu. Terdapat sedikit perbedaan menurut riwayat qiraat dan edisi cetak.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Waqaf dalam Al-Qur’an',
      paragraphs: [
        'Definisi dan hukum Waqaf',
        'Secara bahasa, Waqaf berarti berhenti. Dalam tajwid, Waqaf ialah menghentikan suara pada akhir kata untuk bernapas dengan niat melanjutkan bacaan. Pada umumnya dibolehkan selama tidak mengubah makna, dan tidak dilakukan di tengah kata.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Jenis Waqaf',
      paragraphs: [
        'Waqaf ikhtibari digunakan untuk pengajaran atau pengujian; waqaf intizari untuk menunjukkan beberapa cara baca sebuah kata; waqaf idtirari terjadi karena sesak napas, batuk, atau kebutuhan lain; dan waqaf ikhtiyari dilakukan atas pilihan sendiri pada makna yang sempurna tanpa mengubah makna.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Pentingnya Waqaf',
      paragraphs: [
        'Waqaf yang benar membantu memahami makna Al-Qur’an, mengenali perintah dan larangan, serta menunjukkan pemahaman pembaca terhadap tingkat-tingkat berhenti.',
      ],
    ),
  ],
  AppLanguage.urdu: [
    WaqfReferenceSection(
      title: 'مصحفِ شریف میں علاماتِ وقف',
      paragraphs: [
        'قاری آیات کی مناسب تقسیم اور معنی کو مکمل کرنے والی جگہ کے انتخاب کے لیے علاماتِ وقف استعمال کرتا ہے۔ ابتدائی مصاحف میں یہ علامات موجود نہ تھیں؛ بعد میں علما نے مخصوص مفہوم والے رموز شامل کیے۔ روایت اور مطبوعہ مصحف کے لحاظ سے معمولی فرق ہو سکتا ہے۔',
      ],
    ),
    WaqfReferenceSection(
      title: 'قرآنِ کریم میں وقف',
      paragraphs: [
        'وقف کی تعریف اور حکم',
        'لغت میں وقف کے معنی رکنا ہیں۔ تجوید میں کلمے کے آخر پر آواز روکنا، سانس لینا اور تلاوت دوبارہ شروع کرنے کی نیت کرنا وقف کہلاتا ہے۔ یہ عموماً جائز ہے جب تک معنی نہ بدلے، اور کلمے کے درمیان وقف نہیں کیا جاتا۔',
      ],
    ),
    WaqfReferenceSection(
      title: 'وقف کی اقسام',
      paragraphs: [
        'وقفِ اختباری تعلیم یا امتحان کے لیے ہے؛ وقفِ انتظاری ایک لفظ کی متعدد قراءتیں دکھانے کے لیے ہے؛ وقفِ اضطراری سانس کی تنگی، کھانسی یا دوسری مجبوری میں ہوتا ہے؛ اور وقفِ اختیاری مکمل معنی پر اپنی مرضی سے کیا جاتا ہے، بشرطیکہ معنی نہ بدلے۔',
      ],
    ),
    WaqfReferenceSection(
      title: 'وقف کی اہمیت',
      paragraphs: [
        'صحیح وقف قرآنی معانی سمجھنے، اوامر و نواہی پہچاننے اور قاری کی فہمِ تلاوت کو نمایاں کرنے میں مدد دیتا ہے۔',
      ],
    ),
  ],
  AppLanguage.russian: [
    WaqfReferenceSection(
      title: 'Знаки вакфа в Благородном Мусхафе',
      paragraphs: [
        'Чтец использует знаки вакфа, чтобы делить аяты и выбирать паузу, завершающую смысл. В ранних экземплярах Мусхафа таких знаков не было; позднее ученые добавили символы с определенными значениями. Возможны небольшие различия в зависимости от традиции чтения и печатного издания.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Вакф в Священном Коране',
      paragraphs: [
        'Определение и правило вакфа',
        'В языке вакф означает остановку. В таджвиде это остановка голоса в конце слова для вдоха с намерением продолжить чтение. Обычно она допустима, если не меняет смысл, и не делается внутри слова.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Виды вакфа',
      paragraphs: [
        'Проверочная остановка используется при обучении или проверке; выжидательная — для показа разных вариантов чтения слова; вынужденная — из-за нехватки воздуха, кашля или иной необходимости; добровольная — по выбору чтеца на завершенном смысле без изменения значения.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Значение вакфа',
      paragraphs: [
        'Правильная пауза помогает понимать смыслы Корана, различать веления и запреты и показывает понимание чтецом степеней остановки.',
      ],
    ),
  ],
  AppLanguage.german: [
    WaqfReferenceSection(
      title: 'Waqf-Zeichen im edlen Mushaf',
      paragraphs: [
        'Lesende verwenden Waqf-Zeichen, um die Verse zu gliedern und eine Pause zu wählen, die den Sinn vervollständigt. Frühe Ausgaben des Mushaf enthielten diese Zeichen nicht; später fügten Gelehrte Symbole mit bestimmten Bedeutungen hinzu. Je nach Lesetradition und Druckausgabe sind leichte Unterschiede möglich.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Waqf im edlen Koran',
      paragraphs: [
        'Definition und Regel des Waqf',
        'Sprachlich bedeutet Waqf anhalten. Im Tadschwid ist es das Anhalten der Stimme am Wortende zum Atmen mit der Absicht, die Rezitation fortzusetzen. Es ist grundsätzlich erlaubt, solange der Sinn nicht verändert wird, und erfolgt nicht innerhalb eines Wortes.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Arten des Waqf',
      paragraphs: [
        'Der Prüfungsstopp dient Unterricht oder Prüfung; der Wartestopp zeigt mehrere Lesarten eines Wortes; der notwendige Stopp geschieht wegen Atemnot, Husten oder einer anderen Notwendigkeit; der freiwillige Stopp wird bewusst bei abgeschlossenem Sinn gewählt und darf die Bedeutung nicht verändern.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Bedeutung des Waqf',
      paragraphs: [
        'Eine richtige Pause hilft, koranische Bedeutungen zu verstehen, Gebote und Verbote zu erkennen und zeigt das Verständnis der Lesenden für die Pausenstufen.',
      ],
    ),
  ],
  AppLanguage.japanese: [
    WaqfReferenceSection(
      title: '高貴なムスハフのワクフ記号',
      paragraphs: [
        '朗誦者は、節を区切り意味を完結させる適切な位置を選ぶためにワクフ記号を用います。初期のムスハフにはこれらの記号はなく、後に学者たちが特定の意味を持つ記号を加えました。読誦伝統や印刷版によってわずかな違いがあります。',
      ],
    ),
    WaqfReferenceSection(
      title: '聖クルアーンにおけるワクフ',
      paragraphs: [
        'ワクフの定義と規則',
        '言語上、ワクフは止まることを意味します。タジュウィードでは、朗誦を再開する意図で息を吸うために語末で声を止めることです。意味を変えない限り通常は許され、語の途中で止めることはありません。',
      ],
    ),
    WaqfReferenceSection(
      title: 'ワクフの種類',
      paragraphs: [
        '試験の停止は教育や確認のため、待機の停止は一語の異なる読誦を示すため、必要による停止は息切れ・咳などのため、自発的な停止は意味が完結した所で意図的に行われ、意味を変えてはなりません。',
      ],
    ),
    WaqfReferenceSection(
      title: 'ワクフの重要性',
      paragraphs: ['正しい停止はクルアーンの意味を理解し、命令と禁止を見分け、朗誦者の停止段階への理解を示す助けになります。'],
    ),
  ],
  AppLanguage.nigerianPidgin: [
    WaqfReferenceSection(
      title: 'Waqf Marks for Noble Mushaf',
      paragraphs: [
        'Person wey dey recite fit use Waqf marks take divide verses and choose where pause go complete meaning. Early Mushaf no get these marks; scholars later add symbols wey get special meanings. Small differences fit dey based on recitation tradition and printed edition.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Waqf for Noble Quran',
      paragraphs: [
        'Wetin Waqf mean and e rule',
        'For language, Waqf mean stop. For Tajwid, na to stop voice for end of word make person breathe with mind to continue recitation. E dey allowed unless e go change meaning, and person no suppose stop for middle of word.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Kinds of Waqf',
      paragraphs: [
        'Test stop na for teaching or checking; waiting stop na to show different ways to read one word; necessary stop fit happen because breath short, cough, or another need; voluntary stop na when reader choose stop for complete meaning without changing the meaning.',
      ],
    ),
    WaqfReferenceSection(
      title: 'Why Waqf matter',
      paragraphs: [
        'Correct pause dey help person understand Quran meanings, know commands and prohibitions, and show say reader understand levels of stopping.',
      ],
    ),
  ],
};

const _localizedExampleLabels = <AppLanguage, String>{
  AppLanguage.chinese: '古兰经示例：',
  AppLanguage.hindi: 'क़ुरआनी उदाहरण:',
  AppLanguage.spanish: 'Ejemplo coránico:',
  AppLanguage.french: 'Exemple coranique :',
  AppLanguage.bengali: 'কুরআনি উদাহরণ:',
  AppLanguage.portuguese: 'Exemplo corânico:',
  AppLanguage.indonesian: 'Contoh Al-Qur’an:',
  AppLanguage.urdu: 'قرآنی مثال:',
  AppLanguage.russian: 'Коранический пример:',
  AppLanguage.german: 'Koranisches Beispiel:',
  AppLanguage.japanese: 'クルアーンの例：',
  AppLanguage.nigerianPidgin: 'Quran example:',
};

List<WaqfMarkReferenceDetail> waqfMarkReferenceDetailsFor(
  AppLanguage language,
) {
  if (language == AppLanguage.english) return _englishMarkReferenceDetails;
  if (language == AppLanguage.arabic) {
    return List<WaqfMarkReferenceDetail>.unmodifiable(
      waqfMarkDefinitions.map(
        (definition) => WaqfMarkReferenceDetail(
          beforeExample: definition.referenceBeforeExample,
          afterExample: definition.referenceAfterExample,
        ),
      ),
    );
  }
  final content = waqfMarksContentFor(language);
  final label = _localizedExampleLabels[language]!;
  return List<WaqfMarkReferenceDetail>.generate(
    waqfMarkDefinitions.length,
    (index) => WaqfMarkReferenceDetail(
      beforeExample: label,
      afterExample: content.explanations[index],
    ),
    growable: false,
  );
}

List<WaqfReferenceSection> waqfReferenceSectionsFor(AppLanguage language) {
  if (language == AppLanguage.arabic) return waqfReferenceSections;
  if (language == AppLanguage.english) return _englishReferenceSections;
  return _localizedReferenceSections[language]!;
}
