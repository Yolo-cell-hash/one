import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/service/user_name_onboarding_handler.dart';
import 'package:godrej_one_sdk/widgets/home_camera_widgets.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _glassFill = Color(0xFFE4EAF6);

class LandingTopContent extends StatelessWidget {
  const LandingTopContent({
    super.key,
    required this.users,
    required this.selectedIndex,
    required this.onSelect,
    required this.avatarKeys,
  });

  final List<OnboardingUser> users;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<GlobalKey> avatarKeys;

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
              HomeCameraWidgets(status: 0),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              for (var i = 0; i < users.length; i++) ...[
                UserCircleAvatarOnboarding(
                  key: avatarKeys[i],
                  name: users[i].name,
                  image: AssetImage(users[i].image, package: 'godrej_one_sdk'),
                  selected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
                const SizedBox(width: 8),
              ],
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
