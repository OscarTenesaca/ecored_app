import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_assets.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/utils/utils_size.dart';
import 'package:ecored_app/src/core/widgets/cards/card_tutorial.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/data/models/model_user.dart';
import 'package:flutter/material.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    // final ModelUser pref = Preferences();
    final Preferences pref = Preferences();
    final ModelUser? user = pref.getUser();
    final List<Map<String, String>> tips = [
      {
        "title": "Mantén la batería entre 20% y 80%",
        "subtitle":
            "Evita cargar siempre al 100% o dejarla bajar de 10%. Mantenerla entre 20% y 80% alarga la vida útil, reduce el desgaste químico y ayuda a conservar la autonomía con el tiempo.",
      },
      {
        "title": "Prefiere cargas lentas",
        "subtitle":
            "Las cargas rápidas son útiles en viajes o emergencias, pero generan mayor calor y desgaste. Cuando tengas tiempo, usa carga lenta o nivel 2 para un cuidado prolongado de la batería.",
      },
      {
        "title": "Evita cargar con temperaturas extremas",
        "subtitle":
            "Si la batería está muy caliente por el sol o muy fría, espera unos minutos o deja que el vehículo regule la temperatura antes de cargar. Esto evita daños internos y mantiene un rendimiento óptimo.",
      },
      {
        "title": "Planifica tu carga según la ruta",
        "subtitle":
            "No siempre es necesario llegar al 100%. Para trayectos diarios, entre 60% y 70% suele ser suficiente. En viajes largos, planifica paradas estratégicas para cargas cortas y más eficientes.",
      },
    ];

    return Scaffold(
      backgroundColor: primaryColor(),
      body: Container(
        margin: EdgeInsets.only(top: UtilSize.statusBarHeight()),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título de bienvenida
                Expanded(
                  child: Column(
                    children: [
                      LabelTitle(
                        title:
                            'Bienvenido ${user?.name.split(' ')[0] ?? 'Usuario'},',
                        textColor: accentColor(),
                        fontSize: 24,
                        textAlign: TextAlign.left,
                        alignment: Alignment.centerLeft,
                      ),
                      LabelTitle(
                        title: 'Hora de recargar.',
                        textColor: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.left,
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),

                // Imagen de perfil en círculo
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      user?.img != null
                          ? NetworkImage(user!.img)
                          : const AssetImage(AssetPaths.logo) as ImageProvider,
                ),
              ],
            ),
            const SizedBox(height: 30),
            //asset image
            CustomAssetImg(
              imagePath: AssetPaths.car_electric,
              width: double.infinity,
              height: UtilSize.height(context) * 0.3,
            ),

            LabelTitle(
              title:
                  'Conduce el futuro, recarga con energía limpia y sostenible.⚡️',
              textColor: Colors.white70,
              fontSize: 16,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),
            LabelTitle(
              title: 'Tutoriales y consejos',
              textColor: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.left,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 15),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              shrinkWrap: true,
              itemCount: tips.length,

              itemBuilder: (context, index) {
                final tip = tips[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: CardTutorial(
                    image: AssetPaths.charge_station,
                    title: tip['title']!,
                    subtitle: tip['subtitle']!,
                    onPressed: () {
                      showModalChild(
                        context: context,
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                tip['subtitle']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          // child: Text(
                          //   tip['subtitle']!,
                          //   style: const TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            LabelTitle(
              title: 'Síguenos en redes sociales',
              textColor: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.left,
              alignment: Alignment.centerLeft,
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButtonCircle(
                  icon: Icons.facebook,
                  color: Colors.blueAccent,
                  onPressed: () {
                    print('Facebook pressed');
                  },
                ),

                CustomButtonCircle(
                  icon: Icons.photo_camera_back,
                  color: Colors.purple,
                  onPressed: () {
                    print('Camera pressed');
                  },
                ),
                CustomButtonCircle(
                  icon: Icons.tiktok,
                  color: Colors.grey,
                  onPressed: () {
                    print('TikTok pressed');
                  },
                ),
                CustomButtonCircle(
                  icon: Icons.play_circle_fill,
                  color: Colors.red,
                  onPressed: () {
                    print('Play pressed');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
