import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/service/user_name_onboarding_handler.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _brand = Color(0xFF810055);

const _lineStyle = TextStyle(
  fontSize: 16,
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
);

/// The landing page's frosted header card: the greeting, property and
/// resident on the left; the resident's photo and the property button in a
/// capsule on the right.
class LandingTopContent extends StatelessWidget {
  const LandingTopContent({
    super.key,
    required this.user,
    required this.avatarKey,
    required this.locality,
    this.propertiesOpen = false,
    this.onAvatarTap,
    this.onPropertyTap,
  });

  final OnboardingUser user;

  /// Marks where the launch animation's flying avatar starts from.
  final GlobalKey avatarKey;

  /// The selected property's neighbourhood, shown under "Welcome home".
  final String locality;

  /// Whether the properties list is open — rings the property button.
  final bool propertiesOpen;

  /// Tap on the resident's photo.
  final VoidCallback? onAvatarTap;

  /// Tap on the property button.
  final VoidCallback? onPropertyTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 131,
          padding: const EdgeInsets.fromLTRB(21, 0, 13, 0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome home',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'GEG',
                        package: 'godrej_one_sdk',
                        color: _brand,
                      ),
                    ),
                    Text(
                      locality,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _lineStyle,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _lineStyle,
                    ),
                  ],
                ),
              ),
              _ProfileCapsule(
                user: user,
                avatarKey: avatarKey,
                propertiesOpen: propertiesOpen,
                onAvatarTap: onAvatarTap,
                onPropertyTap: onPropertyTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCapsule extends StatelessWidget {
  const _ProfileCapsule({
    required this.user,
    required this.avatarKey,
    required this.propertiesOpen,
    this.onAvatarTap,
    this.onPropertyTap,
  });

  final OnboardingUser user;
  final GlobalKey avatarKey;
  final bool propertiesOpen;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onPropertyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 102,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UserCircleAvatarOnboarding(
            key: avatarKey,
            name: user.name,
            image: AssetImage(user.image, package: 'godrej_one_sdk'),
            selected: true,
            onTap: onAvatarTap,
          ),
          Container(
            width: 34,
            height: 1,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          Semantics(
            button: true,
            label: 'Properties',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPropertyTap,
              child: _PropertyGlyph(active: propertiesOpen),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand map pin with a house cut into its head, in a pale round button.
class _PropertyGlyph extends StatelessWidget {
  const _PropertyGlyph({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: active ? Border.all(color: activeRingColor, width: 2) : null,
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.location_on, size: 27, color: _brand),
          Align(
            alignment: Alignment(0, -0.2),
            child: Icon(Icons.home_rounded, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
