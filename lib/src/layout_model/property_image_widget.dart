import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../frame_forge.dart';
import 'property.dart';
import 'property_widget.dart';

class PropertyImageWidget extends PropertyWidget {
  const PropertyImageWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.layoutModel.curItem.properties[propertyKey];
    return ShowImageProperty(
        property: property, propertyKey: propertyKey, controller: controller);
  }
}

class ShowImageProperty extends StatefulWidget {
  const ShowImageProperty({
    super.key,
    this.property,
    required this.propertyKey,
    required this.controller,
  });
  final Property? property;
  final String propertyKey;
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
    final Property? property =
        widget.controller.getCurrentItem()?.properties[widget.propertyKey];
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
              width: 64,
              height: 64,
              child: Image.memory(
                widget.property?.value!,
                fit: widget.controller
                        .getCurrentItem()
                        ?.properties['fit']
                        ?.value ??
                    BoxFit.contain,
              ),
            ),
          );
        } else {
          if (snapshot.hasData) {
            final Uint8List data = snapshot.data!;
            if (data.isNotEmpty && data[0] != 0x00) {
              property?.value = data;
              widget.controller.eventBus.emit(
                ChangeItem(
                  id: const Uuid().v4(),
                  itemId: widget.controller.layoutModel.curItem.id,
                ),
              );
              return InkWell(
                onTap: () async {
                  setState(() {
                    images = pickUploadFiles();
                  });
                },
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.memory(
                    data,
                    fit: widget.controller
                            .getCurrentItem()
                            ?.properties['fit']
                            ?.value ??
                        BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) =>
                        const Center(child: Text('Error loading image')),
                  ),
                ),
              );
            } else {
              // Если данные некорректны, показываем ошибку и кнопку повторной загрузки
              return InkWell(
                onTap: () async {
                  setState(() {
                    images = pickUploadFiles();
                  });
                },
                child: const SizedBox(
                  height: 50,
                  child:
                      Center(child: Text('Error: invalid file. Tap to retry.')),
                ),
              );
            }
          } else {
            return InkWell(
              onTap: () async {
                setState(() {
                  images = pickUploadFiles();
                });
              },
              child: SizedBox(
                  height: 50, child: const Text('Tap to upload image')),
            );
          }
        }
      },
    );
  }
}
