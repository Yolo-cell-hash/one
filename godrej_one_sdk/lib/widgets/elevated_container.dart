import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/platform/adaptive.dart';

const _brand = Color(0xFF810055);
const _onBorder = Color(0xFF8DFC63);
const _offBorder = Color(0xFFD9D9D9);

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
    // iOS users expect the system switch here. Its system-green "on" track
    // already speaks the same "active = green" language.
    if (isCupertino(context)) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? _onBorder : _offBorder,
            width: value ? 2 : 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: const DecoratedBox(
            decoration: BoxDecoration(color: _brand, shape: BoxShape.circle),
            child: SizedBox(width: 22, height: 22),
          ),
        ),
      ),
    );
  }
}

class ElevatedContainer extends StatefulWidget {
  ElevatedContainer({super.key, required this.toggleNeeded});

  final bool toggleNeeded;

  @override
  State<ElevatedContainer> createState() => _ElevatedContainerState();
}

class _ElevatedContainerState extends State<ElevatedContainer> {
  bool _isVisible = true;
  bool _isOn = true;

  // iOS draws grouped content as a flat, filled panel; Material lifts it
  // with an elevation shadow.
  double _elevation(BuildContext context) => isCupertino(context) ? 0 : 5;

  Color _surface(BuildContext context) => isCupertino(context)
      ? CupertinoColors.secondarySystemBackground.resolveFrom(context)
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    if (widget.toggleNeeded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Material(
          elevation: _elevation(context),
          color: _surface(context),
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SelectableText(
                    'Turn on the AI Mode so that the app identifies the usage and alters the navigation bar according to your frequently used feature.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: _brand,
                      fontFamily: "GEG",
                      package: 'godrej_one_sdk',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _AiModeToggle(
                  value: _isOn,
                  onChanged: (value) => setState(() => _isOn = value),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Visibility(
        visible: _isVisible,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Material(
            elevation: _elevation(context),
            color: _surface(context),
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How does it work? ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: _brand,
                          fontFamily: "GEG",
                          package: 'godrej_one_sdk',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SelectableText(
                        'Add upto 3 icons to your dynamic navigation toolbar & create a personalised shortcut menu for quick, easy access to your favorite features. ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: _brand,
                          fontFamily: "GEG",
                          package: 'godrej_one_sdk',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _isVisible = false),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F5F5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        adaptiveIcon(context, Icons.close),
                        size: 18,
                        color: _brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
