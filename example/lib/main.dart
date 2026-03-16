import 'package:flutter/material.dart';

void main() {
  runApp(const ObersUiExample());
}

/// Example app showcasing obers_ui components.
class ObersUiExample extends StatelessWidget {
  const ObersUiExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'obers_ui Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const CatalogHome(),
    );
  }
}

/// Home screen with a catalog of all obers_ui components.
class CatalogHome extends StatelessWidget {
  const CatalogHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('obers_ui Catalog')),
      body: const Center(
        child: Text('Components coming soon.'),
      ),
    );
  }
}
