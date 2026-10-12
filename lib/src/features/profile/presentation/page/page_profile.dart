import 'dart:convert';

import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class PageProfile extends StatelessWidget {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      body: Consumer<LoginProvider>(
        builder: (context, provider, _) {
          // Se lee en cada rebuild: al guardar en "Editar perfil" el provider
          // notifica y la tarjeta muestra el nombre/foto nuevos.
          final user = Preferences().getUser();

          return Stack(
            children: [
              SafeArea(
                bottom: false,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  // Espacio inferior para la barra de navegación flotante.
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    UtilSize.bottomPadding() + 110,
                  ),
                  children: [
                    Text(
                      'Perfil',
                      style: TextStyle(
                        color: whiteColor(),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _UserCard(
                      name: user?.name ?? '',
                      email: user?.email ?? '',
                      img: user?.img ?? '',
                      onTap:
                          () =>
                              Navigator.pushNamed(context, RouteNames.pageUser),
                    ),

                    const _SectionTitle('Cuenta'),
                    const _OptionsGroup(
                      children: [
                        _OptionRow(
                          icon: Icons.lock_outline,
                          title: 'Cambiar contraseña',
                        ),
                        _OptionRow(
                          icon: Icons.ios_share,
                          title: 'Compartir aplicación',
                        ),
                      ],
                    ),

                    const _SectionTitle('Ayuda'),
                    const _OptionsGroup(
                      children: [
                        _OptionRow(
                          icon: Icons.call_outlined,
                          title: 'Contactar soporte',
                        ),
                        _OptionRow(
                          icon: Icons.help_outline,
                          title: 'Preguntas frecuentes',
                        ),
                        _OptionRow(
                          icon: Icons.info_outline,
                          title: 'Acerca de nosotros',
                        ),
                        _OptionRow(
                          icon: Icons.phone_iphone,
                          title: 'Versión de la app',
                          trailing: _AppVersionText(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _OptionsGroup(
                      children: [
                        _OptionRow(
                          icon: Icons.logout,
                          title: 'Cerrar sesión',
                          color: errorColor(),
                          trailing: const SizedBox.shrink(),
                          onTap: () async {
                            await provider.logout();
                            if (!context.mounted) return;
                            if (provider.user == null) {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.pageLogin,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (provider.isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: CircularProgressIndicator(color: accentColor()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────── Tarjeta de usuario ─────────────────

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String img;
  final VoidCallback onTap;

  const _UserCard({
    required this.name,
    required this.email,
    required this.img,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(deepForestGreen(), accentColor(), 0.1)!,
            deepForestGreen(),
          ],
        ),
        border: Border.all(color: accentColor().withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArcsPainter(color: accentColor()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
                  child: Row(
                    children: [
                      _Avatar(img: img),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: whiteColor(),
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: grayInputColor(),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ver mis datos',
                              style: TextStyle(
                                color: accentColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: accentColor(), size: 28),
                    ],
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

class _Avatar extends StatelessWidget {
  final String img;

  const _Avatar({required this.img});

  static const double _size = 78;

  ImageProvider? get _image {
    if (img.isEmpty) return null;
    // URL (subida reciente o ruta del servidor) o base64 (formato antiguo).
    if (img.startsWith('http') || img.contains('files/user/')) {
      return NetworkImage(img);
    }
    try {
      return MemoryImage(base64Decode(img));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return Container(
      width: _size,
      height: _size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor(), width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: primaryColor(),
        backgroundImage: image,
        onBackgroundImageError: image == null ? null : (_, __) {},
        child:
            image == null
                ? Icon(Icons.person_outline, color: grayInputColor(), size: 32)
                : null,
      ),
    );
  }
}

/// Arcos concéntricos decorativos desde la esquina inferior derecha.
class _ArcsPainter extends CustomPainter {
  final Color color;

  const _ArcsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.12);

    final center = Offset(size.width, size.height);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.height * 0.45 * i, paint);
    }
  }

  @override
  bool shouldRepaint(_ArcsPainter oldDelegate) => oldDelegate.color != color;
}

// ───────────────── Opciones ─────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: grayInputColor(),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _OptionsGroup extends StatelessWidget {
  final List<Widget> children;

  const _OptionsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Container(
      decoration: BoxDecoration(
        color: deepForestGreen(),
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de opción. Por ahora no navega: las pantallas de contraseña,
/// soporte, FAQ, etc. todavía no existen.
class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  // Por ahora solo "Cerrar sesión" tiene acción: las pantallas de
  // contraseña, soporte, FAQ, etc. todavía no existen.
  final VoidCallback? onTap;
  // Color del ícono y del texto (por defecto acento / blanco).
  final Color? color;

  const _OptionRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color ?? accentColor(), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color ?? whiteColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: grayInputColor()),
          ],
        ),
      ),
    );
  }
}

class _AppVersionText extends StatefulWidget {
  const _AppVersionText();

  @override
  State<_AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<_AppVersionText> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;
        return Text(
          info == null ? '' : '${info.version} (${info.buildNumber})',
          style: TextStyle(color: grayInputColor(), fontSize: 15),
        );
      },
    );
  }
}
