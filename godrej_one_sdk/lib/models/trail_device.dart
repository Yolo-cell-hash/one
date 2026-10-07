import 'package:flutter/material.dart';

/// The filter chips on the Activity Trail device list. "All" isn't a
/// category — it's represented by a `null` selection instead.
enum DeviceCategory {
  locks('Locks'),
  cameras('Cameras'),
  appliance('Appliance'),
  sensors('Sensors');

  const DeviceCategory(this.label);

  final String label;
}

/// One line in a device's activity trail: who did what, and when.
class TrailEvent {
  const TrailEvent({
    required this.actor,
    required this.action,
    required this.time,
  });

  final String actor;
  final String action;
  final TimeOfDay time;

  /// "05:30 AM" — zero-padded 12-hour clock, which `TimeOfDay.format`
  /// doesn't give us (it drops the leading zero).
  String get formattedTime {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// A device that keeps an activity trail.
class TrailDevice {
  const TrailDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.category,
    required this.image,
    this.events = const [],
  });

  final String id;
  final String name;

  /// Shown under the name — "Digital Lock", "VDB".
  final String type;

  /// Where it's installed — "Main Door". Prefixes every event line.
  final String location;
  final DeviceCategory category;
  final String image;
  final List<TrailEvent> events;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || type.toLowerCase().contains(q);
  }
}

/// Placeholder data until the device / audit-log APIs are wired up.
const List<TrailDevice> demoTrailDevices = [
  TrailDevice(
    id: 'advantis_gsl_d1',
    name: 'Advantis GSL D1',
    type: 'Digital Lock',
    location: 'Back Door',
    category: DeviceCategory.locks,
    image: 'images/devices/advantis_gsl_d1.png',
    events: [
      TrailEvent(
        actor: 'Ron',
        action: 'Opened using keypad',
        time: TimeOfDay(hour: 7, minute: 15),
      ),
      TrailEvent(
        actor: 'Ishwarya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 11, minute: 2),
      ),
      TrailEvent(
        actor: 'Riya',
        action: 'Locked using bluetooth',
        time: TimeOfDay(hour: 18, minute: 40),
      ),
    ],
  ),
  TrailDevice(
    id: 'astron_rion',
    name: 'Astron / Rion',
    type: 'Furniture Locks',
    location: 'Bedroom Wardrobe',
    category: DeviceCategory.locks,
    image: 'images/devices/astron_rion.png',
    events: [
      TrailEvent(
        actor: 'Riya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 8, minute: 20),
      ),
      TrailEvent(
        actor: 'Ashwanth',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 21, minute: 10),
      ),
    ],
  ),
  TrailDevice(
    id: 'advantis_iot9',
    name: 'Advantis IoT9',
    type: 'Digital Lock',
    location: 'Main Door',
    category: DeviceCategory.locks,
    image: 'images/devices/advantis_iot9.png',
    events: [
      TrailEvent(
        actor: 'Riya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 5, minute: 30),
      ),
      TrailEvent(
        actor: 'Ron',
        action: 'Opened using keypad',
        time: TimeOfDay(hour: 8, minute: 0),
      ),
      TrailEvent(
        actor: 'Ashwanth',
        action: 'Opened using bluetooth',
        time: TimeOfDay(hour: 9, minute: 43),
      ),
      TrailEvent(
        actor: 'Riya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 9, minute: 56),
      ),
      TrailEvent(
        actor: 'Ishwarya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 12, minute: 30),
      ),
      TrailEvent(
        actor: 'Riya',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 14, minute: 30),
      ),
      TrailEvent(
        actor: 'Ashwanth',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 15, minute: 45),
      ),
      TrailEvent(
        actor: 'Ashwanth',
        action: 'Opened using fingerprint',
        time: TimeOfDay(hour: 16, minute: 56),
      ),
    ],
  ),
  TrailDevice(
    id: 'video_door_bell',
    name: 'Video Door Bell',
    type: 'VDB',
    location: 'Main Door',
    category: DeviceCategory.cameras,
    image: 'images/devices/video_door_bell.png',
    events: [
      TrailEvent(
        actor: 'Visitor',
        action: 'Rang the doorbell',
        time: TimeOfDay(hour: 10, minute: 12),
      ),
      TrailEvent(
        actor: 'Riya',
        action: 'Answered on video call',
        time: TimeOfDay(hour: 10, minute: 13),
      ),
      TrailEvent(
        actor: 'Ashwanth',
        action: 'Viewed live feed',
        time: TimeOfDay(hour: 19, minute: 5),
      ),
    ],
  ),
];
