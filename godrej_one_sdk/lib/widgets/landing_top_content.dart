import 'package:flutter/material.dart';

const _activeRing = Color(0xFF8DFC63);
const _glassFill = Color(0xFFE4EAF6);

class LandingTopContent extends StatefulWidget {
  const LandingTopContent({super.key});

  @override
  State<LandingTopContent> createState() => _LandingTopContentState();
}

class _LandingTopContentState extends State<LandingTopContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome home',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'GEG',
                        package: 'godrej_one_sdk',
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mumbai',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontFamily: 'GEG',
                        package: 'godrej_one_sdk',
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle notification icon tap
                    },
                    child: Image.asset(
                      'images/home_landing_icon.png',
                      package: 'godrej_one_sdk',
                      width: 34,
                      height: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      'images/camera_landing_icon.png',
                      package: 'godrej_one_sdk',
                      width: 34,
                      height: 34,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundImage: AssetImage(
                      'images/pfp1.png',
                      package: 'godrej_one_sdk',
                    ),
                  ),
                  Positioned.fill(
                    left: -1,
                    top: -1,
                    right: -1,
                    bottom: -1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: _activeRing, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 17,
                backgroundImage: AssetImage(
                  'images/pfp2.png',
                  package: 'godrej_one_sdk',
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 17,
                backgroundImage: AssetImage(
                  'images/pfp3.png',
                  package: 'godrej_one_sdk',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _glassFill,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'images/glassy_add.png',
                  package: 'godrej_one_sdk',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
