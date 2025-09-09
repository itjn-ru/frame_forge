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

class TemplateAppbarImportButtonExample extends StatelessWidget {
  final LayoutModelController controller;
  const TemplateAppbarImportButtonExample(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    

final data='''
<?xml version="1.0" encoding="UTF-8"?>
<layout>
  <properties>
    <id>838d44d2-2563-40be-a369-e6217dd1faec</id>
    <name>макет</name>
    <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
  </properties>
  <items>
    <componentPage>
      <properties>
        <id>356160eb-0f4d-46bc-a0ec-809571a53fec</id>
        <name>страница</name>
        <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
      </properties>
      <items>
        <text>
          <properties>
            <id>6f89e212-d7d7-4f98-9ffb-ceee05258995</id>
            <name>текст</name>
            <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
            <position left="60" top="140"/>
            <size width="260" height="140"/>
            <text>This&amp;#x20;is&amp;#x20;text</text>
            <alignment x="0" y="0"/>
          </properties>
          <items/>
        </text>
      </items>
    </componentPage>
    <sourcePage>
      <properties>
        <id>3ad26552-52d1-4f7c-be6d-a34b1c38a407</id>
        <name>страница&amp;#x20;данных</name>
        <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
      </properties>
      <items/>
    </sourcePage>
    <stylePage>
      <properties>
        <id>7cca7c5a-1ea5-4f97-b516-59ff53a22bf9</id>
        <name>страница&amp;#x20;стилей</name>
        <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
      </properties>
      <items>
        <styleElement>
          <properties>
            <id>00000000-0000-0000-0000-000000000000</id>
            <name>базовый&amp;#x20;стиль</name>
            <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
            <color>FF000000</color>
            <backgroundColor>0</backgroundColor>
            <alignment x="-1" y="0"/>
            <fontSize>11</fontSize>
            <fontWeight>700</fontWeight>
            <borderRadius radius="12" type="BorderRadiusAll"/>
            <padding>0,5,10,20</padding>
            <margin>5,0,0,0</margin>
            <topBorder width="1" color="FF416AF0" side="CustomBorderSide.solid"/>
            <bottomBorder width="1" color="FF416AF0" side="CustomBorderSide.solid"/>
            <leftBorder width="1" color="FF416AF0" side="CustomBorderSide.solid"/>
            <rightBorder width="1" color="FF416AF0" side="CustomBorderSide.solid"/>
          </properties>
          <items/>
        </styleElement>
      </items>
    </stylePage>
    <processPage>
      <properties>
        <id>31ceb76b-a262-418d-b159-bec60b0e11be</id>
        <name>процессы</name>
        <style id="00000000-0000-0000-0000-000000000000" name="базовый стиль"/>
      </properties>
      <items/>
    </processPage>
  </items>
</layout>
''';
return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () async => controller.project.load(data: data),
        child: const Text('Импорт примера', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}