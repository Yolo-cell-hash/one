import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/space.dart';
import 'package:godrej_one_sdk/platform/adaptive.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/device_control_panel.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/greeting_header.dart';

const _brand = Color(0xFF810055);
const _onBorder = Color(0xFF8DFC63);
const _onlineDot = Color(0xFF3FBF3F);
const _offlineDot = Color(0xFFBDBDBD);

/// One room's page: its photo full-bleed behind everything, the room's name
/// and device count, a master switch, and a swipeable row of its devices.
/// Tapping a device swaps the bottom half for its [DeviceControlPanel]
/// while the photo and header stay put.
///
/// Pushed onto the My Spaces tab's own navigator, so the shell's bottom bar
/// stays in place above it.
class SpaceDetailScreen extends StatefulWidget {
  const SpaceDetailScreen({
    super.key,
    required this.space,
    required this.name,
    required this.asset,
    this.initialDevice,
  });

  final Space space;

  /// User's name and avatar, for the header.
  final String name, asset;

  /// Opens straight onto this device's controls (deep links from Home).
  final SpaceDevice? initialDevice;

  /// Pushes [spaceId]'s page onto the nearest navigator — in a tab, that's
  /// the tab's own, so it opens over the current tab and back returns to
  /// it. With [deviceName], opens straight onto that device's controls.
  static void open(
    BuildContext context, {
    required String spaceId,
    String? deviceName,
    required String name,
    required String asset,
  }) {
    final space = demoSpaces.where((s) => s.id == spaceId).firstOrNull;
    if (space == null) return;
    final device = space.devices.where((d) => d.name == deviceName).firstOrNull;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SpaceDetailScreen(
          space: space,
          name: name,
          asset: asset,
          initialDevice: device,
        ),
      ),
    );
  }

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  bool _isOn = true;

  /// The device whose controls are showing; `null` shows the room
  /// overview.
  late SpaceDevice? _device = widget.initialDevice;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the device row always
    // sits just above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final cardHeight = (w * 0.3).clamp(108.0, 130.0);

    final space = widget.space;
    final count = space.devices.length;
    final device = _device;

    // Back (button or gesture) first closes an open device, then leaves
    // the room.
    return PopScope(
      // Opened straight onto a device (from Home)? Back returns there,
      // rather than stepping through the room overview first.
      canPop: device == null || device == widget.initialDevice,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _device = null);
      },
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              space.image,
              package: 'godrej_one_sdk',
              fit: BoxFit.cover,
            ),
            // Soft scrims so the white header and room name stay legible on
            // bright photos.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x59000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x4D000000),
                  ],
                  stops: [0, 0.22, 0.55, 0.85],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(
                  name: widget.name,
                  asset: widget.asset,
                  subtitle: 'Your space',
                  trailing: Row(
                    children: [
                      _HeaderButton(
                        image: 'images/camera_landing_icon.png',
                        onTap: () =>
                            showElegantToast(context, 'Cameras coming soon'),
                      ),
                      const SizedBox(width: 14),
                      _HeaderButton(
                        image: 'images/chevron.png',
                        // Android's vertical overflow dots on a round disc; a
                        // quarter turn gives iOS its horizontal ellipsis.
                        quarterTurns: isCupertino(context) ? 1 : 0,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Same backdrop and header either way — only this part swaps
                // between the room overview and the selected device's controls.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.bottomCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: device == null
                      ? Column(
                          key: const ValueKey('overview'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          space.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            color: Colors.white,
                                            fontFamily: 'GEG',
                                            package: 'godrej_one_sdk',
                                            fontWeight: FontWeight.w700,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black38,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$count ${count == 1 ? 'device' : 'devices'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontFamily: 'GEG',
                                            package: 'godrej_one_sdk',
                                            shadows: [
                                              Shadow(
                                                color: Colors.black38,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Sits level with the room name, as in the design.
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: _SpaceToggle(
                                      value: _isOn,
                                      onChanged: (value) =>
                                          setState(() => _isOn = value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: cardHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                // Room for the cards' soft shadows.
                                clipBehavior: Clip.none,
                                itemCount: count + 1,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, i) => i == 0
                                    ? _AddDeviceCard(height: cardHeight)
                                    : _DeviceCard(
                                        device: space.devices[i - 1],
                                        height: cardHeight,
                                        width: cardHeight * 1.26,
                                        isOn: _isOn,
                                        onTap: () => setState(
                                          () => _device = space.devices[i - 1],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          key: ValueKey(device),
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: DeviceControlPanel(device: device),
                        ),
                ),
                SizedBox(height: barHeight + media.padding.bottom + gap * 1.5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.image,
    required this.onTap,
    this.quarterTurns = 0,
  });

  final String image;
  final VoidCallback onTap;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: Image.asset(
          image,
          package: 'godrej_one_sdk',
          width: 34,
          height: 34,
        ),
      ),
    );
  }
}

class _AddDeviceCard extends StatelessWidget {
  const _AddDeviceCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GlassyContainer(
      width: height * 0.55,
      height: height,
      padding: EdgeInsets.zero,
      onTap: () => showElegantToast(context, 'Adding devices coming soon'),
      child: Center(
        child: Icon(adaptiveIcon(context, Icons.add), size: 30, color: _brand),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.height,
    required this.width,
    required this.isOn,
    required this.onTap,
  });

  final SpaceDevice device;
  final double height, width;
  final VoidCallback onTap;

  /// The room's master switch — off greys every status dot and drops the
  /// green highlight.
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final image = device.image;

    return GlassyContainer(
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      borderExists: isOn && device.highlighted,
      borderColor: _onBorder,
      onTap: onTap,
      child: Stack(
        children: [
          if (image != null)
            Positioned.fill(
              child: Align(
                alignment: device.imageAlignment,
                child: FractionallySizedBox(
                  widthFactor: device.imageWidthFactor,
                  heightFactor: device.imageHeightFactor,
                  child: Image.asset(
                    image,
                    package: 'godrej_one_sdk',
                    fit: BoxFit.contain,
                    alignment: device.imageAlignment,
                  ),
                ),
              ),
            )
          else
            Positioned(
              right: 14,
              bottom: 14,
              child: Icon(
                adaptiveIcon(context, device.icon!),
                size: 38,
                color: _brand.withValues(alpha: isOn ? 1 : 0.4),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.2,
                    color: _brand,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOn ? _onlineDot : _offlineDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pill switch in the app's "active = green outline" language
/// (same as the AI-mode toggle on Customize): white track, brand-colored
/// thumb, and only the border changes color.
class _SpaceToggle extends StatelessWidget {
  const _SpaceToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // The system switch on iOS; its green "on" track matches the app's
    // "active = green" language.
    if (isCupertino(context)) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 40,
        height: 22,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? _onBorder : const Color(0xFFD9D9D9),
            width: value ? 2 : 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: const DecoratedBox(
            decoration: BoxDecoration(color: _brand, shape: BoxShape.circle),
            child: SizedBox(width: 14, height: 14),
          ),
        ),
      ),
    );
  }
}
