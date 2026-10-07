import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/trail_device.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';

/// One device's activity trail: a summary card for the device, then every
/// event it logged — who, how, and when.
///
/// Pushed onto the Activity Trails tab's own navigator, so the shell's
/// bottom bar stays in place above it.
class DeviceActivityScreen extends StatelessWidget {
  const DeviceActivityScreen({super.key, required this.device});

  final TrailDevice device;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formula HomeShell uses for its bar, so the last row always
    // scrolls clear of it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const ScreenHeader(title: 'Activity Trail'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                top: 24,
                bottom: barHeight + media.padding.bottom + gap * 2,
              ),
              children: [
                _DeviceSummaryCard(device: device),
                const SizedBox(height: 22),
                if (device.events.isEmpty)
                  const _NoActivity()
                else
                  for (final event in device.events)
                    _TrailEventRow(location: device.location, event: event),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceSummaryCard extends StatelessWidget {
  const _DeviceSummaryCard({required this.device});

  final TrailDevice device;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 76,
            child: Image.asset(
              device.image,
              package: 'godrej_one_sdk',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 36),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.location} | ${device.type}',
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
    );
  }
}

class _TrailEventRow extends StatelessWidget {
  const _TrailEventRow({required this.location, required this.event});

  final String location;
  final TrailEvent event;

  static const _grey = Color(0xFF8E8E8E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.actor,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  '$location | ${event.action}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _grey,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                event.formattedTime,
                style: const TextStyle(
                  fontSize: 15,
                  color: _grey,
                  fontFamily: 'GEG',
                  package: 'godrej_one_sdk',
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  // Keeps the times lined up down the column.
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoActivity extends StatelessWidget {
  const _NoActivity();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Text(
        'No activity recorded yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF8E8E8E),
          fontFamily: 'GEG',
          package: 'godrej_one_sdk',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
