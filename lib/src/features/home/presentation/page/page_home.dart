// import 'package:ecored_app/src/core/utils/utils_assets.dart';
// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:ecored_app/src/core/utils/utils_size.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/login/data/models/model_user.dart';
// import 'package:flutter/material.dart';

// class PageHome extends StatelessWidget {
//   const PageHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Preferences pref = Preferences();
//     final ModelUser? user = pref.getUser();

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Container(
//           margin: EdgeInsets.only(top: UtilSize.statusBarHeight() + 20),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               // Bienvenida
//               Align(
//                 alignment: Alignment.center,
//                 child: LabelTitle(
//                   title: 'Bienvenido \n ${user?.name ?? 'Usuario'}',
//                   textColor: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Imagen principal
//               CustomAssetImg(
//                 imagePath: AssetPaths.car_electric,
//                 width: double.infinity,
//                 height: UtilSize.height(context) * 0.3,
//               ),

//               const SizedBox(height: 20),

//               // Frase o tagline
//               LabelTitle(
//                 title:
//                     'Conduce el futuro, recarga con energía limpia y sostenible ⚡️',
//                 textColor: Colors.white70,
//                 fontSize: 16,
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 30),

//               // -------------------------
//               // Redes sociales
//               // -------------------------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Síguenos en redes sociales',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _SocialButton(icon: Icons.facebook, color: Colors.blueAccent),
//                   _SocialButton(icon: Icons.camera_alt, color: Colors.purple),
//                   _SocialButton(
//                     icon: Icons.play_circle_fill,
//                     color: Colors.red,
//                   ),
//                   _SocialButton(icon: Icons.web, color: Colors.greenAccent),
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // -------------------------
//               // Tutoriales o Tips
//               // -------------------------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Tutoriales y consejos',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),

//               // Scroll horizontal con tips
//               SizedBox(
//                 height: 180,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Cómo usar una estación de carga',
//                       subtitle: 'Aprende a conectar tu vehículo fácilmente.',
//                     ),
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Consejos para cuidar tu batería',
//                       subtitle: 'Extiende la vida útil de tu auto eléctrico.',
//                     ),
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Ventajas de la energía verde',
//                       subtitle: 'Ahorra dinero y ayuda al planeta 🌍',
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // -------------------------
//               // Pie o mensaje final
//               // -------------------------
//               Text(
//                 'Versión 1.0.0 — EcoRed App',
//                 style: TextStyle(color: Colors.white38, fontSize: 12),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -------------------------
// // Widgets auxiliares
// // -------------------------

// class _SocialButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;

//   const _SocialButton({required this.icon, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       backgroundColor: color.withOpacity(0.2),
//       radius: 28,
//       child: Icon(icon, color: color, size: 30),
//     );
//   }
// }

// class _TutorialCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final String subtitle;

//   const _TutorialCard({
//     required this.image,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 220,
//       margin: const EdgeInsets.only(right: 15),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Imagen superior
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             child: Image.asset(
//               image,
//               width: 220,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 11,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Colors.white70, fontSize: 10),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:ecored_app/src/core/utils/utils_assets.dart';
// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:ecored_app/src/core/utils/utils_size.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/login/data/models/model_user.dart';
// import 'package:flutter/material.dart';

// class PageHome extends StatelessWidget {
//   const PageHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Preferences pref = Preferences();
//     final ModelUser? user = pref.getUser();

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Container(
//           margin: EdgeInsets.only(top: UtilSize.statusBarHeight() + 20),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               // -------------------------
//               // Título y bienvenida
//               // -------------------------
//               LabelTitle(
//                 title: 'Bienvenido ${user?.name ?? 'Usuario'}',
//                 textColor: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.w600,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),

//               // -------------------------
//               // Imagen principal
//               // -------------------------
//               CustomAssetImg(
//                 imagePath: AssetPaths.car_electric,
//                 width: double.infinity,
//                 height: UtilSize.height(context) * 0.35,
//               ),

//               const SizedBox(height: 20),

//               // -------------------------
//               // Frase o tagline
//               // -------------------------
//               LabelTitle(
//                 title:
//                     'Conduce el futuro, recarga con energía limpia y sostenible ⚡️',
//                 textColor: Colors.white70,
//                 fontSize: 18,
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 30),

//               // -------------------------
//               // Redes sociales (sólo íconos)
//               // -------------------------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Síguenos en redes sociales',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _SocialButton(icon: Icons.facebook, color: Colors.blueAccent),
//                   _SocialButton(icon: Icons.camera_alt, color: Colors.purple),
//                   _SocialButton(
//                     icon: Icons.play_circle_fill,
//                     color: Colors.red,
//                   ),
//                   _SocialButton(icon: Icons.web, color: Colors.greenAccent),
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // -------------------------
//               // Tutoriales / Tips
//               // -------------------------
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Tutoriales y consejos',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),

//               // Carrusel de tips
//               SizedBox(
//                 height: 190,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Cómo usar una estación de carga',
//                       subtitle: 'Aprende a conectar tu vehículo fácilmente.',
//                     ),
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Consejos para cuidar tu batería',
//                       subtitle: 'Extiende la vida útil de tu auto eléctrico.',
//                     ),
//                     _TutorialCard(
//                       image: AssetPaths.car_electric,
//                       title: 'Ventajas de la energía verde',
//                       subtitle: 'Ahorra dinero y ayuda al planeta 🌍',
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // -------------------------
//               // Footer (Información de la app)
//               // -------------------------
//               Text(
//                 'Versión 1.0.0 — EcoRed App',
//                 style: TextStyle(color: Colors.white38, fontSize: 12),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -------------------------
// // Widgets auxiliares para botones sociales
// // -------------------------

// class _SocialButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;

//   const _SocialButton({required this.icon, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Aquí puedes implementar la navegación o apertura de red social
//       },
//       child: CircleAvatar(
//         backgroundColor: color.withOpacity(0.1),
//         radius: 30,
//         child: Icon(icon, color: color, size: 30),
//       ),
//     );
//   }
// }

// // -------------------------
// // Tarjetas para tutoriales / tips
// // -------------------------

// class _TutorialCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final String subtitle;

//   const _TutorialCard({
//     required this.image,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 220,
//       margin: const EdgeInsets.only(right: 15),
//       decoration: BoxDecoration(
//         color: Colors.grey[850],
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             offset: Offset(0, 4),
//             blurRadius: 6,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Imagen superior
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             child: Image.asset(
//               image,
//               width: 220,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
      backgroundColor: Colors.black,

      body: Container(
        margin: EdgeInsets.only(top: UtilSize.statusBarHeight() + 20),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            LabelTitle(
              title: 'Bienvenido ${user?.name ?? 'Usuario'}',
              textColor: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              alignment: Alignment.center,
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
