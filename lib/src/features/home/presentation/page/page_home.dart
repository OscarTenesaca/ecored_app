import 'dart:convert';

import 'package:ecored_app/src/core/adapter/adapter_launcher.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:flutter/material.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  static const Color accent = Color(0xFFB8F000);

  @override
  Widget build(BuildContext context) {
    final tips = <TipSheetItem>[
      const TipSheetItem(
        category: "Cuidado de batería",
        summary: "Maximiza su vida útil",
        title: "Mantén la batería entre 20% y 80%",
        description:
            "Evita cargar siempre al 100% o dejarla bajar de 10%. Mantenerla entre 20% y 80% alarga la vida útil, reduce el desgaste químico y ayuda a conservar la autonomía con el tiempo.",
        // Batería horizontal, como en el diseño.
        icon: RotatedBox(
          quarterTurns: 1,
          child: Icon(Icons.battery_full_outlined),
        ),
        visual: TipRangeBar(start: 20, end: 80, label: "Zona recomendada"),
      ),
      const TipSheetItem(
        category: "Carga inteligente",
        summary: "Menos desgaste, más eficiencia",
        title: "Prefiere cargas lentas",
        description:
            "Las cargas rápidas son útiles en viajes o emergencias, pero generan mayor calor y desgaste. Cuando tengas tiempo, usa carga lenta o nivel 2 para un cuidado prolongado de la batería.",
        icon: Icon(Icons.bolt_outlined),
      ),
      const TipSheetItem(
        category: "Temperatura ideal",
        summary: "Protege el rendimiento",
        title: "Evita cargar con temperaturas extremas",
        description:
            "Si la batería está muy caliente por el sol o muy fría, espera unos minutos o deja que el vehículo regule la temperatura antes de cargar.",
        icon: Icon(Icons.thermostat_outlined),
      ),
      const TipSheetItem(
        category: "Planifica tu ruta",
        summary: "Viajes más eficientes",
        title: "Planifica tu carga según la ruta",
        description:
            "No siempre es necesario llegar al 100%. Para trayectos diarios, entre 60% y 70% suele ser suficiente.",
        icon: Icon(Icons.route_outlined),
      ),
    ];

    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _HomeUserAvatar(img: Preferences().getUser()?.img ?? ''),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelTitle(
                            title: 'Bienvenido',
                            textColor: grayInputColor(),
                          ),
                          LabelTitle(
                            title:
                                Preferences().getUser()?.name.toUpperCase() ??
                                '',
                            textColor: accentColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),

                    // IconButton(
                    //   onPressed: () {},
                    //   icon: const Icon(
                    //     Icons.notifications,
                    //     color: Colors.white70,
                    //   ),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // HERO
              Container(
                // margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  image: DecorationImage(
                    image: AssetImage(AssetPaths.car_electric),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        primaryColor(),
                        primaryColor().withValues(alpha: 0.70),
                        primaryColor().withValues(alpha: 0.30),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LabelTitle(
                        padding: false,
                        title: 'Energía limpia',
                        textColor: accentColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      LabelTitle(
                        padding: false,
                        title: "para tu camino",
                        textColor: whiteColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: LabelTitle(
                  padding: false,
                  title: "Tutoriales y consejos",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tips.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (_, index) {
                    final item = tips[index];

                    return Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: deepForestGreen(),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap:
                              () => showTipSheet(
                                context,
                                tips: tips,
                                initialIndex: index,
                              ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: accentColor().withValues(
                                          alpha: 0.14,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: IconTheme(
                                        data: IconThemeData(
                                          color: accentColor(),
                                          size: 22,
                                        ),
                                        child: Center(child: item.icon),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      color: grayInputColor(),
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: whiteColor(),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: grayInputColor(),
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: LabelTitle(
                  title: "Síguenos en nuestras redes sociales",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButtonCircle(
                    asset: AssetPaths.iconInstagram,
                    onTap:
                        () => AdapterLauncher().launchURL(
                          'https://www.instagram.com',
                        ),
                  ),
                  CustomButtonCircle(
                    asset: AssetPaths.iconFacebook,
                    onTap:
                        () => AdapterLauncher().launchURL(
                          'https://www.facebook.com',
                        ),
                  ),
                  CustomButtonCircle(
                    asset: AssetPaths.iconTiktok,
                    onTap:
                        () => AdapterLauncher().launchURL(
                          'https://www.tiktok.com',
                        ),
                  ),
                  CustomButtonCircle(
                    asset: AssetPaths.iconYoutube,
                    onTap:
                        () => AdapterLauncher().launchURL(
                          'https://www.youtube.com',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// Foto de perfil del usuario con la misma forma cuadrangular que
/// [CustomButtonSquare] (mismo tamaño/borderRadius por defecto), pero
/// mostrando la imagen real en vez de un ícono — igual que en
/// `CustomHiveImg` (perfil), que distingue entre URL de red
/// (`files/user/`) y base64.
class _HomeUserAvatar extends StatelessWidget {
  final String img;

  const _HomeUserAvatar({required this.img});

  static const double _size = 54;
  static const double _borderRadius = 18;

  @override
  Widget build(BuildContext context) {
    if (img.isEmpty) {
      return CustomButtonSquare(
        icon: Icons.person_outline,
        backgroundColor: accentColor(),
        iconColor: primaryColor(),
      );
    }

    final isNetworkImage = img.contains('files/user/');

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: SizedBox(
        width: _size,
        height: _size,
        child:
            isNetworkImage
                ? Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: accentColor(),
                        child: Icon(
                          Icons.person_outline,
                          color: primaryColor(),
                        ),
                      ),
                )
                : Image.memory(base64.decode(img), fit: BoxFit.cover),
      ),
    );
  }
}
