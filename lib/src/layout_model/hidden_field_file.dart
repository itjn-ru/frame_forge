import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'component.dart';

class HiddenFieldFile extends StatelessWidget {
  final LayoutComponent component;

  const HiddenFieldFile({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 26,
                    onPressed: () async {},
                    icon: const Icon(CupertinoIcons.paperclip)),
                const SizedBox(
                  width: 26,
                ),
                IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 26,
                    onPressed: () async {},
                    icon: const Icon(CupertinoIcons.camera)),
                const SizedBox(
                  width: 26,
                ),
                IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 26,
                    onPressed: () async {},
                    icon: const Icon(CupertinoIcons.video_camera)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

