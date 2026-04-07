import 'package:flutter/material.dart';

class ObservationFormScreen extends StatelessWidget {
  const ObservationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva observación')),
      body: const Center(child: Text('Formulario — próxima fase')),
    );
  }
}