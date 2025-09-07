# UI Kit Components

Reusable user interface components for Frame Forge.

## PropertyTextField

Base TextField with automatic Tab and focus handling for property widgets.

### Features:
- ✅ Automatic Tab key handling
- ✅ Event emission on focus loss  
- ✅ Customizable callbacks for all events
- ✅ Standard Tab behavior (navigation between fields)
- ✅ **Automatic text selection on focus**

### Usage example:
```dart
PropertyTextField(
  controller: textController,
  focusNode: focusNode,
  onChanged: (value) => updateValue(value),
  onSubmitted: () => emitChange(),
  onTapOutside: () => emitChange(),
  onTabPressed: () => emitChange(),
  onFocusLost: () => emitChange(),
  keyboardType: TextInputType.number,
  selectAllOnFocus: true, // Enabled by default
)
```

### Text selection parameters:
- `selectAllOnFocus: true` (default) - selects all text when receiving focus
- `selectAllOnFocus: false` - disables automatic text selection

## NumericPropertyTextField

Specialized version of PropertyTextField for numeric values.

### Features:
- ✅ All PropertyTextField capabilities
- ✅ Automatically configured keyboardType: TextInputType.number

### Usage example:
```dart
NumericPropertyTextField(
  controller: numberController,
  focusNode: focusNode,
  onChanged: (value) => updateNumber(value),
  onSubmitted: () => emitChange(),
)
```

## DualPropertyTextField

Widget for entering a pair of related values (coordinates, dimensions, etc.).

### Features:
- ✅ Two linked numeric fields
- ✅ Customizable labels for each field
- ✅ Unified event handling for both fields
- ✅ Automatic Tab handling between fields

### Usage example:
```dart
DualPropertyTextField(
  firstLabel: "X",
  secondLabel: "Y", 
  firstController: xController,
  secondController: yController,
  firstFocusNode: xFocusNode,
  secondFocusNode: yFocusNode,
  onFirstChanged: (value) => updateX(value),
  onSecondChanged: (value) => updateY(value),
  onSubmitted: () => emitChange(),
  onTabPressed: () => emitChange(),
)
```

## Extending UIKit

To add new components:

1. Create component file in `lib/src/ui_kit/`
2. Add export in `lib/src/ui_kit/ui_kit.dart`
3. Component will be automatically available via `import 'package:frame_forge/frame_forge.dart'`

### Recommendations:
- Follow patterns of existing components
- Always handle Tab events with `KeyEventResult.ignored`
- Provide callbacks for all important events
- Use appropriate default values
