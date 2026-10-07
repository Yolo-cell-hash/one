import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/space.dart';
import 'package:godrej_one_sdk/models/trail_device.dart';
import 'package:godrej_one_sdk/platform/adaptive.dart';
import 'package:godrej_one_sdk/screens/device_activity_screen.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/hold_to_unlock.dart';

const _brand = Color(0xFF810055);
const _onBorder = Color(0xFF8DFC63);
const _green = Color(0xFF22C55E);
const _gap = 10.0;

const _labelStyle = TextStyle(
  fontSize: 15,
  color: _brand,
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
);

/// The bottom half of a device's page, assembled from the device itself:
///
/// * a status card of its [SpaceDevice.stats];
/// * shortcut tiles — "Manage User" when it has users, "Activity Trail"
///   when it's linked to one, plus one that fits its [DeviceKind];
/// * the one primary control its kind calls for — hold-to-unlock for a
///   lock, a live view for cameras, an on/off switch (plus brightness for
///   lights) for everything else.
///
/// So a new device needs only data, not a new screen.
class DeviceControlPanel extends StatelessWidget {
  const DeviceControlPanel({super.key, required this.device});

  final SpaceDevice device;

  @override
  Widget build(BuildContext context) {
    final shortcuts = _shortcuts(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _gap,
      children: [
        _StatsCard(stats: device.stats),
        if (shortcuts.isNotEmpty)
          Row(
            spacing: _gap,
            children: [for (final s in shortcuts) Expanded(child: s)],
          ),
        ..._primaryControls(),
      ],
    );
  }

  List<Widget> _shortcuts(BuildContext context) {
    final trailId = device.trailDeviceId;
    final trailDevice = trailId == null
        ? null
        : demoTrailDevices.where((d) => d.id == trailId).firstOrNull;

    return [
      if (device.userCount > 0)
        _ShortcutTile(
          title: 'Manage User',
          onTap: () => showElegantToast(context, 'User management coming soon'),
          child: _AvatarStack(count: device.userCount),
        ),
      if (trailDevice != null)
        _ShortcutTile(
          title: 'Activity Trail',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DeviceActivityScreen(device: trailDevice),
            ),
          ),
          child: Icon(
            adaptiveIcon(context, Icons.access_time_filled),
            color: _brand,
            size: 24,
          ),
        ),
      if (device.userCount == 0 || trailDevice == null)
        switch (device.kind) {
          DeviceKind.camera || DeviceKind.doorbell => _ShortcutTile(
            title: 'Recordings',
            onTap: () => showElegantToast(context, 'Recordings coming soon'),
            child: Icon(
              adaptiveIcon(context, Icons.video_library),
              color: _brand,
              size: 24,
            ),
          ),
          DeviceKind.sensor => _ShortcutTile(
            title: 'Alerts',
            onTap: () => showElegantToast(context, 'Alerts coming soon'),
            child: Icon(
              adaptiveIcon(context, Icons.notifications_active),
              color: _brand,
              size: 24,
            ),
          ),
          DeviceKind.light || DeviceKind.appliance => _ShortcutTile(
            title: 'Schedule',
            onTap: () => showElegantToast(context, 'Schedules coming soon'),
            child: Icon(
              adaptiveIcon(context, Icons.schedule),
              color: _brand,
              size: 24,
            ),
          ),
          DeviceKind.lock => _ShortcutTile(
            title: 'Settings',
            onTap: () => showElegantToast(context, 'Lock settings coming soon'),
            child: Icon(
              adaptiveIcon(context, Icons.settings),
              color: _brand,
              size: 24,
            ),
          ),
        },
    ];
  }

  List<Widget> _primaryControls() {
    switch (device.kind) {
      case DeviceKind.lock:
        return [HoldToUnlock(target: _lockTarget(device.name))];
      case DeviceKind.camera:
      case DeviceKind.doorbell:
        return [_LiveView(title: device.name)];
      case DeviceKind.light:
        return [
          _TogglePill(
            key: ValueKey('${device.name}-power'),
            icon: Icons.power_settings_new,
            onTitle: '${device.name} · On',
            offTitle: '${device.name} · Off',
            onSubtitle: 'Tap to switch off',
            offSubtitle: 'Tap to switch on',
          ),
          const _BrightnessCard(),
        ];
      case DeviceKind.appliance:
        return [
          _TogglePill(
            key: ValueKey('${device.name}-power'),
            icon: Icons.power_settings_new,
            onTitle: '${device.name} · On',
            offTitle: '${device.name} · Off',
            onSubtitle: 'Tap to switch off',
            offSubtitle: 'Tap to switch on',
          ),
        ];
      case DeviceKind.sensor:
        return [
          _TogglePill(
            key: ValueKey('${device.name}-armed'),
            icon: Icons.shield_outlined,
            onIcon: Icons.shield,
            onTitle: '${device.name} · Armed',
            offTitle: '${device.name} · Disarmed',
            onSubtitle: 'You’ll be alerted on any trigger',
            offSubtitle: 'Tap to arm',
          ),
        ];
    }
  }

  /// "Main Door Lock" → "main door", for the unlock hint.
  static String _lockTarget(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith(' lock')
        ? lower.substring(0, lower.length - 5)
        : lower;
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final List<DeviceStat> stats;

  @override
  Widget build(BuildContext context) {
    return GlassyContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          for (final stat in stats)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stat.label, style: _labelStyle),
                  const SizedBox(height: 12),
                  Icon(
                    adaptiveIcon(context, stat.icon),
                    color: _brand,
                    size: 22,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (stat.dot != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: stat.dot,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: 9),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          stat.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _labelStyle,
                        ),
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

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassyContainer(
      height: 84,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _labelStyle),
          child,
        ],
      ),
    );
  }
}

/// "+3" chip followed by three overlapping avatars.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count});

  final int count;

  static const _faces = [
    'images/pfp1.png',
    'images/pfp2.png',
    'images/pfp3.png',
  ];
  static const _size = 28.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, _faces.length);
    final extra = count - shown;
    final items = <Widget>[
      if (extra > 0)
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _brand.withValues(alpha: 0.15)),
          ),
          child: Text(
            '+$extra',
            style: const TextStyle(
              fontSize: 12,
              color: _brand,
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      for (var i = 0; i < shown; i++)
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              _faces[i],
              package: 'godrej_one_sdk',
              fit: BoxFit.cover,
            ),
          ),
        ),
    ];

    return SizedBox(
      height: _size,
      width: _size + (items.length - 1) * (_size - _overlap),
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              width: _size,
              height: _size,
              child: items[i],
            ),
        ],
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return GlassyContainer(
      height: 150,
      width: double.infinity,
      title: title,
      subtitle: 'Live',
      subtitleIcon: Icons.circle,
      subtitleIconColor: const Color(0xFFEF4444),
      caption: 'Tap to expand',
      imageExists: true,
      imagePath: 'images/camera_dummy_img.png',
      mediaLayout: GlassyMediaLayout.panel,
      mediaWidthFactor: 0.58,
      onTap: () => showElegantToast(context, 'Full screen view coming soon'),
    );
  }
}

/// Glass pill with a round button on the left; tap anywhere to flip it.
/// The green outline marks "on", matching the rest of the app.
class _TogglePill extends StatefulWidget {
  const _TogglePill({
    super.key,
    required this.icon,
    this.onIcon,
    required this.onTitle,
    required this.offTitle,
    required this.onSubtitle,
    required this.offSubtitle,
  });

  final IconData icon;
  final IconData? onIcon;
  final String onTitle, offTitle, onSubtitle, offSubtitle;

  @override
  State<_TogglePill> createState() => _TogglePillState();
}

class _TogglePillState extends State<_TogglePill> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    const height = 76.0;
    const knob = height - 16;

    return GlassyContainer(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      borderExists: _on,
      borderColor: _onBorder,
      onTap: () => setState(() => _on = !_on),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: knob,
            height: knob,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _on ? _brand : Colors.white.withValues(alpha: 0.85),
            ),
            child: Icon(
              adaptiveIcon(
                context,
                _on ? (widget.onIcon ?? widget.icon) : widget.icon,
              ),
              color: _on ? Colors.white : _brand,
              size: knob * 0.4,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _on ? widget.onTitle : widget.offTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _brand,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _on ? widget.onSubtitle : widget.offSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontSize: 10,
                    color: _brand,
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _on ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                adaptiveIcon(context, Icons.check_circle),
                color: _green,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrightnessCard extends StatefulWidget {
  const _BrightnessCard();

  @override
  State<_BrightnessCard> createState() => _BrightnessCardState();
}

class _BrightnessCardState extends State<_BrightnessCard> {
  double _value = 0.7;

  @override
  Widget build(BuildContext context) {
    return GlassyContainer(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                adaptiveIcon(context, Icons.brightness_6_outlined),
                color: _brand,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Brightness', style: _labelStyle)),
              Text('${(_value * 100).round()}%', style: _labelStyle),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _brand,
              inactiveTrackColor: _brand.withValues(alpha: 0.15),
              thumbColor: _brand,
              overlayColor: _brand.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            // CupertinoSlider on iOS (white thumb, brand track via the
            // Cupertino theme); the themed Material slider on Android.
            child: Slider.adaptive(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
        ],
      ),
    );
  }
}
