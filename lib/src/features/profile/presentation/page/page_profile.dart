import 'package:flutter/material.dart';

class PageProfile extends StatelessWidget {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps Page')),
      body: Center(child: Text('This is the profile page')),
    );
  }
}
