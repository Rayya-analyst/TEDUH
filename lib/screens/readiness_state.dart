import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/teduh_common.dart';

class RC {
  static const green = Color(0xFF1B6F57);
  static const greenBright = Color(0xFF0F7B4F);
  static const dark = Color(0xFF1F3D2F);
  static const grey = Color(0xFF7C8A82);
  static const border = Color(0xFFE4ECE6);
  static const tile = Color(0xFFE6F2EA);
  static const bg = Color(0xFFF4F9F5);
}

String numberWord(int n) {
  const w = [
    'Nol', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima', 'Enam', 'Tujuh', 
    'Delapan', 'Sembilan', 'Sepuluh'
  ];
  return (n >= 0 && n < w.length) ? w[n] : '$n';
}

class PackItem {
  final String name;
  final String category;
  final bool custom;
  final bool hasDetail;
  bool checked;
  PackItem(this.name, this.category,
      {this.checked = false, this.custom = false, this.hasDetail = false});
}

class ReadyStep {
  final String title;
  final String subtitle;
  final IconData icon;
  bool done;
  ReadyStep(this.title, this.subtitle, this.icon, {this.done = false});
}

class EmergencyContact {
  final String name;
  final String phone;
  const EmergencyContact(this.name, this.phone);
}

const String kCatAir = 'Perlindungan Udara';
const String kCatMedis = 'Kesehatan Medis';
const String kCatCustom = 'Item Kustom';

class ReadinessState extends ChangeNotifier {
  ReadinessState._();
  static final ReadinessState instance = ReadinessState._();

  final List<PackItem> packItems = [
    PackItem('Masker N95 / KN95', kCatAir, checked: true, hasDetail: true),
    PackItem('Kacamata Pelindung / Goggles', kCatAir),
    PackItem('Obat Tetes Mata', kCatMedis, checked: true),
    PackItem('Inhaler / Obat Pernapasan', kCatMedis),
    PackItem('Air Minum', kCatMedis, checked: true),
  ];

  final List<ReadyStep> steps = [
    ReadyStep('Gunakan Masker', 'Masker bersih siap dibawa',
        Icons.masks_outlined,
        done: true),
    ReadyStep('Menyiapkan Air Minum', 'Jaga udara di rumah tetap bersih',
        Icons.home_outlined,
        done: true),
    ReadyStep('Siapkan Kebutuhan Kesehatan',
        'Obat pribadi & air minum tersedia', Icons.health_and_safety_outlined,
        done: true),
    ReadyStep('Cek Udara Sebelum Keluar', 'Lihat kondisi sebelum beraktivitas',
        Icons.air_rounded),
  ];

  final List<EmergencyContact> contacts = [];

  int get packDone => packItems.where((e) => e.checked).length;
  int get packTotal => packItems.length;
  double get packFraction => packTotal == 0 ? 0 : packDone / packTotal;
  int get packPercent => (packFraction * 100).round();

  int get stepsDone => steps.where((e) => e.done).length;
  int get stepsTotal => steps.length;
  double get stepsFraction => stepsTotal == 0 ? 0 : stepsDone / stepsTotal;
  int get stepsPercent => (stepsFraction * 100).round();

  int get overallPercent =>
      (((packFraction + stepsFraction) / 2) * 100).round();

  void togglePack(PackItem item) {
    item.checked = !item.checked;
    notifyListeners();
  }

  void addCustomItem(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    packItems.add(PackItem(n, kCatCustom, custom: true));
    notifyListeners();
  }

  void removePack(PackItem item) {
    packItems.remove(item);
    notifyListeners();
  }

  void toggleStep(ReadyStep s) {
    s.done = !s.done;
    notifyListeners();
  }

  void resetSteps() {
    for (final s in steps) {
      s.done = false;
    }
    notifyListeners();
  }

  static const String _kPrefs = 'ready_progress_v1';

  Future<bool> save() async {
    try {
      final p = await SharedPreferences.getInstance();
      final data = {
        'pack': {for (final e in packItems) e.name: e.checked},
        'custom': [
          for (final e in packItems.where((e) => e.custom)) e.name,
        ],
        'steps': {for (final e in steps) e.title: e.done},
      };
      return await p.setString(_kPrefs, jsonEncode(data));
    } catch (_) {
      return false;
    }
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kPrefs);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final name in (data['custom'] as List? ?? const [])) {
        if (!packItems.any((e) => e.name == name)) {
          packItems.add(PackItem(name as String, kCatCustom, custom: true));
        }
      }
      final pack = (data['pack'] as Map?) ?? const {};
      for (final e in packItems) {
        if (pack[e.name] is bool) e.checked = pack[e.name] as bool;
      }
      final st = (data['steps'] as Map?) ?? const {};
      for (final e in steps) {
        if (st[e.title] is bool) e.done = st[e.title] as bool;
      }
      notifyListeners();
    } catch (_) {}
  }

  void addContact(String name, String phone) {
    if (name.trim().isEmpty || phone.trim().isEmpty) return;
    contacts.add(EmergencyContact(name.trim(), phone.trim()));
    notifyListeners();
  }

  void removeContact(EmergencyContact c) {
    contacts.remove(c);
    notifyListeners();
  }
}

class ReadyButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const ReadyButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = RC.green,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 21, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadyCheck extends StatelessWidget {
  final bool checked;
  final Color fill;
  const ReadyCheck({super.key, required this.checked, this.fill = RC.green});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? fill : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked ? fill : const Color(0xFFC9D6CD),
          width: 1.4,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : null,
    );
  }
}

class ReadyScaffold extends StatefulWidget {
  final String title;
  final bool centerTitle;
  final bool leaves;
  final Widget? trailing;
  final Widget? bottom;
  final Color background;
  final Widget Function(BuildContext context, Animation<double> anim) builder;

  const ReadyScaffold({
    super.key,
    required this.title,
    required this.builder,
    this.centerTitle = false,
    this.leaves = true,
    this.trailing,
    this.bottom,
    this.background = const Color(0xFFF6FAF6),
  });

  @override
  State<ReadyScaffold> createState() => _ReadyScaffoldState();
}

class _ReadyScaffoldState extends State<ReadyScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      animationBehavior: AnimationBehavior.preserve,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _header() {
    final back = IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_rounded),
      color: RC.dark,
      iconSize: 26,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
    final style = GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: widget.centerTitle ? FontWeight.w700 : FontWeight.w500,
      color: RC.dark,
    );

    if (widget.centerTitle) {
      return SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: back),
            Text(widget.title, style: style),
            if (widget.trailing != null)
              Align(
                alignment: Alignment.centerRight,
                child: widget.trailing!,
              ),
          ],
        ),
      );
    }
    return Row(
      children: [
        back,
        const SizedBox(width: 18),
        Expanded(child: Text(widget.title, style: style)),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.background,
      body: Stack(
        children: [
          if (widget.leaves)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter:
                      SoftLeavesPainter(_anim, const Color(0xFFE3EFE4)),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Reveal(
                    animation: _anim,
                    begin: 0.0,
                    end: 0.3,
                    child: _header(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: widget.builder(context, _anim),
                  ),
                ),
                if (widget.bottom != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: widget.bottom!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
