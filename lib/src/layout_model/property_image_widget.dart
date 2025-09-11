import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'property.dart';
import 'property_widget.dart';
import 'controller/layout_model_controller.dart';

class PropertyImageWidget extends PropertyWidget {
  const PropertyImageWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.layoutModel.curItem.properties[propertyKey];
    return ShowImageProperty(property: property, controller: controller);
  }
}

class ShowImageProperty extends StatefulWidget {
  const ShowImageProperty({
    super.key,
    this.property,
    required this.controller,
  });
  final Property? property;
  final LayoutModelController controller;

  @override
  State<ShowImageProperty> createState() => _ShowImagePropertyState();
}

class _ShowImagePropertyState extends State<ShowImageProperty> {
  Future<Uint8List>? images;

  Future<Uint8List> pickUploadFiles() async {
    final Uint8List? bytes = await widget.controller.pickUploadFiles();
    if (bytes == null) {
      throw Exception(
        'No file selected or file picking not supported on this platform',
      );
    }

    widget.property?.value = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: images,
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (widget.property?.value != null) {
          return InkWell(
            onTap: () async {
              setState(() {
                images = pickUploadFiles();
              });
            },
            child: SizedBox(
              width: 128,
              height: 128,
              child: Image.memory(widget.property?.value!),
            ),
          );
        } else {
          if (snapshot.hasData) {
            return InkWell(
              onTap: () async {
                setState(() {
                  images = pickUploadFiles();
                });
              },
              child: SizedBox(
                width: 128,
                height: 128,
                child: Image.memory(snapshot.data!),
              ),
            );
          } else {
            return InkWell(
              onTap: () async {
                setState(() {
                  images = pickUploadFiles();
                });
              },
              child: const CircularProgressIndicator(),
            );
          }
        }
      },
    );
  }
}
