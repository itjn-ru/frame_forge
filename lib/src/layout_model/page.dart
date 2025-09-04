import 'item.dart';
import 'screen_size_enum.dart';

class ComponentAndSourcePage extends Item {
  ComponentAndSourcePage(super.type, super.name);
}

// class ScreenSizeLayout extends ComponentAndSourcePage{
//   final ScreenSizeEnum? screenSize;
//   ScreenSizeLayout(super.type, super.name, [this.screenSize = ScreenSizeEnum.mobile]){
//     properties['screenSize']=Property('размер экрана', screenSize, type: ScreenSizeEnum);
//   }
//   @override
//   String toString() {
//     return properties['screenSize']?.value.title??'null';
//   }
// }
class ComponentPage extends ComponentAndSourcePage {
  final ScreenSizeEnum? screenSize;
  ComponentPage(name, [this.screenSize = ScreenSizeEnum.mobile])
      : super("componentPage", name);
}

class SourcePage extends ComponentAndSourcePage {
  SourcePage(name) : super("sourcePage", name);
}

class StylePage extends ComponentAndSourcePage {
  StylePage(name) : super("stylePage", name);
}

class ProcessPage extends ComponentAndSourcePage {
  ProcessPage(name, {this.viewport}) : super("processPage", name);
  Map<String, dynamic>? viewport = {
    "offset": [0.0, 0.0],
    "zoom": 1.0
  };
}
