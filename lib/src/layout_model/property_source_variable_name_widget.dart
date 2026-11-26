import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../ui_kit/property_text_field.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'property_widget.dart';
import 'source_variable.dart';
import 'strings.dart';

/// The `name` field of a [SourceVariable] in the properties panel.
///
/// Renaming a variable is reference-safe: on commit every component
/// sourceV2 binding pointing at the old name is updated
/// (`LayoutModel.renameSourceVariable`), map children also update the
/// `mapKey` of `parent.key` references. Duplicate names are rejected with
/// a snackbar and the old name is restored. Works the same way as the
/// name cells of the fullscreen source table.
class PropertySourceVariableNameWidget extends PropertyWidget {
  const PropertySourceVariableNameWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Item? item = controller.getCurrentItem();
    if (item is! SourceVariable) {
      return InputTextPropertyWidget(controller, propertyKey);
    }
    return _SourceVariableNameField(controller: controller, variable: item);
  }
}

class _SourceVariableNameField extends StatefulWidget {
  final LayoutModelController controller;
  final SourceVariable variable;

  const _SourceVariableNameField({
    required this.controller,
    required this.variable,
  });

  @override
  State<StatefulWidget> createState() => _SourceVariableNameFieldState();
}

class _SourceVariableNameFieldState extends State<_SourceVariableNameField> {
  /// Name captured when the field gains focus: [onChanged] writes into the
  /// property on every keystroke, so the original name must be remembered
  /// before typing starts.
  String? _oldName;

  void _emitChange() {
    widget.controller.eventBus.emit(
      AttributeChangeEvent(
        id: const Uuid().v4(),
        itemId: widget.variable.id,
      ),
    );
  }

  /// Name of the parent variable when this variable is a child (map key)
  /// of a Map variable — renames then update `parent.oldKey` references.
  String? get _parentMapName {
    final Item? parent = widget.controller.layoutModel.findParentById(
      widget.controller.layoutModel.root,
      widget.variable.id,
    );
    if (parent is SourceVariable &&
        (parent.properties['type']?.value?.toString() ?? '') == 'Map') {
      return parent.properties['name']?.value?.toString();
    }
    return null;
  }

  void _onFocusGained() {
    _oldName =
        widget.variable.properties['name']?.value?.toString() ?? '';
  }

  void _commit() {
    final String oldName = _oldName ??
        (widget.variable.properties['name']?.value?.toString() ?? '');
    _oldName = null;
    final String newName = (widget.variable.properties['name']?.value
            ?.toString() ??
        '')
        .trim();
    if (newName.isEmpty || newName == oldName) {
      if (newName.isEmpty) {
        widget.variable.properties['name']?.value = oldName;
      }
      _emitChange();
      return;
    }
    if (widget.controller.layoutModel.sourceVariableNameExists(
      newName,
      excludingId: widget.variable.id,
    )) {
      widget.variable.properties['name']?.value = oldName;
      _emitChange();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(FrameForgeStrings.sourceTableDuplicateName)),
        );
      return;
    }
    widget.variable.properties['name']?.value = newName;
    // Keep component bindings pointing at the renamed variable.
    widget.controller.layoutModel.renameSourceVariable(
      oldName,
      newName,
      parentName: _parentMapName,
    );
    _emitChange();
  }

  @override
  Widget build(BuildContext context) {
    return PropertyTextField(
      defaultValue: widget.variable.properties['name']?.value?.toString() ?? '',
      onChanged: (String value) {
        widget.variable.properties['name']?.value = value;
      },
      onFocusGained: _onFocusGained,
      onSubmitted: _commit,
      onTapOutside: _commit,
      onFocusLost: _commit,
    );
  }
}
