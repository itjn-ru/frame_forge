import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';

class TemplateAppbarExportButton extends StatelessWidget {
  final LayoutModelController controller;
  const TemplateAppbarExportButton(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () async => controller.project.save(),
        child: const Text('Export', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
