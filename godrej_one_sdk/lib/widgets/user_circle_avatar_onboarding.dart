import 'package:flutter/material.dart';

const activeRingColor = Color(0xFF8DFC63);

class UserCircleAvatarOnboarding extends StatelessWidget {
  const UserCircleAvatarOnboarding({
    super.key,
    required this.name,
    required this.image,
    this.onTap,
    this.selected = false,
    this.radius = 17,
  });

  final String name;
  final ImageProvider image;
  final VoidCallback? onTap;
  final bool selected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(radius: radius, backgroundImage: image),
            Positioned.fill(
              left: -1,
              top: -1,
              right: -1,
              bottom: -1,
              child: AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: activeRingColor, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
