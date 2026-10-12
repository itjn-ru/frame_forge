import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';

class MaketPageComponentsColumn extends StatefulWidget {
  final LayoutModelController controller;
  const MaketPageComponentsColumn(this.controller, {super.key});

  @override
  State<MaketPageComponentsColumn> createState() =>
      _MaketPageComponentsColumnState();
}

class _MaketPageComponentsColumnState extends State<MaketPageComponentsColumn>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            onTap: (value) {
              switch (value) {
                case 0:
                  // Return selection to the current component page so the
                  // canvas shows components, not the previously open tab.
                  widget.controller
                      .switchPage(widget.controller.currentComponentPage);
                  break;
                case 1:
                  widget.controller.layoutModel.curPageType = SourcePage;
                  break;
                case 2:
                  widget.controller.layoutModel.curPageType = StylePage;
                  break;
              }
              setState(() {});
            },
            tabs: [
              TabWidget(text: 'Pages', active: _tabController.index == 0),
              TabWidget(text: 'Data', active: _tabController.index == 1),
              TabWidget(text: 'Styles', active: _tabController.index == 2),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pages tab: master-detail. The master is a searchable,
                // virtualized list of pages (PageList); the detail is the
                // component tree of the currently open page only. This
                // keeps the panel usable with dozens of pages.
                Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: PageList(widget.controller,
                          showSearchBar: true, showQuickSwitcher: false),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      flex: 4,
                      child: ValueListenableBuilder<String?>(
                        valueListenable: widget.controller.selectedIdNotifier,
                        builder: (BuildContext context, String? _, __) {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              Items(
                                widget.controller.currentComponentPage,
                                widget.controller,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    Items(
                      widget.controller.layoutModel.root.items
                          .whereType<SourcePage>()
                          .first,
                      widget.controller,
                    ),
                  ],
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    Items(
                      widget.controller.layoutModel.root.items
                          .whereType<StylePage>()
                          .first,
                      widget.controller,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabWidget extends StatelessWidget {
  final String text;
  final bool active;
  const TabWidget({super.key, required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: active ? Colors.black : Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
          child: Text(text),
        ),
      ),
    );
  }
}
