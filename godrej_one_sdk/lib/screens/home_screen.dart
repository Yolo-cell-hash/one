import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/home_camera_widgets.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';
import 'package:godrej_one_sdk/widgets/glassy_scrollbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.name, required this.asset});

  final String name;
  final String asset;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    // Everything below is derived from the screen width so the grid keeps the
    // same proportions from a small phone to a tablet.
    final gutter = (w * 0.045).clamp(14.0, 24.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);
    final bannerHeight = (w * 0.21).clamp(74.0, 98.0);
    final tileHeight = (w * 0.35).clamp(120.0, 168.0);
    final cameraHeight = (w * 0.30).clamp(108.0, 160.0);
    final barHeight = (w * 0.19).clamp(66.0, 84.0);

    // The background image and the bottom bar are owned by HomeShell (they
    // are shared, persistent chrome); this widget is only the Home tab's
    // body inside the shell's IndexedStack.
    return Column(
      children: [
        // Pinned: stays put while the grid scrolls underneath it.
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            media.padding.top + 16,
            gutter,
            gap * 1.2,
          ),
          child: _Header(name: widget.name, asset: widget.asset),
        ),
        Expanded(
          child: GlassyScrollbar(
            controller: _scrollController,
            rightInset: gutter * 0.3,
            // Keep the track clear of the floating bottom bar.
            margin: EdgeInsets.only(
              top: 4,
              // bottom: barHeight + media.padding.bottom + gap,
              bottom: barHeight + media.padding.bottom + gap * 1.6,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                gutter,
                0,
                gutter,
                // Clear the floating bar plus the home indicator.
                barHeight + media.padding.bottom + gap * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassyContainer(
                    height: bannerHeight,
                    width: double.infinity,
                    title:
                        'Security system is armed away. All doors are locked. All gates are closed',
                    borderExists: true,
                    borderColor: const Color(0xFF8DFC63),
                  ),
                  SizedBox(height: gap),
                  Row(
                    spacing: gap,
                    children: [
                      GlassyContainer(
                        flex: 1,
                        height: tileHeight,
                        title: 'Energy Usage',
                        subtitle: '24.6 kWh',
                        caption: 'Today',
                        sparkline: const <double>[
                          4,
                          6,
                          5,
                          9,
                          7,
                          11,
                          8,
                          12,
                          15,
                          25,
                          38,
                          45,
                        ],
                      ),
                      GlassyContainer(
                        flex: 1,
                        height: tileHeight,
                        title: 'Indoor Temp',
                        subtitle: '24° C',
                        caption: 'Cozy',
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  Row(
                    spacing: gap,
                    children: [
                      GlassyContainer(
                        flex: 2,
                        height: tileHeight,
                        title: 'Air Quality',
                        subtitle: '42',
                        caption: 'Good',
                      ),
                      GlassyContainer(
                        flex: 5,
                        height: tileHeight,
                        title: 'Main door lock',
                        subtitle: 'LOCKED',
                        subtitleIcon: Icons.lock,
                        subtitleColor: const Color(0xFF3FBF3F),
                        imageExists: true,
                        imagePath: 'images/main_door_lock.png',
                        // Narrow enough to stay an overlay: the lock bleeds off
                        // the bottom-right corner behind the text.
                        mediaLayout: GlassyMediaLayout.overlay,
                        imageWidthFactor: 0.52,
                        imageHeightFactor: 0.88,
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  GlassyContainer(
                    height: cameraHeight,
                    width: double.infinity,
                    title: 'Entrance Camera',
                    imageExists: true,
                    imagePath: 'images/camera_dummy_img.png',
                    // Full-width card: title on the left, live view as a rounded
                    // panel filling the right half.
                    mediaLayout: GlassyMediaLayout.panel,
                    mediaWidthFactor: 0.58,
                    mediaOverlay: const _RecordingBadge(),
                  ),
                  SizedBox(height: gap),
                  Row(
                    spacing: gap,
                    children: [
                      GlassyContainer(
                        flex: 1,
                        height: tileHeight,
                        title: 'Video Door Bell',
                        statusDotColor: const Color(0xFF3FBF3F),
                        imageExists: true,
                        imagePath: 'images/vdb.png',
                        imageAlignment: Alignment.centerRight,
                        imageWidthFactor: 0.38,
                        imageHeightFactor: 0.72,
                        imagePadding: const EdgeInsets.only(right: 10),
                      ),
                      GlassyContainer(
                        flex: 1,
                        height: tileHeight,
                        title: 'Add Widgets',
                        imageExists: true,
                        imagePath: 'images/add_widgets.png',
                        // Small glyph tucked into the bottom-left, aligned with
                        // the title rather than filling the tile.
                        imageAlignment: Alignment.bottomLeft,
                        imageWidthFactor: 0.26,
                        imageHeightFactor: 0.26,
                        imagePadding: const EdgeInsets.fromLTRB(18, 0, 0, 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.asset});

  final String name;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final avatar = (w * 0.13).clamp(44.0, 60.0);

    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            asset,
            package: 'godrej_one_sdk',
            width: avatar,
            height: avatar,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: w * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hey, $name!',
                style: TextStyle(
                  fontSize: (w * 0.055).clamp(18.0, 24.0),
                  fontFamily: 'GEG',
                  package: 'godrej_one_sdk',
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Mumbai Home',
                style: TextStyle(
                  fontSize: (w * 0.035).clamp(12.0, 15.0),
                  fontFamily: 'GEG',
                  package: 'godrej_one_sdk',
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const HomeCameraWidgets(status: 1),
      ],
    );
  }
}

/// Red pip + label sitting on the camera preview.
class _RecordingBadge extends StatelessWidget {
  const _RecordingBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'REC',
              style: TextStyle(
                fontFamily: 'GEG',
                package: 'godrej_one_sdk',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
