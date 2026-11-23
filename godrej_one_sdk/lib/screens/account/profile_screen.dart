import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/trail_device.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/screens/account/device_pages.dart';
import 'package:godrej_one_sdk/screens/account/info_pages.dart';
import 'package:godrej_one_sdk/screens/account/manage_properties_screen.dart';
import 'package:godrej_one_sdk/screens/account/personal_information_screen.dart';
import 'package:godrej_one_sdk/screens/account/voice_assistant_screen.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';

const _brand = Color(0xFF810055);

/// Gateways aren't modelled yet; the design's count until they are.
const _demoGatewayCount = 3;

const _text = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
);

/// The Profile tab: the resident's photo and counts over their home's
/// photo, then Account, Management, Integrations and Support. Each row opens
/// its page inside the tab, so the bottom bar stays put.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabNavigator(tabId: 'profile', root: _ProfilePage());
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  void _signOut(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);

  Future<void> _confirmDelete(BuildContext context) async {
    final delete = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const _DeleteAccountDialog(),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
    if (delete == true && context.mounted) {
      showElegantToast(context, 'Account deletion coming soon');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: barHeight + media.padding.bottom + gap * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(
              onProperties: () =>
                  _push(context, const ManagePropertiesScreen()),
              onDevices: () => _push(context, const DevicesScreen()),
            ),
            _Section(
              label: 'Account',
              rows: [
                _Row(
                  icon: const _Glyph(Icons.person),
                  label: 'Personal information',
                  onTap: () =>
                      _push(context, const PersonalInformationScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.person, badge: Icons.lock),
                  label: 'Security and privacy',
                  onTap: () => _push(context, const SecurityPrivacyScreen()),
                ),
              ],
            ),
            _Section(
              label: 'Management',
              rows: [
                _Row(
                  icon: const _PinGlyph(),
                  label: 'Manage Properties',
                  onTap: () => _push(context, const ManagePropertiesScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.sensor_door_rounded),
                  label: 'Manage Locks',
                  onTap: () => _push(context, const ManageLocksScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.workspaces_filled),
                  label: 'Devices',
                  onTap: () => _push(context, const DevicesScreen()),
                ),
              ],
            ),
            _Section(
              label: 'Integrations',
              rows: [
                _Row(
                  icon: const _Glyph(Icons.mic_rounded),
                  label: 'Voice Assistant',
                  onTap: () => _push(context, const VoiceAssistantScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.home_rounded, badge: Icons.wifi),
                  label: 'Smart home Integrations',
                  onTap: () => showElegantToast(
                    context,
                    'Smart home integrations coming soon',
                  ),
                ),
              ],
            ),
            _Section(
              label: 'Support',
              rows: [
                _Row(
                  icon: const _Glyph(Icons.support_agent_rounded),
                  label: 'Support',
                  onTap: () => _push(context, const SupportScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.policy_rounded),
                  label: 'Terms & Policies',
                  onTap: () => _push(context, const TermsScreen()),
                ),
                _Row(
                  icon: const _Glyph(Icons.person, badge: Icons.cancel),
                  label: 'Delete Account',
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Center(
              child: BrandPillButton(
                label: 'Sign Out',
                onTap: () => _signOut(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The resident's photo, name and counts in a frosted card, over a blurred
/// copy of the selected property's photo.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onProperties, required this.onDevices});

  final VoidCallback onProperties;
  final VoidCallback onDevices;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProfileStore>();
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: top + 275,
      child: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
                tileMode: TileMode.clamp,
              ),
              child: Image(
                image: store.property.frostedImage,
                fit: BoxFit.cover,
                alignment: const Alignment(0.2, -0.6),
              ),
            ),
          ),
          Positioned(
            left: 33,
            right: 33,
            bottom: 18,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        store.user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _text.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        spacing: 6,
                        children: [
                          _Stat(
                            count: store.properties.length,
                            label: 'Properties',
                            onTap: onProperties,
                          ),
                          _Stat(
                            count: demoTrailDevices.length,
                            label: 'Devices',
                            onTap: onDevices,
                          ),
                          _Stat(
                            count: _demoGatewayCount,
                            label: 'Gateways',
                            onTap: () => showElegantToast(
                              context,
                              'Gateways coming soon',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: ProfileAvatar(
                size: 93,
                ring: true,
                openProfileOnTap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label, required this.onTap});

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        container: true,
        button: true,
        label: '$count $label',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$count', style: _text.copyWith(fontSize: 24)),
                const SizedBox(height: 4),
                Text(label, style: _text.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled group of rows in a soft raised card.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.rows});

  final String label;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 18, 36, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _text.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: Color(0xFFE3E3E3)),
                    rows[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 53,
        child: Row(
          children: [
            SizedBox(width: 30, child: Center(child: icon)),
            const SizedBox(width: 22),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text.copyWith(fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _brand, size: 22),
          ],
        ),
      ),
    );
  }
}

/// A brand glyph, optionally with a small [badge] over its bottom-right.
class _Glyph extends StatelessWidget {
  const _Glyph(this.icon, {this.badge});

  final IconData icon;
  final IconData? badge;

  @override
  Widget build(BuildContext context) {
    if (badge == null) return Icon(icon, color: _brand, size: 24);
    return SizedBox(
      width: 28,
      height: 26,
      child: Stack(
        children: [
          Icon(icon, color: _brand, size: 24),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F6F6),
                shape: BoxShape.circle,
              ),
              child: Icon(badge, color: _brand, size: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map pin with a house cut into it — the property glyph.
class _PinGlyph extends StatelessWidget {
  const _PinGlyph();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, size: 27, color: _brand),
        Align(
          alignment: Alignment(0, -0.2),
          child: Icon(Icons.home_rounded, size: 11, color: Colors.white),
        ),
      ],
    );
  }
}

/// "Delete Account" confirmation over a frosted page; pops `true` for
/// Delete.
class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: SoftCard(
            radius: 30,
            color: const Color(0xFFF7F7F7),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delete Account',
                    style: _text.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to delete your account?\n'
                    'This action will permanently erase all your personal '
                    'data, including your settings, preferences, and '
                    'history. Once deleted, your account cannot be '
                    'recovered, and you will lose access to all associated '
                    'services',
                    textAlign: TextAlign.center,
                    style: _text.copyWith(fontSize: 13, height: 1.8),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brand,
                          side: const BorderSide(color: _brand),
                          shape: const StadiumBorder(),
                          minimumSize: const Size(108, 40),
                        ),
                        child: Text(
                          'Delete',
                          style: _text.copyWith(fontSize: 16),
                        ),
                      ),
                      FormActionButton(
                        label: 'Cancel',
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
