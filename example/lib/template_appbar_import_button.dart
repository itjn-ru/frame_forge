import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';

class TemplateAppbarImportButton extends StatelessWidget {
  final LayoutModelController controller;
  const TemplateAppbarImportButton(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () async => controller.project.load(),
        child: const Text('Импорт', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
