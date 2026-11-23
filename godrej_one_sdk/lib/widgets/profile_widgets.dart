import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/photo.dart';
import 'package:godrej_one_sdk/providers/bottom_bar_provider.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/screen_header.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _brand = Color(0xFF810055);

/// Switches the shell to the Profile tab — what tapping the resident's
/// photo does anywhere inside the app.
void openProfile(BuildContext context) =>
    context.read<BottomBarProvider>().selectById('profile');

/// The signed-in resident's photo, from [ProfileStore], so it changes
/// everywhere the moment it's edited. Tapping it opens Profile unless
/// [onTap] says otherwise.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.ring = false,
    this.onTap,
    this.openProfileOnTap = true,
  });

  final double size;

  /// The active-green ring the design draws round the resident.
  final bool ring;
  final VoidCallback? onTap;
  final bool openProfileOnTap;

  @override
  Widget build(BuildContext context) {
    final user = context.select<ProfileStore, ({String name, String image})>(
      (s) => (name: s.user.name, image: s.user.image),
    );
    final tap = onTap ?? (openProfileOnTap ? () => openProfile(context) : null);
    return Semantics(
      container: true,
      button: tap != null,
      label: '${user.name}, profile',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: PhotoCircle(
          image: photoImage(user.image),
          size: size,
          ring: ring,
        ),
      ),
    );
  }
}

/// A round photo, optionally with the active-green ring.
class PhotoCircle extends StatelessWidget {
  const PhotoCircle({
    super.key,
    required this.image,
    required this.size,
    this.ring = false,
  });

  final ImageProvider image;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ring ? Border.all(color: activeRingColor, width: 2) : null,
      ),
      child: ClipOval(
        child: Image(
          image: image,
          fit: BoxFit.cover,
          width: size,
          height: size,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Color(0xFFE6E6E6),
            child: Icon(Icons.person, color: _brand),
          ),
        ),
      ),
    );
  }
}

/// [child] with a small round badge button over its bottom-right — the
/// pencil on the profile photo, the camera on a property's photo.
class BadgedPhoto extends StatelessWidget {
  const BadgedPhoto({
    super.key,
    required this.child,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget child;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -4,
          bottom: -2,
          child: Semantics(
            container: true,
            button: true,
            label: label,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 19, color: _brand),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped outlined field with its label sitting on the border, as in
/// the design's forms.
class OutlinedField extends StatelessWidget {
  const OutlinedField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  static const _text = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'GEG',
    package: 'godrej_one_sdk',
  );

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
      borderSide: BorderSide(color: _brand),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: _text,
      cursorColor: _brand,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: _text.copyWith(color: _brand, fontSize: 15),
        floatingLabelStyle: _text.copyWith(color: _brand, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _brand, width: 1.6),
        ),
      ),
    );
  }
}

/// "Upload From Gallery" / "Take Picture" — shown in place of a form while
/// its photo is being changed.
class PhotoSourceButtons extends StatelessWidget {
  const PhotoSourceButtons({super.key, required this.onPick});

  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 206,
          child: BrandPillButton(
            label: 'Upload From Gallery',
            onTap: () => onPick(ImageSource.gallery),
            padding: const EdgeInsets.symmetric(vertical: 10),
            centered: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 206,
          child: BrandPillButton(
            label: 'Take Picture',
            onTap: () => onPick(ImageSource.camera),
            padding: const EdgeInsets.symmetric(vertical: 10),
            centered: true,
          ),
        ),
      ],
    );
  }
}

/// White page with the design's centred title and "more" button, a body,
/// and an optional pill [action] above the bottom bar.
class ProfileSubpage extends StatelessWidget {
  const ProfileSubpage({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final Widget body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the action always sits
    // just above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          ScreenHeader(title: title),
          Expanded(child: body),
          if (action != null) ...[const SizedBox(height: 12), action!],
          SizedBox(height: barHeight + media.padding.bottom + gap * 1.4),
        ],
      ),
    );
  }
}

/// The brand pill at the foot of a form, greyed out while [onTap] is null.
class FormActionButton extends StatelessWidget {
  const FormActionButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? _brand : const Color(0xFFDADADA),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.white : const Color(0xFF9E9E9E),
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
            ),
          ),
        ),
      ),
    );
  }
}

/// The design's soft raised card: a wide, faint shadow under a light grey
/// [Material], so ink from rows inside it still shows.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.color = const Color(0xFFF6F6F6),
  });

  final Widget child;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
