import 'package:flutter/material.dart';

void main() {
  runApp(const DeltaruneStudioShell());
}

class DeltaruneStudioShell extends StatelessWidget {
  const DeltaruneStudioShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deltarune Studio',
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Deltarune Studio')),
        body: const Center(
          child: Text('Editor runtime is ready for the new architecture.'),
        ),
      ),
    );
  }
}
