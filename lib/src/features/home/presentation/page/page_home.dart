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
    final tips = [
      {
        "title": "Cuidado de batería",
        "subtitle": "Maximiza su vida útil",
        "popupTitle": "Mantén la batería entre 20% y 80%",
        "popupText":
            "Evita cargar siempre al 100% o dejarla bajar de 10%. Mantenerla entre 20% y 80% alarga la vida útil, reduce el desgaste químico y ayuda a conservar la autonomía con el tiempo.",
      },
      {
        "title": "Carga inteligente",
        "subtitle": "Menos desgaste, más eficiencia",
        "popupTitle": "Prefiere cargas lentas",
        "popupText":
            "Las cargas rápidas son útiles en viajes o emergencias, pero generan mayor calor y desgaste. Cuando tengas tiempo, usa carga lenta o nivel 2 para un cuidado prolongado de la batería.",
      },
      {
        "title": "Temperatura ideal",
        "subtitle": "Protege el rendimiento",
        "popupTitle": "Evita cargar con temperaturas extremas",
        "popupText":
            "Si la batería está muy caliente por el sol o muy fría, espera unos minutos o deja que el vehículo regule la temperatura antes de cargar.",
      },
      {
        "title": "Planifica tu ruta",
        "subtitle": "Viajes más eficientes",
        "popupTitle": "Planifica tu carga según la ruta",
        "popupText":
            "No siempre es necesario llegar al 100%. Para trayectos diarios, entre 60% y 70% suele ser suficiente.",
      },
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
                    CustomButtonSquare(
                      icon: Icons.person_outline,
                      backgroundColor: accentColor(),
                      iconColor: primaryColor(),
                    ),

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
                            // title: 'Oscar',
                            title: Preferences().getUser()!.name,
                            textColor: whiteColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white70,
                      ),
                    ),
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

                    return InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        showPopUpWithChildren(
                          context: context,
                          title: item["popupTitle"]!,
                          subTitle: item["popupText"]!,
                          sizeTitle: 21,
                          sizeSubtitle: 14,
                          textButton: 'Cerrar',
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: deepForestGreen(),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabelTitle(
                              padding: false,
                              title: item["title"]!,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),

                            const Spacer(),

                            LabelTitle(
                              padding: false,
                              title: item["subtitle"]!,
                              // fontSize: 11,
                              fontWeight: FontWeight.w600,
                              textColor: grayInputColor(),
                              textAlign: TextAlign.left,
                            ),

                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white30,
                                size: 18,
                              ),
                            ),
                          ],
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
