import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/widgets/landing_unlock_slider.dart';
import 'package:godrej_one_sdk/widgets/landing_top_content.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/landing_base_bg.png',
              package: 'godrej_one_sdk',
              fit: BoxFit.cover,
            ),
          ),
          // White haze sampled from the design: clear down to 56%, ~48% white by 72%, easing off at the bottom.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.41),
                    Colors.white.withValues(alpha: 0.48),
                    Colors.white.withValues(alpha: 0.47),
                    Colors.white.withValues(alpha: 0.33),
                  ],
                  stops: const [0.0, 0.56, 0.60, 0.64, 0.68, 0.72, 0.86, 1.0],
                ),
              ),
            ),
          ),

          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: LandingTopContent(),
          ),

          Positioned(
            bottom: 227,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'images/home_glass.png',
                package: 'godrej_one_sdk',
                width: 65,
                height: 65,
              ),
            ),
          ),

          Positioned(
            left: 34,
            bottom: 177,
            child: Image.asset(
              'images/bell_icon.png',
              package: 'godrej_one_sdk',
              width: 65,
              height: 65,
            ),
          ),
          Positioned(
            right: 24,
            bottom: 177,
            child: Image.asset(
              'images/power_icon.png',
              package: 'godrej_one_sdk',
              width: 65,
              height: 65,
            ),
          ),

          const LandingUnlockSlider(),
        ],
      ),
    );
  }
}
