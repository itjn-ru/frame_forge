import 'package:flutter/material.dart';

import 'controller/layout_model_controller.dart';
import 'page.dart';
import 'strings.dart';

/// Opens the quick page switcher dialog (Ctrl+K).
///
/// Fastest way to jump between layouts with dozens of pages: fuzzy-free
/// prefix/substring search over page names, arrow keys and Enter to open.
Future<void> showPageQuickSwitcher(
  BuildContext context,
  LayoutModelController controller,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _PageQuickSwitcherDialog(controller: controller);
    },
  );
}

class _PageQuickSwitcherDialog extends StatefulWidget {
  final LayoutModelController controller;
  const _PageQuickSwitcherDialog({required this.controller});

  @override
  State<_PageQuickSwitcherDialog> createState() =>
      _PageQuickSwitcherDialogState();
}

class _PageQuickSwitcherDialogState extends State<_PageQuickSwitcherDialog> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ComponentPage> pages = widget.controller.layoutModel.componentPages;
    final ComponentPage currentPage = widget.controller.currentComponentPage;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                FrameForgeStrings.quickSwitcherTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              RawAutocomplete<ComponentPage>(
                textEditingController: _textController,
                focusNode: _focusNode,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final String query = textEditingValue.text.toLowerCase().trim();
                  if (query.isEmpty) {
                    // Current page first, then the rest in order.
                    return <ComponentPage>[
                      currentPage,
                      ...pages.where((ComponentPage p) => p != currentPage),
                    ];
                  }
                  return pages.where((ComponentPage page) {
                    final String name =
                        (page['name'] ?? '').toString().toLowerCase();
                    return name.contains(query);
                  });
                },
                displayStringForOption: (ComponentPage option) =>
                    (option['name'] ?? '').toString(),
                onSelected: (ComponentPage page) {
                  widget.controller.switchPage(page);
                  Navigator.of(context).pop();
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: FrameForgeStrings.quickSwitcherHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (String _) => onFieldSubmitted(),
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<ComponentPage> onSelected,
                  Iterable<ComponentPage> options,
                ) {
                  if (options.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(FrameForgeStrings.quickSwitcherEmpty),
                    );
                  }
                  return Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ComponentPage page = options.elementAt(index);
                          final bool highlighted =
                              AutocompleteHighlightedOption.of(context) == index;
                          final bool isCurrent = page == currentPage;
                          return ListTile(
                            dense: true,
                            selected: highlighted,
                            leading: Icon(
                              isCurrent ? Icons.check_circle : Icons.crop_din,
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            title: Text(
                              (page['name'] ?? '').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(page),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}