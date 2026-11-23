import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';

const _brand = Color(0xFF810055);

const _text = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
);

/// Security and privacy settings — empty in the design for now.
class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubpage(
      title: 'Security and privacy',
      body: const SizedBox.expand(),
      action: FormActionButton(
        label: 'Update',
        onTap: () => showElegantToast(context, 'Security settings coming soon'),
      ),
    );
  }
}

/// Customer support contacts.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubpage(
      title: 'Support',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 3),
            SvgPicture.asset(
              'images/svgs/godrej_logo_white.svg',
              package: 'godrej_one_sdk',
              width: 128,
              colorFilter: const ColorFilter.mode(_brand, BlendMode.srcIn),
            ),
            const SizedBox(height: 70),
            Text(
              '24/7 Customer Support',
              style: _text.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Text(
              '1800 209 4543  |  +91 93216 65511',
              style: _text.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              'glafsescalation@godrejenterprises.com',
              style: _text.copyWith(fontSize: 14),
            ),
            const Spacer(flex: 4),
            Text(
              'Copyright © 2025 Godrej Enterprises. All rights reserved',
              textAlign: TextAlign.center,
              style: _text.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 8),
            Text(
              'www.godrejenterprises.com',
              style: _text.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terms and Conditions and the Privacy Policy.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubpage(
      title: 'Terms and Policies',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 34, 30, 16),
        children: [
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  for (final (i, title) in [
                    'Terms and Conditions',
                    'Privacy Policy',
                  ].indexed) ...[
                    if (i > 0)
                      const Divider(height: 1, color: Color(0xFFE3E3E3)),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 64),
                      title: Text(title, style: _text.copyWith(fontSize: 15)),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: _brand,
                      ),
                      onTap: () =>
                          showElegantToast(context, '$title coming soon'),
                    ),
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
