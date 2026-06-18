import 'package:ecored_app/src/core/config/enviroment.dart';
import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/access/datasources/access_service_data_source.dart';
import 'package:ecored_app/src/features/charger/presentation/page/page_opt_charger.dart';
import 'package:ecored_app/src/features/finance/presentation/page/page_finance.dart';
import 'package:ecored_app/src/features/home/presentation/page/page_home.dart';
import 'package:ecored_app/src/features/maps/presentation/page/page_maps.dart';
import 'package:ecored_app/src/features/profile/presentation/page/page_profile.dart';
import 'package:flutter/material.dart';

class PageAccess extends StatefulWidget {
  const PageAccess({super.key});

  @override
  State<PageAccess> createState() => _PageAccessState();
}

class _PageAccessState extends State<PageAccess> {
  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
  final AccessServicesDataSourceImpl apiAccess = AccessServicesDataSourceImpl(
    Environment.url,
  );

  late Future<int> _validateFuture;
  bool _redirected = false; // 🔥 evita múltiples navegaciones

  @override
  void initState() {
    super.initState();
    _validateFuture = apiAccess.validateToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: FutureBuilder<int>(
        future: _validateFuture,
        builder: (context, snapshot) {
          // 🔄 loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ error
          if (snapshot.hasError) {
            _handleInvalidSession();
            return const SizedBox();
          }

          // ⚠️ token inválido
          if (snapshot.hasData && snapshot.data != 200) {
            _handleInvalidSession();
            return const SizedBox();
          }

          // ✅ token válido
          return ValueListenableBuilder<int>(
            valueListenable: _indexNotifier,
            builder: (context, index, child) {
              return _getPages()[index];
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottonBar(indexNotifier: _indexNotifier),
    );
  }

  void _handleInvalidSession() {
    if (_redirected) return; // 🔥 evita loops

    _redirected = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, RouteNames.pageLogin);
    });
  }

  List<Widget> _getPages() {
    return [
      PageHome(),
      PageMaps(),
      PageOptCharger(),
      PageFinance(),
      PageProfile(),
    ];
    // return [PageHome(), PageMaps(), PageScanQr(), PageFinance(), PageProfile()];
  }
}
// class PageAccess extends StatefulWidget {
//   const PageAccess({super.key});

//   @override
//   State<PageAccess> createState() => _PageAccessState();
// }

// class _PageAccessState extends State<PageAccess> {
//   final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);
//   final AccessServicesDataSourceImpl apiAccess = AccessServicesDataSourceImpl(
//     Environment.url,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,

//       body: FutureBuilder<int>(
//         future: apiAccess.validateToken(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Mientras esperamos la respuesta del servicio, podemos mostrar un cargando
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             // Si hay un error, mostramos un mensaje
//             return Center(child: Text('Error al validar el token.'));
//           }

//           return ValueListenableBuilder(
//             valueListenable: _indexNotifier,
//             builder: (context, index, child) {
//               // return IndexedStack(index: index, children: _getPages(index));
//               return _getPages(index)[index];
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: CustomBottonBar(indexNotifier: _indexNotifier),
//     );
//   }

//   //Methods to handle navigation and other logic can be added here
//   List<Widget> _getPages(int index) {
//     return [PageHome(), PageMaps(), PageScanQr(), PageFinance(), PageProfile()];
//   }
// }
