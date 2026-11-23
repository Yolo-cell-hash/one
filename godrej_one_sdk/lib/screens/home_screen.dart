import 'dart:ui' show ImageFilter;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/home_device.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/screens/property_screen.dart';
import 'package:godrej_one_sdk/screens/space_detail_screen.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _brand = Color(0xFF810055);
const _card = Color(0xFFF5F5F5);
const _sheet = Color(0xFFFAFAFA);
const _online = Color(0xFF2FC52F);
const _warning = Color(0xFFF2CB2E);
const _offline = Color(0xFFEF4444);
const _notifyAmber = Color(0xFFE99A07);
const _removeRed = Color(0xFFFF3B30);
const _headerButton = Color(0xFFE9C4DC);

const _text = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
);

/// The Home tab: a greeting on the brand header, then a white sheet with the
/// home's status and a card per device. Tapping a device opens its product
/// page; long-pressing it offers to hide, rename or remove it, and — for a
/// device that needs attention — to show its notification.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.openVdbOnStart = false});

  /// Opens the Video Door Bell over Home right away, so back lands on Home.
  final bool openVdbOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Devices removed with "Remove Device" this session.
  final _removed = <String>{};

  final _list = ScrollController();
  final _banner = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.openVdbOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SpaceDetailScreen.open(
          context,
          spaceId: 'entrance',
          deviceName: 'VDB',
          animate: false,
        );
      });
    }
  }

  @override
  void dispose() {
    _list.dispose();
    _banner.dispose();
    super.dispose();
  }

  /// Every device still on the account, under the name the resident gave it.
  List<HomeDevice> _devices(ProfileStore store) => [
    for (final device in HomeDevice.demo)
      if (!_removed.contains(device.id))
        device.renamed(store.deviceName(device.id) ?? device.name),
  ];

  /// The banner's pages: the home's status, then one per device that needs
  /// attention.
  List<_BannerPage> _bannerPages(List<HomeDevice> devices) => [
    const _BannerPage(
      'Security system is armed away. All doors are locked. All gates are '
      'closed.',
      activeRingColor,
    ),
    const _BannerPage(
      'Energy usage today is 24.6 kWh, 8% lower than yesterday.',
      activeRingColor,
    ),
    for (final device in devices)
      if (device.health != DeviceHealth.ok)
        _BannerPage(
          device.alertFor(device.name),
          _healthColor(device.health),
          deviceId: device.id,
        ),
  ];

  /// Taps on cards that don't open a page: offline devices, and those whose
  /// page isn't built yet.
  void _onCardTap(HomeDevice device) => showElegantToast(
    context,
    device.health == DeviceHealth.offline
        ? '${device.name} is offline'
        : '${device.name} coming soon',
  );

  Future<void> _showActions(HomeDevice device, GlobalKey cardKey) async {
    final box = cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    HapticFeedback.mediumImpact();
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final action = await Navigator.of(
      context,
      rootNavigator: true,
    ).push(_DeviceActionsRoute(device: device, cardRect: rect));
    if (!mounted || action == null) return;
    switch (action) {
      case _DeviceAction.hide:
        await _hide(device);
      case _DeviceAction.edit:
        await _rename(device);
      case _DeviceAction.notifications:
        await _showNotification(device);
      case _DeviceAction.remove:
        await _remove(device);
    }
  }

  Future<void> _hide(HomeDevice device) async {
    final hide = await _showHomeDialog<bool>(
      context,
      _ConfirmCard(
        icon: Icons.visibility_off_outlined,
        title: 'Hide ${device.name}?',
        message: device.page != null
            ? '${device.name} will be hidden from your Home screen. You can '
                  'still open it from Spaces, on its product page.'
            : '${device.name} will be hidden from your Home screen.',
        confirmLabel: 'Hide',
      ),
    );
    if (hide != true || !mounted) return;
    context.read<ProfileStore>().hideDevice(device.id);
    showElegantToast(context, '${device.name} hidden from Home');
  }

  Future<void> _rename(HomeDevice device) async {
    final name = await _showHomeDialog<String>(
      context,
      _RenameCard(name: device.name),
    );
    if (name == null || name == device.name || !mounted) return;
    context.read<ProfileStore>().renameDevice(device.id, name);
    showElegantToast(context, 'Renamed to $name');
  }

  Future<void> _remove(HomeDevice device) async {
    final remove = await _showHomeDialog<bool>(
      context,
      _ConfirmCard(
        icon: Icons.warning_rounded,
        title: 'Remove ${device.name}?',
        message:
            'This will deboard ${device.name} and erase all of its device '
            'data and memory, including its users, history and settings. '
            "This can't be undone.",
        confirmLabel: 'Remove',
        destructive: true,
      ),
    );
    if (remove != true || !mounted) return;
    setState(() => _removed.add(device.id));
    showElegantToast(context, '${device.name} removed');
  }

  /// Brings the banner into view and slides it to [device]'s notification.
  Future<void> _showNotification(HomeDevice device) async {
    final pages = _bannerPages(_devices(context.read<ProfileStore>()));
    final page = pages.indexWhere((p) => p.deviceId == device.id);
    if (page < 0) return;
    if (_list.hasClients && _list.offset > 0) {
      await _list.animateTo(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted || !_banner.hasClients) return;
    await _banner.animateToPage(
      page,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    final store = context.watch<ProfileStore>();
    final devices = _devices(store);
    final shown = [
      for (final device in devices)
        if (!store.isHidden(device.id)) device,
    ];

    return ColoredBox(
      color: _brand,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, media.padding.top + 26, 20, 26),
            child: const _Header(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: ColoredBox(
                // Not pure white, so the cards' shadows read against it.
                color: _sheet,
                child: ListView(
                  controller: _list,
                  padding: EdgeInsets.fromLTRB(
                    17,
                    18,
                    17,
                    barHeight + media.padding.bottom + gap * 2,
                  ),
                  children: [
                    _StatusBanner(
                      pages: _bannerPages(devices),
                      controller: _banner,
                    ),
                    const SizedBox(height: 18),
                    _DeviceGrid(
                      devices: shown,
                      onTap: _onCardTap,
                      onLongPress: _showActions,
                    ),
                    if (store.hiddenCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Center(
                          child: TextButton(
                            onPressed: store.showHiddenDevices,
                            style: TextButton.styleFrom(
                              foregroundColor: _brand,
                            ),
                            child: Text(
                              'Show hidden devices (${store.hiddenCount})',
                              style: _text.copyWith(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _healthColor(DeviceHealth health) => switch (health) {
  DeviceHealth.ok => _online,
  DeviceHealth.warning => _warning,
  DeviceHealth.offline => _offline,
};

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProfileStore>();
    final city = store.property.location.split(',').last.trim();
    return Row(
      children: [
        const ProfileAvatar(size: 48),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey ${store.user.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text.copyWith(fontSize: 19, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                '$city Home',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text.copyWith(fontSize: 13.5, color: Colors.white),
              ),
            ],
          ),
        ),
        _HeaderButton(
          label: 'Properties',
          icon: Icons.home_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PropertyScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _HeaderButton(
          label: 'More',
          icon: Icons.more_vert_rounded,
          onTap: () => showElegantToast(context, 'Coming soon'),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _headerButton,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _brand, size: 20),
        ),
      ),
    );
  }
}

/// One page of the Home banner: a message in a pill outlined in [color].
class _BannerPage {
  const _BannerPage(this.text, this.color, {this.deviceId});

  final String text;
  final Color color;

  /// The device the message is about, for a device's notification.
  final String? deviceId;
}

/// The home's status and devices' notifications, one a page, with dots
/// under them.
class _StatusBanner extends StatefulWidget {
  const _StatusBanner({required this.pages, required this.controller});

  final List<_BannerPage> pages;
  final PageController controller;

  @override
  State<_StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<_StatusBanner> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    return Column(
      children: [
        SizedBox(
          height: 66,
          child: PageView.builder(
            controller: widget.controller,
            itemCount: pages.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(33),
                border: Border.all(color: pages[i].color, width: 1.4),
              ),
              child: Text(
                pages[i].text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _text.copyWith(fontSize: 12.3, height: 1.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? _brand : const Color(0xFFD0D0D0),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Two columns of device cards, then "Add Devices" and "Add Widgets".
class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid({
    required this.devices,
    required this.onTap,
    required this.onLongPress,
  });

  final List<HomeDevice> devices;
  final ValueChanged<HomeDevice> onTap;
  final void Function(HomeDevice, GlobalKey) onLongPress;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final device in devices)
        _DeviceCard(
          key: ValueKey(device.id),
          device: device,
          onTap: () => onTap(device),
          onLongPress: onLongPress,
        ),
      _AddCard(
        title: 'Add Devices',
        icon: Icons.workspaces_filled,
        onTap: () => context.read<BottomBarProvider>().selectById('devices'),
      ),
      _AddCard(
        title: 'Add Widgets',
        icon: Icons.dashboard_customize_rounded,
        onTap: () => showElegantToast(context, 'More widgets coming soon'),
      ),
    ];
    return Column(
      spacing: 19,
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Row(
            spacing: 13,
            children: [
              Expanded(child: tiles[i]),
              Expanded(
                child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox(),
              ),
            ],
          ),
      ],
    );
  }
}

const _tileRadius = 26.0;

/// The soft grey card all Home tiles share: its [_TileShadow] and
/// [_TileSurface] together.
class _Tile extends StatelessWidget {
  const _Tile({required this.child, this.color = _card, this.lifted = false});

  final Widget child;
  final Color color;

  /// A stronger shadow, for the card raised over the long-press menu.
  final bool lifted;

  static const height = 114.0;

  @override
  Widget build(BuildContext context) {
    return _TileShadow(
      lifted: lifted,
      child: _TileSurface(color: color, child: child),
    );
  }
}

/// The card's glass face: a white rim and a fill that brightens toward the
/// bottom edge.
class _TileSurface extends StatelessWidget {
  const _TileSurface({required this.child, this.color = _card});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _Tile.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_tileRadius),
        border: Border.all(color: Colors.white, width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color, Color.lerp(color, Colors.white, 0.6)!],
          stops: const [0, 0.82, 1],
        ),
      ),
      child: child,
    );
  }
}

/// The card's shadow, kept apart from its face so a card that grows into
/// its page can be clipped without clipping the shadow away.
class _TileShadow extends StatelessWidget {
  const _TileShadow({super.key, required this.child, this.lifted = false});

  final Widget child;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_tileRadius),
        // Fitted to the design's measured shadow: dark right under the
        // card, a soft grey band below it, and little to the sides.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.12 : 0.08),
            blurRadius: lifted ? 12 : 8,
            spreadRadius: -1,
            offset: Offset(0, lifted ? 6 : 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.16 : 0.11),
            blurRadius: lifted ? 32 : 24,
            spreadRadius: -8,
            offset: Offset(0, lifted ? 22 : 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DeviceCard extends StatefulWidget {
  const _DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onLongPress,
  });

  final HomeDevice device;
  final VoidCallback onTap;
  final void Function(HomeDevice, GlobalKey) onLongPress;

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    // An offline device can't be opened; its card says so instead.
    final page = device.health == DeviceHealth.offline ? null : device.page;
    final face = _TileSurface(child: DeviceCardContent(device: device));

    return Semantics(
      button: true,
      label: '${device.name}, ${device.location}',
      onLongPressHint: 'Device options',
      excludeSemantics: true,
      child: _TileShadow(
        key: _key,
        child: page == null
            ? GestureDetector(
                onTap: widget.onTap,
                onLongPress: () => widget.onLongPress(device, _key),
                child: face,
              )
            // The card grows into its product page, and back shrinks the
            // page into the card again.
            : OpenContainer<void>(
                tappable: false,
                transitionType: ContainerTransitionType.fade,
                transitionDuration: const Duration(milliseconds: 480),
                closedElevation: 0,
                openElevation: 0,
                closedColor: _card,
                openColor: _card,
                closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(_tileRadius)),
                ),
                closedBuilder: (_, open) => GestureDetector(
                  onTap: open,
                  onLongPress: () => widget.onLongPress(device, _key),
                  child: face,
                ),
                openBuilder: (_, _) => SpaceDetailScreen.forDevice(
                  spaceId: page.spaceId,
                  deviceName: page.deviceName,
                )!,
              ),
      ),
    );
  }
}

/// A device card's name, location, status dot and product shot.
class DeviceCardContent extends StatelessWidget {
  const DeviceCardContent({super.key, required this.device});

  final HomeDevice device;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: device.imageTop,
          right: device.imageRight,
          height: device.imageHeight,
          child: Image.asset(
            device.image,
            package: 'godrej_one_sdk',
            fit: BoxFit.fitHeight,
          ),
        ),
        Positioned(
          left: 14,
          top: 16,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text.copyWith(fontSize: 15.5),
              ),
              const SizedBox(height: 4),
              Text(
                device.location,
                style: _text.copyWith(fontSize: 11, height: 1.2),
              ),
            ],
          ),
        ),
        Positioned(
          left: 14,
          bottom: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _healthColor(device.health),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: _Tile(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 16, 13, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _text.copyWith(fontSize: 15.5)),
                const Spacer(),
                Icon(icon, color: _brand, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ long-press menu

enum _DeviceAction { hide, edit, notifications, remove }

/// The long-press menu's rows for [device]: Notifications only for a device
/// that needs attention.
List<_DeviceAction> _actionsFor(HomeDevice device) => [
  _DeviceAction.hide,
  _DeviceAction.edit,
  if (device.health != DeviceHealth.ok) _DeviceAction.notifications,
  _DeviceAction.remove,
];

const _menuRowHeight = 35.0;
const _menuWidth = 186.0;

/// Dims everything, lifts the pressed card in place, and opens a frosted
/// menu beside it. Pops the chosen [_DeviceAction], or null.
class _DeviceActionsRoute extends PopupRoute<_DeviceAction> {
  _DeviceActionsRoute({required this.device, required this.cardRect});

  final HomeDevice device;
  final Rect cardRect;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.36);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Close menu';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    final actions = _actionsFor(device);
    final menuHeight = actions.length * _menuRowHeight + actions.length + 1;
    const overlap = 15.0;

    // Beside the card, toward the screen's middle; above it if there's
    // room, else below.
    final onLeft = cardRect.center.dx < size.width / 2;
    final left = onLeft
        ? cardRect.right - overlap
        : cardRect.left + overlap - _menuWidth;
    final above = cardRect.top - 3 - menuHeight > top + 8;
    final menuTop = above ? cardRect.top - 3 - menuHeight : cardRect.bottom + 3;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return Stack(
      children: [
        Positioned.fromRect(
          rect: cardRect,
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.03).animate(curved),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              // An overlay route has no Material of its own for text to
              // take its defaults from.
              child: Material(
                type: MaterialType.transparency,
                child: _Tile(
                  color: const Color(0xFFF8F8F8),
                  lifted: true,
                  child: DeviceCardContent(device: device),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: left.clamp(8.0, size.width - _menuWidth - 8),
          top: menuTop,
          width: _menuWidth,
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(curved),
              alignment: Alignment(onLeft ? -1 : 1, above ? 1 : -1),
              child: _ActionMenu(
                device: device,
                actions: actions,
                onSelect: (action) => Navigator.of(context).pop(action),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.device,
    required this.actions,
    required this.onSelect,
  });

  final HomeDevice device;
  final List<_DeviceAction> actions;
  final ValueChanged<_DeviceAction> onSelect;

  _MenuItem _item(_DeviceAction action) {
    final notifyColor = device.health == DeviceHealth.offline
        ? _offline
        : _notifyAmber;
    return switch (action) {
      _DeviceAction.hide => _MenuItem(
        leading: const Icon(Icons.visibility_off_rounded, size: 17),
        label: 'Hide Device',
        onTap: () => onSelect(action),
      ),
      _DeviceAction.edit => _MenuItem(
        leading: const _EditGlyph(),
        label: 'Edit Device',
        onTap: () => onSelect(action),
      ),
      _DeviceAction.notifications => _MenuItem(
        leading: SvgPicture.asset(
          'images/svgs/notification.svg',
          package: 'godrej_one_sdk',
          width: 16,
          colorFilter: ColorFilter.mode(notifyColor, BlendMode.srcIn),
        ),
        label: 'Notifications',
        color: notifyColor,
        onTap: () => onSelect(action),
      ),
      _DeviceAction.remove => _MenuItem(
        leading: const Icon(Icons.remove_circle, size: 17),
        label: 'Remove Device',
        color: _removeRed,
        onTap: () => onSelect(action),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final divider = Container(
      height: 1,
      margin: const EdgeInsets.only(left: 40, right: 28),
      color: Colors.white.withValues(alpha: 0.85),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, action) in actions.indexed) ...[
                  if (i > 0) divider,
                  _item(action),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A pencil cut out of a white disc — the design's "Edit" glyph.
class _EditGlyph extends StatelessWidget {
  const _EditGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3),
        ],
      ),
      child: const Icon(Icons.edit_rounded, size: 10, color: Color(0xFFB5B5B5)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.leading,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final Widget leading;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shadow = [
      Shadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 4),
    ];
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _menuRowHeight,
        child: Row(
          children: [
            const SizedBox(width: 14),
            IconTheme(
              data: IconThemeData(color: color, shadows: shadow),
              child: SizedBox(width: 18, child: Center(child: leading)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: _text.copyWith(
                  fontSize: 12.5,
                  color: color,
                  shadows: shadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ dialogs

/// Shows [card] centred over a softly blurred Home; resolves to what the
/// card pops.
Future<T?> _showHomeDialog<T>(BuildContext context, Widget card) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: card,
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The two buttons at a dialog's foot: Cancel, then [confirmLabel].
class _DialogButtons extends StatelessWidget {
  const _DialogButtons({
    required this.confirmLabel,
    required this.onConfirm,
    this.destructive = false,
  });

  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? _removeRed : _brand;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 18,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: _brand,
            side: const BorderSide(color: _brand),
            shape: const StadiumBorder(),
            minimumSize: const Size(110, 40),
          ),
          child: Text('Cancel', style: _text.copyWith(fontSize: 15)),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            minimumSize: const Size(110, 40),
          ),
          child: Text(
            confirmLabel,
            style: _text.copyWith(fontSize: 15, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// A confirmation: soft (brand) for reversible actions, or [destructive]
/// (red) for ones that can't be undone. Pops `true` to go ahead.
class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? _removeRed : _brand;
    return SoftCard(
      radius: 30,
      color: const Color(0xFFF7F7F7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: destructive ? 0.12 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _text.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: destructive ? _removeRed : _brand,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: _text.copyWith(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 20),
            _DialogButtons(
              confirmLabel: confirmLabel,
              destructive: destructive,
              onConfirm: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rename a device. Pops the new name, or null.
class _RenameCard extends StatefulWidget {
  const _RenameCard({required this.name});

  final String name;

  @override
  State<_RenameCard> createState() => _RenameCardState();
}

class _RenameCardState extends State<_RenameCard> {
  late final _controller = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      showElegantToast(context, 'Enter a name for the device');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 30,
      color: const Color(0xFFF7F7F7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Device',
              style: _text.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            OutlinedField(
              label: 'Device name',
              controller: _controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            _DialogButtons(confirmLabel: 'Save', onConfirm: _save),
          ],
        ),
      ),
    );
  }
}
