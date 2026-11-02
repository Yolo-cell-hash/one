import 'package:flutter/material.dart';

import 'package:godrej_one_sdk/models/property.dart';
import 'package:godrej_one_sdk/widgets/action_card.dart';
import 'package:godrej_one_sdk/widgets/user_circle_avatar_onboarding.dart';

const _brand = Color(0xFF810055);

/// Frosted "Properties" card opened from the landing page's home button:
/// one row per [Property], the selected one ringed in the active green,
/// and an "Add Property" pill under the list.
class LandingPropertiesPanel extends StatelessWidget {
  const LandingPropertiesPanel({
    super.key,
    required this.properties,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAddProperty,
  });

  final List<Property> properties;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddProperty;

  @override
  Widget build(BuildContext context) {
    // No blur of its own: the photo behind it is already frosted, and a live
    // blur can't fade with the card.
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Properties',
            style: TextStyle(
              fontSize: 22,
              color: _brand,
              fontFamily: 'GEG',
              package: 'godrej_one_sdk',
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < properties.length; i++) ...[
            _PropertyRow(
              property: properties[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
            const SizedBox(height: 11),
          ],
          const SizedBox(height: 12),
          BrandPillButton(
            label: 'Add Property',
            fontSize: 18,
            onTap: onAddProperty,
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.property,
    required this.selected,
    required this.onTap,
  });

  final Property property;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 97,
        padding: const EdgeInsets.fromLTRB(36, 8, 12, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? activeRingColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 464 / 324,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image(
                  image: property.thumbnailImage,
                  fit: BoxFit.cover,
                  // Portrait photos are mostly sky up top — frame the house.
                  alignment: const Alignment(0, 0.4),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                property.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  color: _brand,
                  fontFamily: 'GEG',
                  package: 'godrej_one_sdk',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
