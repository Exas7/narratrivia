import 'package:flutter/material.dart';
import '../controllers/hub_constants.dart';

/// Selector widget showing 7 colored rectangles for quick navigation
class ArcSelector extends StatelessWidget {
  final int currentIndex;
  final bool isVisible;
  final Function(int) onItemTap;

  const ArcSelector({
    super.key,
    required this.currentIndex,
    required this.isVisible,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      height: HubConstants.selectorHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(HubConstants.selectorBorderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            HubConstants.mediums.length,
                (index) => _buildSelectorItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorItem(int index) {
    final medium = HubConstants.mediums[index];
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onItemTap(index),
      child: AnimatedContainer(
        duration: HubConstants.selectorAnimationDuration,
        width: HubConstants.selectorItemSize,
        height: HubConstants.selectorItemSize,
        decoration: BoxDecoration(
          color: medium.color,
          borderRadius: BorderRadius.circular(HubConstants.selectorItemBorderRadius),
          border: isActive
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: medium.color.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: medium.color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            duration: HubConstants.selectorAnimationDuration,
            scale: isActive ? 1.1 : 1.0,
            child: Icon(
              medium.icon,
              color: isActive ? Colors.white : Colors.black54,
              size: isActive ? 26 : 22,
            ),
          ),
        ),
      ),
    );
  }
}