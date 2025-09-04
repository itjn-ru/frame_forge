import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'property.dart';
import 'property_widget.dart';

class PropertyImageWidget extends PropertyWidget {
  const PropertyImageWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final property = controller.layoutModel.curItem.properties[propertyKey]!;
    return  ShowImageProperty(property: property);
  }
}

class ShowImageProperty extends StatefulWidget {
  const ShowImageProperty({super.key, required this.property});
final Property property;
  @override
  State<ShowImageProperty> createState() => _ShowImagePropertyState();
}

class _ShowImagePropertyState extends State<ShowImageProperty> {
  Future<Uint8List>? images;
  @override
  initState() {
    super.initState();
  }
  Future<Uint8List> pickUploadFiles() async {
    List<PlatformFile> files=[];
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image);
    if (result != null) {
      files = result.files;
    }
    widget.property.value=files.first.bytes!;
    final asdas=base64.encode(files.first.bytes!);
    base64.decode(asdas);
    return files.first.bytes!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: images,
        builder: (context, snapshot) {
          if(widget.property.value!=null) {
            return InkWell(
              onTap: () async {
                setState(()  {
                  images = pickUploadFiles();
                });
              },
              child: SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.memory(widget.property.value!)),
            );
          }else{
          if (snapshot.hasData) {
            return InkWell(
              onTap: () async {
                setState(()  {
                images = pickUploadFiles();
                });
              },
              child: SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.memory(snapshot.data!)),
            );
          } else {
            return InkWell(onTap: () async {
              setState(()  {
                images = pickUploadFiles();
              });
            },child: const CircularProgressIndicator());
          }}
        });
  }
}
