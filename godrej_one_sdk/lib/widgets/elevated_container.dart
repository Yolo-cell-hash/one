import 'package:flutter/material.dart';

const _brand = Color(0xFF810055);
const _onBorder = Color(0xFF8DFC63);
const _offBorder = Color(0xFFD9D9D9);

const _text = TextStyle(
  color: _brand,
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
);

/// A pill toggle matching the app's "active = green outline" language (the
/// same treatment as the armed-away banner and the locked-door status):
/// track stays white, the filled brand-colored thumb slides left↔right, and
/// only the border switches color to signal on/off.
class _AiModeToggle extends StatelessWidget {
  const _AiModeToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'AI Mode',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 40,
          height: 18,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: value ? _onBorder : _offBorder,
              width: value ? 1.5 : 1,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: const DecoratedBox(
              decoration: BoxDecoration(color: _brand, shape: BoxShape.circle),
              child: SizedBox(width: 13, height: 13),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft raised card on the Navigation page: "How does it work?" when
/// [toggleNeeded] is false, the AI Mode switch when it's true.
class ElevatedContainer extends StatefulWidget {
  const ElevatedContainer({super.key, required this.toggleNeeded});

  final bool toggleNeeded;

  @override
  State<ElevatedContainer> createState() => _ElevatedContainerState();
}

class _ElevatedContainerState extends State<ElevatedContainer> {
  bool _aiMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        width: double.infinity,
        padding: widget.toggleNeeded
            ? const EdgeInsets.fromLTRB(14, 26, 20, 26)
            : const EdgeInsets.fromLTRB(13, 16, 13, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(widget.toggleNeeded ? 30 : 26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: widget.toggleNeeded
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      'Turn on the AI Mode so that the app identifies the '
                      'usage and alters the navigation bar according to '
                      'your frequently used feature.',
                      style: _text.copyWith(fontSize: 12.5, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 18),
                  _AiModeToggle(
                    value: _aiMode,
                    onChanged: (value) => setState(() => _aiMode = value),
                  ),
                ],
              )
            : Text.rich(
                TextSpan(
                  style: _text.copyWith(
                    fontSize: 12.5,
                    height: 1.3,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                  ),
                  children: const [
                    TextSpan(
                      text: 'How does it work?\n',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          'Add up to 3 icons to your dynamic navigation '
                          'toolbar and create a personalized shortcut menu '
                          'for quick, easy access to your favorite features.',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
