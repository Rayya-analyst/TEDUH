import 'dart:math' as math;
import '../widgets/coach_marks.dart';
import '../widgets/voice_scope.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const bg = Color(0xFFF7FAF6);
  static const green = Color(0xFF0F7B4F);
  static const dark = Color(0xFF1F3D2F);
  static const hint = Color(0xFF7C9084);
  static const fieldBorder = Color(0xFFE2EAE4);
  static const fieldActiveBg = Color(0xFFEAF5EE);
  static const iconIdle = Color(0xFF8A9A90);
  static const softLeaf = Color(0xFFE2EFDF);
  static const error = Color(0xFFD64545);
}

class DataProfilePage extends StatefulWidget {
  const DataProfilePage({super.key});

  @override
  State<DataProfilePage> createState() => _DataProfilePageState();
}

class _DataProfilePageState extends State<DataProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  final _nameC = TextEditingController(text: 'Aronisa Sinarzka Dewiputri');
  final _usernameC = TextEditingController(text: 'Aronisa Sinarzka Dewiputri');
  final _emailC = TextEditingController(text: 'aronisa.sinarzka@gmail.com');
  final _phoneC = TextEditingController(text: '085847663653');

  final _nameF = FocusNode();
  final _usernameF = FocusNode();
  final _emailF = FocusNode();
  final _phoneF = FocusNode();

  final Map<String, String?> _errors = {};
  bool _saving = false;

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
    _nameC.dispose();
    _usernameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _nameF.dispose();
    _usernameF.dispose();
    _emailF.dispose();
    _phoneF.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String?>{};

    if (_nameC.text.trim().isEmpty) {
      errors['name'] = 'Nama lengkap wajib diisi';
    }
    if (_usernameC.text.trim().length < 3) {
      errors['username'] = 'Username minimal 3 karakter';
    }
    final email = _emailC.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = 'Format email tidak valid';
    }
    final phone = _phoneC.text.trim();
    if (phone.length < 9 || phone.length > 15) {
      errors['phone'] = 'Nomor telepon harus 9–15 digit';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving) return;
    if (!_validate()) return;

    setState(() => _saving = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _saving = false);
    _toast('Perubahan berhasil disimpan');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  void _changePhoto() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2DB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              _sheetTile(ctx, Icons.photo_camera_outlined, 'Ambil foto'),
              _sheetTile(ctx, Icons.photo_library_outlined, 'Pilih dari galeri'),
              _sheetTile(ctx, Icons.delete_outline_rounded, 'Hapus foto',
                  color: _C.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile(BuildContext ctx, IconData icon, String label,
      {Color color = _C.dark}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13.5, color: color),
      ),
      onTap: () {
        Navigator.pop(ctx);

        _toast('$label (segera hadir)');
      },
    );
  }

  List<CoachStep> get _tour => const [
        CoachStep(title: 'Foto profil', body: 'Ketuk Ubah foto profil untuk mengambil foto, memilih dari galeri, atau menghapus foto. Format JPG atau PNG, maksimal 5 megabita.'),
        CoachStep(title: 'Data dirimu', body: 'Isi nama lengkap, nama pengguna, email, dan nomor telepon. Kolom yang salah akan diberi pesan.'),
        CoachStep(title: 'Simpan perubahan', body: 'Pastikan data sudah benar, lalu ketuk Simpan. Datamu terlindungi dan hanya dipakai untuk layanan TEDUH.'),
      ];

  @override
  Widget build(BuildContext context) => VoiceScope(
        screen: 'data_profile',
        tour: _tour,
        guide: PageGuide(content: () => 'Ini halaman Data Profil. Berisi foto profil, nama lengkap, nama pengguna, email, dan nomor telepon, serta tombol Simpan. Ucapkan kembali untuk ke halaman sebelumnya.'),
        child: _buildBody(context),
      );

  Widget _buildBody(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final avatar = w * 0.30;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _SoftLeavesPainter(_anim)),
              ),
            ),
            SafeArea(
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _Reveal(
                      animation: _anim,
                      begin: 0.0,
                      end: 0.4,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: _C.dark,
                            iconSize: 26,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 18),
                          Text(
                            'Data Profil',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _C.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _Reveal(
                            animation: _anim,
                            begin: 0.1,
                            end: 0.55,
                            child: Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _changePhoto,
                                    child: SizedBox(
                                      width: avatar + 8,
                                      height: avatar + 8,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: avatar,
                                            height: avatar,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFF0F6F1),
                                              border: Border.all(
                                                  color: _C.green, width: 2.2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _C.green
                                                      .withValues(alpha: 0.14),
                                                  blurRadius: 24,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.person_outline_rounded,
                                              size: avatar * 0.5,
                                              color: const Color(0xFF86A895),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 4,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: _C.green,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.photo_camera_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: _changePhoto,
                                    child: Text(
                                      'Ubah foto profil',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _C.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'JPG atau PNG · Maks. 5 MB',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: _C.hint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          _Reveal(
                            animation: _anim,
                            begin: 0.25,
                            end: 0.65,
                            child: _InputField(
                              label: 'Nama Lengkap',
                              icon: Icons.person_outline_rounded,
                              controller: _nameC,
                              focusNode: _nameF,
                              error: _errors['name'],
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _usernameF.requestFocus(),
                              onChanged: (_) => _clearError('name'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Reveal(
                            animation: _anim,
                            begin: 0.35,
                            end: 0.75,
                            child: _InputField(
                              label: 'Username',
                              icon: Icons.alternate_email_rounded,
                              controller: _usernameC,
                              focusNode: _usernameF,
                              error: _errors['username'],
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _emailF.requestFocus(),
                              onChanged: (_) => _clearError('username'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Reveal(
                            animation: _anim,
                            begin: 0.45,
                            end: 0.85,
                            child: _InputField(
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              controller: _emailC,
                              focusNode: _emailF,
                              error: _errors['email'],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _phoneF.requestFocus(),
                              onChanged: (_) => _clearError('email'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Reveal(
                            animation: _anim,
                            begin: 0.55,
                            end: 0.95,
                            child: _InputField(
                              label: 'No. Telepon',
                              icon: Icons.phone_outlined,
                              controller: _phoneC,
                              focusNode: _phoneF,
                              error: _errors['phone'],
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              onSubmitted: (_) => _save(),
                              onChanged: (_) => _clearError('phone'),
                            ),
                          ),

                          const SizedBox(height: 18),

                          _Reveal(
                            animation: _anim,
                            begin: 0.65,
                            end: 1.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(Icons.verified_user_outlined,
                                      size: 14, color: _C.green),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Data pribadimu terlindungi dan hanya '
                                    'digunakan untuk layanan TEDUH.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      height: 1.5,
                                      color: _C.hint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: _Reveal(
                      animation: _anim,
                      begin: 0.7,
                      end: 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SaveButton(saving: _saving, onPressed: _save),
                          const SizedBox(height: 10),
                          Text(
                            'Pastikan data sudah benar sebelum menyimpan.',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _C.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearError(String key) {
    if (_errors[key] != null) {
      setState(() => _errors[key] = null);
    }
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.focusNode,
    this.error,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.formatters,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _C.dark,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, _) {
            final focused = focusNode.hasFocus;
            final hasError = error != null;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: focused ? _C.fieldActiveBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? _C.error
                      : (focused ? _C.green : _C.fieldBorder),
                  width: focused || hasError ? 1.2 : 1,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: _C.green.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: focused ? _C.green : _C.iconIdle,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      textCapitalization: textCapitalization,
                      inputFormatters: formatters,
                      onSubmitted: onSubmitted,
                      onChanged: onChanged,
                      cursorColor: _C.green,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: _C.dark,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4),
                  child: Text(
                    error!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: _C.error,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatefulWidget {
  final bool saving;
  final VoidCallback onPressed;

  const _SaveButton({required this.saving, required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.saving ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _C.green,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _C.green.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.saving
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  const _Reveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _SoftLeavesPainter extends CustomPainter {
  final Animation<double> anim;
  _SoftLeavesPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Curves.easeOut.transform(anim.value.clamp(0.0, 1.0));

    _leaf(canvas, Offset(w * 1.04, -h * 0.02), w * 0.58, w * 0.20,
        215 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.9 * p));
    _leaf(canvas, Offset(w * 0.98, -h * 0.01), w * 0.36, w * 0.13,
        195 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.6 * p));

    _leaf(canvas, Offset(-w * 0.04, h * 0.99), w * 0.46, w * 0.16,
        32 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.75 * p));
    _leaf(canvas, Offset(w * 0.02, h * 1.02), w * 0.34, w * 0.12,
        8 * math.pi / 180, _C.softLeaf.withValues(alpha: 0.5 * p));
  }

  void _leaf(Canvas canvas, Offset origin, double length, double width,
      double angle, Color color) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(width * 1.05, -length * 0.20, width * 0.95, -length * 0.72, 0,
          -length)
      ..cubicTo(-width * 0.95, -length * 0.72, -width * 1.05, -length * 0.20,
          0, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SoftLeavesPainter old) => false;
}
