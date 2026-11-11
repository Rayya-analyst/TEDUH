enum DisabilityType {
  none,
  blind,
  lowVision,
  deaf,
  speech,
  motor,
  cognitive,
  multiple;

  String get key => name;

  static DisabilityType fromKey(String? k) {
    for (final t in DisabilityType.values) {
      if (t.name == k) return t;
    }
    return DisabilityType.none;
  }

  String get label {
    switch (this) {
      case DisabilityType.none:
        return 'Tidak ada';
      case DisabilityType.blind:
        return 'Tunanetra (tidak bisa melihat)';
      case DisabilityType.lowVision:
        return 'Low vision (sulit melihat)';
      case DisabilityType.deaf:
        return 'Tunarungu (sulit mendengar)';
      case DisabilityType.speech:
        return 'Tunawicara (sulit berbicara)';
      case DisabilityType.motor:
        return 'Tunadaksa (sulit menggerakkan tangan)';
      case DisabilityType.cognitive:
        return 'Intelektual / sulit memahami';
      case DisabilityType.multiple:
        return 'Lebih dari satu';
    }
  }

  String get shortLabel {
    switch (this) {
      case DisabilityType.none:
        return 'Tidak ada';
      case DisabilityType.blind:
        return 'Tunanetra';
      case DisabilityType.lowVision:
        return 'Low vision';
      case DisabilityType.deaf:
        return 'Tunarungu';
      case DisabilityType.speech:
        return 'Tunawicara';
      case DisabilityType.motor:
        return 'Tunadaksa';
      case DisabilityType.cognitive:
        return 'Intelektual';
      case DisabilityType.multiple:
        return 'Ganda';
    }
  }

  String get adaptation {
    switch (this) {
      case DisabilityType.none:
        return '';
      case DisabilityType.blind:
        return 'Seluruh halaman dijelaskan dengan suara, tanpa panduan visual. '
            'Kamu cukup berbicara, tidak perlu menyentuh layar.';
      case DisabilityType.lowVision:
        return 'Teks dibuat sangat besar dan tebal, kontras tinggi, dan '
            'panduan dibacakan sambil disorot. Kamu juga bisa memberi '
            'perintah dengan suara.';
      case DisabilityType.deaf:
        return 'Semua informasi ditampilkan sebagai teks, dan peringatan '
            'udara berbahaya memakai getar dan layar berkedip. Tidak ada '
            'suara yang wajib kamu dengar.';
      case DisabilityType.speech:
        return 'Kamu tidak perlu berbicara. Semua bisa dilakukan dengan '
            'sentuhan, ketikan, dan pilihan cepat.';
      case DisabilityType.motor:
        return 'Kamu bisa mengendalikan TEDUH dengan suara tanpa menyentuh '
            'layar, dan tombol dibuat lebih besar.';
      case DisabilityType.cognitive:
        return 'Bahasa dibuat sederhana, langkah panduan dibacakan pelan satu '
            'per satu, dan gerakan layar dikurangi.';
      case DisabilityType.multiple:
        return 'Semua dukungan diaktifkan: suara, teks besar, bahasa '
            'sederhana, dan panduan visual yang ikut dibacakan.';
    }
  }

  bool get usesSpeech =>
      this == blind || this == lowVision || this == cognitive || this == multiple;

  bool get usesMic =>
      this == blind || this == lowVision || this == motor || this == multiple;

  bool get usesVisualTour => this != blind;

  bool get narratesPages => this == blind;

  bool get needsVisualAlerts => this == deaf || this == multiple;

  bool get simpleLanguage =>
      this == blind || this == cognitive || this == multiple;


  static DisabilityType? parse(String raw) {
    final t = ' ${raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')} ';
    bool any(List<String> k) => k.any((e) => t.contains(e));

    if (any(['ganda', 'lebih dari satu', 'semuanya', 'beberapa', 'campuran'])) {
      return DisabilityType.multiple;
    }
    if (any([
      'low vision', 'lowvision', 'kurang awas', 'rabun', 'buram', 'kabur',
      'sulit melihat', 'susah melihat', 'kurang jelas', 'penglihatan terbatas',
      'penglihatan kurang', 'mata minus', 'katarak',
    ])) {
      return DisabilityType.lowVision;
    }
    if (any([
      'buta', 'tunanetra', 'tuna netra', 'netra', 'tidak bisa melihat',
      'tidak dapat melihat', 'tak bisa melihat', 'tidak melihat',
    ])) {
      return DisabilityType.blind;
    }
    if (any([
      'wicara', 'bisu', 'tidak bisa bicara', 'tidak bisa berbicara',
      'sulit bicara', 'susah bicara', 'sulit berbicara', 'gagu',
    ])) {
      return DisabilityType.speech;
    }
    if (any([
      'tuli', 'rungu', 'tunarungu', 'tuna rungu', 'tidak bisa mendengar',
      'sulit mendengar', 'susah mendengar', 'kurang dengar', 'pendengaran',
      'budek',
    ])) {
      return DisabilityType.deaf;
    }
    if (any([
      'daksa', 'tunadaksa', 'tuna daksa', 'lumpuh', 'kursi roda', 'amputasi',
      'tangan', 'jari', 'tremor', 'gemetar', 'fisik', 'stroke', 'cerebral',
      'sulit menggerakkan', 'susah menggerakkan', 'tidak bisa menyentuh',
    ])) {
      return DisabilityType.motor;
    }
    if (any([
      'intelektual', 'tunagrahita', 'tuna grahita', 'autis', 'autisme',
      'disleksia', 'adhd', 'down syndrome', 'sulit memahami', 'susah memahami',
      'sulit membaca', 'susah membaca', 'kognitif', 'mental', 'mudah lupa',
      'sulit konsentrasi', 'sulit fokus', 'lambat belajar',
    ])) {
      return DisabilityType.cognitive;
    }
    return null;
  }
}
