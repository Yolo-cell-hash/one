import 'package:flutter/material.dart';

/// A single bottom-tab's identity: an id, its glyph, and its tooltip.
///
/// No [VoidCallback] here — this is plain data, so it can live inside a
/// [ChangeNotifier] and be read from anywhere in the app. Whoever actually
/// renders the bar (today, `HomeShell`) turns each spec into a
/// `BottomBarItem` and attaches the tap behavior.
class BottomBarItemSpec {
  const BottomBarItemSpec.icon(this.id, this.icon, {required this.tooltip})
    : assetPath = null;

  const BottomBarItemSpec.asset(
    this.id,
    this.assetPath, {
    required this.tooltip,
  }) : icon = null;

  final String id;
  final IconData? icon;
  final String? assetPath;
  final String tooltip;
}

/// The single source of truth for the app's bottom tabs: their ids, icons,
/// order, and which one is currently selected.
///
/// The item list is populated right here, at construction — via
/// [MultiProvider] in `main.dart` — so it (and the selected tab) are
/// available anywhere via `context.watch<BottomBarProvider>()` from the
/// moment the app starts. Nothing has to wait for `HomeShell` to mount, and
/// there is exactly one place these ids are declared, so a screen's icon
/// and its provider id can never drift apart.
class BottomBarProvider extends ChangeNotifier {
  BottomBarProvider({List<BottomBarItemSpec>? items})
    : _items = items ?? defaultItems;

  static const List<BottomBarItemSpec> defaultItems = [
    BottomBarItemSpec.icon('home', Icons.home_filled, tooltip: 'Home'),
    BottomBarItemSpec.icon(
      'activity_trails',
      Icons.access_time_filled,
      tooltip: 'Activity Trails',
    ),
    BottomBarItemSpec.icon(
      'devices',
      Icons.workspaces_filled,
      tooltip: 'Add Devices',
    ),
    BottomBarItemSpec.asset(
      'my_space',
      'images/svgs/spaces.svg',
      tooltip: 'My Spaces',
    ),
    BottomBarItemSpec.icon('customize', Icons.add, tooltip: 'Customize'),
  ];

  final List<BottomBarItemSpec> _items;
  int _selectedIndex = 0;

  List<BottomBarItemSpec> get items => List.unmodifiable(_items);
  int get selectedIndex => _selectedIndex;
  String get selectedId => _items[_selectedIndex].id;

  String? idAt(int index) =>
      index >= 0 && index < _items.length ? _items[index].id : null;

  int? indexOfId(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    return index == -1 ? null : index;
  }

  /// Switches the active tab. Safe to call from anywhere — a menu, a deep
  /// link handler, another tab's "go to Devices" button — not just the bar
  /// itself.
  void select(int index) {
    if (index < 0 || index >= _items.length || index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  void selectById(String id) {
    final index = indexOfId(id);
    if (index != null) select(index);
  }
}
