import 'package:flutter/material.dart';

const _green = Color(0xFF3FBF3F);
const _red = Color(0xFFEF4444);
const _amber = Color(0xFFF5A524);

/// What a device is, which decides the controls on its page: a lock gets
/// hold-to-unlock and user management, cameras get a live view, lights a
/// power switch and brightness, and so on.
enum DeviceKind { lock, doorbell, camera, light, appliance, sensor }

/// One reading in a device page's status card — "Battery · Critical".
class DeviceStat {
  const DeviceStat({
    required this.label,
    required this.icon,
    required this.value,
    this.dot,
  });

  final String label;
  final IconData icon;
  final String value;

  /// Status dot before [value]; none when null.
  final Color? dot;
}

/// A device shown on a space's page.
class SpaceDevice {
  const SpaceDevice({
    required this.name,
    required this.kind,
    this.image,
    this.icon,
    this.imageAlignment = Alignment.centerRight,
    this.imageWidthFactor = 0.4,
    this.imageHeightFactor = 0.75,
    this.highlighted = false,
    List<DeviceStat>? stats,
    this.trailDeviceId,
    this.userCount = 0,
  }) : assert(image != null || icon != null),
       customStats = stats;

  final String name;
  final DeviceKind kind;

  /// Product shot, drawn on the card's right side…
  final String? image;
  final Alignment imageAlignment;
  final double imageWidthFactor;
  final double imageHeightFactor;

  /// …or, for devices without one, a glyph.
  final IconData? icon;

  /// Draws the green "active" outline (e.g. a locked door).
  final bool highlighted;

  /// Id of the matching device in Activity Trail; shows the "Activity
  /// Trail" shortcut on the device page when set.
  final String? trailDeviceId;

  /// People with access (locks); shows "Manage User" when non-zero.
  final int userCount;

  /// Readings specific to this device; `null` uses [kind]'s defaults.
  final List<DeviceStat>? customStats;

  /// The status card's readings — [customStats], or sensible defaults for
  /// the device's [kind].
  List<DeviceStat> get stats => customStats ?? _defaultStats[kind]!;

  static const Map<DeviceKind, List<DeviceStat>> _defaultStats = {
    DeviceKind.lock: [
      DeviceStat(
        label: 'Door',
        icon: Icons.door_front_door_outlined,
        value: 'Closed',
        dot: _green,
      ),
      DeviceStat(
        label: 'Battery',
        icon: Icons.battery_charging_full_outlined,
        value: 'Good',
        dot: _green,
      ),
      DeviceStat(label: 'Status', icon: Icons.bluetooth, value: 'BLE'),
    ],
    DeviceKind.doorbell: [
      DeviceStat(
        label: 'Status',
        icon: Icons.wifi,
        value: 'Online',
        dot: _green,
      ),
      DeviceStat(
        label: 'Battery',
        icon: Icons.battery_5_bar_outlined,
        value: '72%',
        dot: _green,
      ),
      DeviceStat(
        label: 'Last ring',
        icon: Icons.notifications_none,
        value: '10:12 AM',
      ),
    ],
    DeviceKind.camera: [
      DeviceStat(
        label: 'Status',
        icon: Icons.wifi,
        value: 'Online',
        dot: _green,
      ),
      DeviceStat(label: 'Storage', icon: Icons.sd_card_outlined, value: '64%'),
      DeviceStat(
        label: 'Night',
        icon: Icons.nightlight_outlined,
        value: 'Auto',
      ),
    ],
    DeviceKind.light: [
      DeviceStat(
        label: 'Status',
        icon: Icons.wifi,
        value: 'Online',
        dot: _green,
      ),
      DeviceStat(label: 'Tone', icon: Icons.wb_sunny_outlined, value: 'Warm'),
      DeviceStat(label: 'Today', icon: Icons.bolt_outlined, value: '0.4 kWh'),
    ],
    DeviceKind.appliance: [
      DeviceStat(
        label: 'Status',
        icon: Icons.wifi,
        value: 'Online',
        dot: _green,
      ),
      DeviceStat(label: 'Mode', icon: Icons.tune, value: 'Auto'),
      DeviceStat(label: 'Today', icon: Icons.bolt_outlined, value: '1.2 kWh'),
    ],
    DeviceKind.sensor: [
      DeviceStat(
        label: 'Status',
        icon: Icons.wifi,
        value: 'Online',
        dot: _green,
      ),
      DeviceStat(
        label: 'Battery',
        icon: Icons.battery_5_bar_outlined,
        value: '88%',
        dot: _green,
      ),
      DeviceStat(label: 'Last alert', icon: Icons.history, value: 'None'),
    ],
  };
}

/// A room in the home: its tile on My Spaces, and its own page.
class Space {
  const Space({
    required this.id,
    required this.label,
    required this.image,
    this.devices = const [],
  });

  final String id;
  final String label;

  /// Room photo — cropped into the grid tile, and full-bleed behind the
  /// room's page and its devices' pages.
  final String image;
  final List<SpaceDevice> devices;
}

/// Placeholder data until the spaces / devices APIs are wired up.
const List<Space> demoSpaces = [
  Space(
    id: 'entrance',
    label: 'Entrance',
    image: 'images/entrance.png',
    devices: [
      SpaceDevice(
        name: 'Main Door Lock',
        kind: DeviceKind.lock,
        image: 'images/main_door_lock.png',
        // Bleeds off the bottom-right corner, like the Home tab's lock tile.
        imageAlignment: Alignment.bottomRight,
        imageWidthFactor: 0.62,
        imageHeightFactor: 0.95,
        highlighted: true,
        trailDeviceId: 'advantis_iot9',
        userCount: 6,
        stats: [
          DeviceStat(
            label: 'Door',
            icon: Icons.door_front_door_outlined,
            value: 'Closed',
            dot: _green,
          ),
          DeviceStat(
            label: 'Battery',
            icon: Icons.battery_charging_full_outlined,
            value: 'Critical',
            dot: _red,
          ),
          DeviceStat(label: 'Status', icon: Icons.bluetooth, value: 'BLE'),
        ],
      ),
      SpaceDevice(
        name: 'VDB',
        kind: DeviceKind.doorbell,
        image: 'images/vdb.png',
        imageWidthFactor: 0.55,
        imageHeightFactor: 1,
        trailDeviceId: 'video_door_bell',
      ),
      SpaceDevice(
        name: 'Entrance Camera',
        kind: DeviceKind.camera,
        icon: Icons.videocam_outlined,
      ),
      SpaceDevice(
        name: 'Foyer Lights',
        kind: DeviceKind.light,
        icon: Icons.lightbulb_outline,
      ),
      SpaceDevice(
        name: 'Motion Sensor',
        kind: DeviceKind.sensor,
        icon: Icons.sensors,
      ),
    ],
  ),
  Space(
    id: 'living_room',
    label: 'Living Room',
    image: 'images/living_room.png',
    devices: [
      SpaceDevice(
        name: 'Ceiling Lights',
        kind: DeviceKind.light,
        icon: Icons.light_outlined,
        highlighted: true,
      ),
      SpaceDevice(name: 'Smart TV', kind: DeviceKind.appliance, icon: Icons.tv),
      SpaceDevice(
        name: 'Air Conditioner',
        kind: DeviceKind.appliance,
        icon: Icons.ac_unit,
        stats: [
          DeviceStat(
            label: 'Status',
            icon: Icons.wifi,
            value: 'Online',
            dot: _green,
          ),
          DeviceStat(label: 'Set to', icon: Icons.thermostat, value: '24° C'),
          DeviceStat(label: 'Mode', icon: Icons.ac_unit, value: 'Cool'),
        ],
      ),
      SpaceDevice(
        name: 'Smart Speaker',
        kind: DeviceKind.appliance,
        icon: Icons.speaker_outlined,
      ),
    ],
  ),
  Space(
    id: 'dining',
    label: 'Dining',
    image: 'images/dining.png',
    devices: [
      SpaceDevice(
        name: 'Pendant Lights',
        kind: DeviceKind.light,
        icon: Icons.light_outlined,
        highlighted: true,
      ),
      SpaceDevice(
        name: 'Air Purifier',
        kind: DeviceKind.appliance,
        icon: Icons.air,
        stats: [
          DeviceStat(
            label: 'Status',
            icon: Icons.wifi,
            value: 'Online',
            dot: _green,
          ),
          DeviceStat(label: 'AQI', icon: Icons.eco_outlined, value: '42'),
          DeviceStat(
            label: 'Filter',
            icon: Icons.filter_alt_outlined,
            value: 'Replace soon',
            dot: _amber,
          ),
        ],
      ),
    ],
  ),
  Space(
    id: 'kitchen',
    label: 'Kitchen',
    image: 'images/kitchen.png',
    devices: [
      SpaceDevice(
        name: 'Refrigerator',
        kind: DeviceKind.appliance,
        icon: Icons.kitchen_outlined,
        highlighted: true,
        stats: [
          DeviceStat(
            label: 'Status',
            icon: Icons.wifi,
            value: 'Online',
            dot: _green,
          ),
          DeviceStat(label: 'Fridge', icon: Icons.thermostat, value: '4° C'),
          DeviceStat(label: 'Freezer', icon: Icons.ac_unit, value: '-18° C'),
        ],
      ),
      SpaceDevice(
        name: 'Gas Leak Sensor',
        kind: DeviceKind.sensor,
        icon: Icons.sensors,
      ),
      SpaceDevice(name: 'Chimney', kind: DeviceKind.appliance, icon: Icons.air),
    ],
  ),
  Space(
    id: 'master_bedroom',
    label: 'Master Bedroom',
    image: 'images/master_bedroom.png',
    devices: [
      SpaceDevice(
        name: 'Wardrobe Lock',
        kind: DeviceKind.lock,
        image: 'images/devices/astron_rion.png',
        imageWidthFactor: 0.32,
        imageHeightFactor: 0.6,
        highlighted: true,
        trailDeviceId: 'astron_rion',
        userCount: 2,
      ),
      SpaceDevice(
        name: 'Air Conditioner',
        kind: DeviceKind.appliance,
        icon: Icons.ac_unit,
      ),
      SpaceDevice(
        name: 'Bedside Lamp',
        kind: DeviceKind.light,
        icon: Icons.lightbulb_outline,
      ),
      SpaceDevice(
        name: 'Smart Curtains',
        kind: DeviceKind.appliance,
        icon: Icons.curtains_outlined,
      ),
    ],
  ),
  Space(
    id: 'balcony',
    label: 'Balcony',
    image: 'images/balcony.png',
    devices: [
      SpaceDevice(
        name: 'Outdoor Camera',
        kind: DeviceKind.camera,
        icon: Icons.videocam_outlined,
      ),
      SpaceDevice(
        name: 'Garden Lights',
        kind: DeviceKind.light,
        icon: Icons.light_outlined,
        highlighted: true,
      ),
    ],
  ),
];
