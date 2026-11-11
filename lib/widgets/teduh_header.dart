import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/riwayat_notifikasi_page.dart';

class TeduhHeader extends StatelessWidget {
  final String title;

  final String accent;
  final String subtitle;
  final VoidCallback onMenu;
  final VoidCallback? onNotification;

  const TeduhHeader({
    super.key,
    this.title = 'TEDUH ',
    required this.accent,
    required this.subtitle,
    required this.onMenu,
    this.onNotification,
  });

  static const Color dark = Color(0xFF1F3D2F);
  static const Color green = Color(0xFF1B6F57);
  static const Color grey = Color(0xFF7C8A82);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Buka menu samping',
          child: IconButton(
            onPressed: onMenu,
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            iconSize: 30,
            color: green,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: dark,
                        ),
                      ),
                      TextSpan(
                        text: accent,
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                header: true,
                label: '$title$accent. $subtitle',
                child: ExcludeSemantics(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Notifikasi. Ada pemberitahuan baru',
          child: Material(
            color: Colors.white,
            elevation: 1.5,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onNotification ??
                  () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RiwayatNotifikasiPage(),
                        ),
                      ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        size: 24, color: green),
                    Positioned(
                      right: 12,
                      top: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE05A5A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
