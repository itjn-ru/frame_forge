# Frame Forge

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/itjn-ru/frame_forge/blob/main/README.md)
[![ru](https://img.shields.io/badge/lang-ru-blue.svg)](https://github.com/itjn-ru/frame_forge/blob/main/README.ru.md)

## Описание
Этот пакет предоставляет визуальный редактор для проектирования и рендеринга пользовательских интерфейсов.
В его основе лежит использование XML как формата описания структуры UI. Изначально разработанный для работы с документами и структурированными данными, он отлично подходит для систем с архитектурой BDUI (Backend-Driven UI).

## Возможности

### Визуальный UI Редактор
- **Drag & Drop Интерфейс** - Интуитивный визуальный редактор для создания макетов
- **Предварительный просмотр в реальном времени** - Мгновенное отображение изменений при проектировании
- **Поддержка мультиэкранов** - Одновременное проектирование для мобильных, планшетных и десктопных устройств
- **Привязка к сетке** - Точное позиционирование с привязкой к сетке

### Архитектура и Интеграция
- **XML-структура** - Чистая, читаемая разметка описывает UI компоненты и свойства
- **BDUI (Backend-Driven UI)** - Сервер управляет UI без обновления клиентского приложения
- **Динамический рендеринг** - Интерфейс генерируется из данных сервера во время выполнения
- **Сервис-ориентированная архитектура** - Модульный дизайн с внедрением зависимостей

### Удобство Разработки
- **Система Отмены/Повтора** - Полное управление историей с горячими клавишами (Ctrl+Z/Ctrl+Y)
- **Операции Копирования/Вставки** - Эффективное дублирование компонентов и макетов
- **Глобальные обработчики клавиатуры** - Поддержка международных раскладок клавиатуры
- **Управление проектами** - Сохранение/загрузка проектов с пользовательской сериализацией

### Продвинутые Функции
- **Библиотека компонентов** - вариативность UI компонентов за счет добавления стилей
- **Привязка данных** - Соединение UI элементов с динамическими источниками данных
- **Управление стилями** - Централизованная стилизация с поддержкой тем
- **Рабочие процессы** - Определение сложных UI взаимодействий и потоков
- **Адаптивный дизайн** - Адаптивные макеты для различных размеров экрана

### Производительность и Надёжность
- **Эффективный рендеринг** - Оптимизированные обновления дерева виджетов
- **Управление памятью** - Очистка и управление ресурсами
- **Обработка ошибок** - Надёжное восстановление после ошибок и валидация
- **Кроссплатформенность** - Работа на Web, Mobile и Desktop
 
## Motivation
Без изменения кода, загрузки в store изменять UI и обмен данными с сервером приложения клиента.   
![admin-layout-photo](./doc/images/admin-layout-photo.png)


## Использование

### Создать DSL модель
- Добавить нужные размеры экранов для LayoutModel.
- Создать контроллер

```dart
  final LayoutModel layoutModel = LayoutModel(
    screenSizes: [ScreenSizeEnum.mobile, ScreenSizeEnum.desktop],
  );
  
  late final LayoutModelController _layoutModelController =
      LayoutModelController(
        layoutModel: layoutModel,
        projectSaver: (map) async {
          // Здесь можно настроить сохранение проекта
          return true;
        },
        projectLoader: (isSaved) async {
          /// Загрузка модели из файла
          final FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result == null) return null;
          final PlatformFile file = result.files.first;
          return utf8.decode(file.bytes! as List<int>);
        },
      );
```
Если есть желание использовать на клавиатуре хоткеи: copy/past/undo/redo, надо инициализировать HardwareKeyboard instance с хандлером.

```dart
void initState() {
    //listen to controller events to update UI
    _layoutModelController.eventBus.events.listen(_handleControllerEvents);
    // Register global keyboard handler
    HardwareKeyboard.instance.addHandler(_layoutModelController.keyboardHandler.handleKeyEvent);
    super.initState();
  }
```



### Основные компоненты

Вывод компонентов макета:
```dart
Column(
  children: [
    Items(layoutModel.root, layoutModel),
  ],
),
```

Вывод источников-переменных макета:
```dart
Column(
  children: [
    Items(
        layoutModel.root.items
            .whereType<SourcePage>()
            .first, layoutModel,
    ),
  ],
),
```

Вывод стилей макета:
```dart
Column(
  children: [
    Items(
        layoutModel.root.items
            .whereType<StylePage>()
            .first, layoutModel, 
    ),
  ],
),
```

Вывод процессов макета:
```dart
Column(
  children: [
    ProcessItems(
        layoutModel.root.items
            .whereType<ProcessPage>()
            .first,layoutModel,
    ),
  ],
),
```

Вывод вьюшки, как страница выглядит
Обязательно указать размер экрана из [ScreenSizeEnum]
```dart
LayoutBuilder(
    builder: (context, constraints) {
        return Consumer<LayoutModel>(
            builder: (context, value, child) {
                return ComponentsAndSources(value,constraints, screenSize);
            },
        );
    }
),
```
