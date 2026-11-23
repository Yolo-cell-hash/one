import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/tab_navigator.dart';

const _brand = Color(0xFF810055);
const _online = Color(0xFF3FBF3F);

const _text = TextStyle(fontFamily: 'GEG', package: 'godrej_one_sdk');

/// The assistant's name: Gia — Godrej Intelligent Assistant — the voice of
/// Godrej ONE.
const assistantName = 'Gia';

/// The bar's chat tab: a conversation with Gia.
///
/// A placeholder for now — the opening conversation is scripted and replies
/// are canned, picked by keyword, until a real assistant is wired up.
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabNavigator(tabId: 'assistant', root: _ChatPage());
  }
}

class _Message {
  const _Message(this.text, {required this.fromUser});

  final String text;
  final bool fromUser;
}

class _ChatPage extends StatefulWidget {
  const _ChatPage();

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final List<_Message> _messages = _openingConversation(
    context.read<ProfileStore>().user.name,
  );
  bool _typing = false;
  Timer? _replyTimer;

  static const _suggestions = [
    'Lock all doors',
    'Who rang the doorbell?',
    'Energy usage today',
    'Add a device',
  ];

  static List<_Message> _openingConversation(String name) => [
    _Message(
      "Hi $name! I'm $assistantName, your Godrej ONE assistant. Ask me "
      'about your locks, cameras, devices or home.',
      fromUser: false,
    ),
    const _Message('Is the main door locked?', fromUser: true),
    const _Message(
      'Yes, the Main door lock is locked, and so are your other doors.',
      fromUser: false,
    ),
    const _Message('Who rang the doorbell today?', fromUser: true),
    const _Message(
      'Your Video Door Bell rang twice today: at 10:42 AM and 4:15 PM. '
      'Both clips are saved in Activity Trails.',
      fromUser: false,
    ),
  ];

  /// A canned reply until a real assistant is connected.
  static String _replyTo(String message) {
    final m = message.toLowerCase();
    if (m.contains('unlock')) {
      return 'For your safety, doors are unlocked with hold and swipe on '
          'the landing page. I can remind you how!';
    }
    // Before locks: "doorbell" contains "door".
    if (m.contains('bell') || m.contains('camera') || m.contains('vdb')) {
      return 'Your Video Door Bell is online. Its last ring was at 4:15 PM, '
          'and the clip is in Activity Trails.';
    }
    if (m.contains('lock') || m.contains('door')) {
      return 'Done! All 3 doors are locked: Back door, Front door and '
          'Balcony door.';
    }
    if (m.contains('energy') || m.contains('power') || m.contains('usage')) {
      return "You've used 24.6 kWh today, about 8% less than yesterday.";
    }
    if (m.contains('device') || m.contains('add')) {
      return 'To add a device, open the Devices tab in the bar and choose '
          'Scan QR or Scan Nearby.';
    }
    if (RegExp(r'\b(hi|hello|hey)\b').hasMatch(m)) {
      return 'Hello! How can I help with your home today?';
    }
    if (m.contains('thank')) return "You're welcome!";
    return "I'm still learning. $assistantName is a preview for now, so "
        'my answers are placeholders. Real help is coming soon!';
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;
    _input.clear();
    setState(() {
      _messages.add(_Message(text, fromUser: true));
      _typing = true;
    });
    _scrollToEnd();
    _replyTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Message(_replyTo(text), fromUser: false));
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    // Same formulas HomeShell uses for its bar, so the input always sits
    // just above it.
    final barHeight = (w * 0.19).clamp(66.0, 84.0);
    final gap = (w * 0.035).clamp(12.0, 18.0);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const _ChatHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              itemCount: _messages.length + 2,
              itemBuilder: (context, i) {
                if (i == 0) return const _PreviewNote();
                if (i == _messages.length + 1) {
                  return _typing
                      ? const _Bubble(fromUser: false, child: _TypingDots())
                      : const SizedBox.shrink();
                }
                final message = _messages[i - 1];
                return _Bubble(
                  fromUser: message.fromUser,
                  child: Text(
                    message.text,
                    style: _text.copyWith(
                      fontSize: 15,
                      height: 1.35,
                      color: message.fromUser ? Colors.white : _brand,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _SuggestionChip(
                label: _suggestions[i],
                onTap: () => _send(_suggestions[i]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Composer(controller: _input, onSend: _send),
          ),
          SizedBox(height: barHeight + media.padding.bottom + gap * 1.3),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 12),
      child: Row(
        children: [
          const _GiaAvatar(size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistantName,
                  style: _text.copyWith(fontSize: 24, color: _brand),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your Godrej ONE assistant',
                      style: _text.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showElegantToast(context, 'Coming soon'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 22,
                color: _brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiaAvatar extends StatelessWidget {
  const _GiaAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA0206F), _brand],
        ),
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}

class _PreviewNote extends StatelessWidget {
  const _PreviewNote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Preview · replies are placeholders',
          style: _text.copyWith(fontSize: 12, color: const Color(0xFF8A8A8A)),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.fromUser, required this.child});

  final bool fromUser;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(20);
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.68,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: fromUser ? _brand : const Color(0xFFF4F1F3),
        borderRadius: BorderRadius.only(
          topLeft: r,
          topRight: r,
          bottomLeft: fromUser ? r : const Radius.circular(6),
          bottomRight: fromUser ? const Radius.circular(6) : r,
        ),
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: fromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromUser) ...[
            const _GiaAvatar(size: 28),
            const SizedBox(width: 8),
          ],
          bubble,
        ],
      ),
    );
  }
}

/// Three dots pulsing in turn while Gia "types".
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$assistantName is typing',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(
                  horizontal: 2.5,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brand.withValues(
                    alpha:
                        0.3 +
                        0.7 *
                            (1 - ((_controller.value * 3 - i) % 3).clamp(0, 1)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD9D9D9))),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: _text.copyWith(fontSize: 14, color: _brand),
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSend,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: _brand,
              style: _text.copyWith(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Ask $assistantName anything',
                hintStyle: _text.copyWith(
                  fontSize: 15,
                  color: const Color(0xFFA6A6A6),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Send',
            child: GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: const BoxDecoration(
                  color: _brand,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
