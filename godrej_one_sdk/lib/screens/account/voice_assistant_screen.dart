import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';

const _brand = Color(0xFF810055);

const _text = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
  fontSize: 13,
  height: 1.6,
);

/// Voice assistants the account can be linked to. A mock-up for now: Link
/// shows a toast.
class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubpage(
      title: 'Voice Assistance',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 26, 30, 16),
        children: [
          const Text(
            'Link your account with these voice assistants for seamless '
            'control of your locks',
            style: _text,
          ),
          const SizedBox(height: 24),
          for (final assistant in ['Amazon Alexa', 'Google home']) ...[
            _AssistantCard(
              name: assistant,
              onLink: () =>
                  showElegantToast(context, 'Linking $assistant coming soon'),
            ),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 60),
          const Text(
            'After linking to a Voice Assistance, control each lock with '
            'your voice. Go to the Settings of a lock and turn on the '
            'relevant Voice Assistance option.\n\n'
            'You can do that by\n\n'
            'Selecting a lock > Settings > Voice Assistance > Enable '
            'Amazon > Alexa or Google Home',
            textAlign: TextAlign.center,
            style: _text,
          ),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.name, required this.onLink});

  final String name;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: _text.copyWith(fontSize: 17)),
          const SizedBox(height: 14),
          SizedBox(
            width: 104,
            child: BrandPillButton(
              label: 'Link',
              onTap: onLink,
              centered: true,
              padding: const EdgeInsets.symmetric(vertical: 7),
            ),
          ),
        ],
      ),
    );
  }
}
