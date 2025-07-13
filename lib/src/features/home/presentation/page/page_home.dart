import 'package:flutter/material.dart';

class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to the Home Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:flutter/material.dart';

// class PageHome extends StatefulWidget {
//   const PageHome({super.key});

//   @override
//   State<PageHome> createState() => _PageHomeState();
// }

// class _PageHomeState extends State<PageHome> {
//   final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(0);

//   @override
//   Widget build(BuildContext context) {
//     // List<Map> latLngMarkers = [
//     //   {'_id': 'aoeurcgc', 'lat': -2.888100139166612, 'lng': -78.98455544907367},
//     //   {'_id': 'aoeurcgc', 'lat': -2.9014499915134335, 'lng': -78.9937269702811},
//     //   {'_id': 'aoeurcgc', 'lat': -2.89698963821467, 'lng': -79.00210722955012},
//     //   {'_id': 'aoeurcgc', 'lat': -2.903732995835395, 'lng': -79.0187781133494},
//     // ];

//     return Scaffold(
//       extendBody: true,
//       body: ValueListenableBuilder(
//         valueListenable: _indexNotifier,
//         builder: (context, index, child) {
//           return IndexedStack(index: index, children: _getPages(index));
//         },
//       ),
//       bottomNavigationBar: CustomBottonBar(indexNotifier: _indexNotifier),
//     );
//   }

//   //Methods to handle navigation and other logic can be added here
//   List<Widget> _getPages(int index) {
//     return [
//       Container(color: Colors.red, child: Center(child: Text('Page 1'))),
//       Container(color: Colors.green, child: Center(child: Text('Page 2'))),
//       Container(color: Colors.blue, child: Center(child: Text('Page 3'))),
//       Container(color: Colors.orange, child: Center(child: Text('Page 4'))),
//     ];
//   }
// }
