import 'package:flutter/material.dart';

class PageFinance extends StatelessWidget {
  const PageFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps Page')),
      body: Center(child: Text('This is the finance page')),
    );
  }
}
