enum ScreenSizeEnum {
  mobile(width: 360, height: 720, title: 'мобильный', value: true),
  desktop(width: 720, height: 720, title: 'десктоп', value: false);
  final double width;
  final double height;
  final String title;
  final bool value;

  const ScreenSizeEnum(
      {required this.height,
        required this.width,
        required this.title,
        required this.value});


}