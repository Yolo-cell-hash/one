import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/trail_device.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';
import 'package:godrej_one_sdk/widgets/search_bar_widget.dart';

/// A searchable, chip-filtered list of devices under a page title — the
/// Activity Trail device picker and the "Godrej Devices" pairing list.
/// What tapping a device does is up to the caller.
class DeviceCatalogPage extends StatefulWidget {
  const DeviceCatalogPage({
    super.key,
    required this.title,
    required this.onDeviceTap,
  });

  final String title;
  final void Function(BuildContext context, TrailDevice device) onDeviceTap;

  @override
  State<DeviceCatalogPage> createState() => _DeviceCatalogPageState();
}

class _DeviceCatalogPageState extends State<DeviceCatalogPage> {
  String _query = '';

  /// `null` is the "All" chip.
  DeviceCategory? _category;

  void _openDevice(TrailDevice device) {
    FocusScope.of(context).unfocus();
    widget.onDeviceTap(context, device);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formula HomeShell uses for its bar, so the last row always
    // scrolls clear of it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    final devices = [
      for (final device in demoTrailDevices)
        if ((_category == null || device.category == _category) &&
            device.matches(_query))
          device,
    ];

    // Material rather than a ColoredBox: it's the opaque backdrop during
    // page transitions *and* the surface the tiles' ink splashes draw on.
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          ScreenHeader(title: widget.title),
          const SizedBox(height: 25.0),
          SearchBarWidget(
            labelText: 'Search Devices',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 22.0),
          _CategoryChips(
            selected: _category,
            onSelected: (category) => setState(() => _category = category),
          ),
          const SizedBox(height: 18.0),
          Expanded(
            child: devices.isEmpty
                ? const _NoDevices()
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: barHeight + media.padding.bottom + gap * 2,
                    ),
                    itemCount: devices.length,
                    itemBuilder: (context, i) => _DeviceTile(
                      device: devices[i],
                      onTap: () => _openDevice(devices[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrolling pill filters: "All", then one per
/// [DeviceCategory].
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final DeviceCategory? selected;
  final ValueChanged<DeviceCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        spacing: 12,
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in DeviceCategory.values)
            _Chip(
              label: category.label,
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _brand = Color(0xFF810055);
  static const _border = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _brand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _brand : _border),
        ),
        // Text color animates in step with the fill — switching it
        // instantly flashes white-on-white while the fill fades in.
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 16,
            color: selected ? Colors.white : Colors.black,
            fontFamily: 'GEG',
            package: 'godrej_one_sdk',
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onTap});

  final TrailDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        child: Row(
          children: [
            // Fixed slot so every name lines up, whatever the product
            // shot's proportions.
            SizedBox(
              width: 32,
              height: 46,
              child: Image.asset(
                device.image,
                package: 'godrej_one_sdk',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'GEG',
                      package: 'godrej_one_sdk',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E8E),
                      fontFamily: 'GEG',
                      package: 'godrej_one_sdk',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDevices extends StatelessWidget {
  const _NoDevices();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          'No devices found',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8E8E8E),
            fontFamily: 'GEG',
            package: 'godrej_one_sdk',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
