import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<EnhancedBottomNavigation> createState() =>
      _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.home_outlined,
                Icons.home,
                'Home',
                _hasNewPosts(),
              ),
              _buildNavItem(
                1,
                Icons.business_outlined,
                Icons.business,
                'Jobs',
                false,
              ),
              _buildNavItem(
                2,
                Icons.forum_outlined,
                Icons.forum,
                'Forum',
                _hasNewPosts(),
              ),
              _buildNavItem(
                3,
                Icons.people_outlined,
                Icons.people,
                'Network',
                false,
              ),
              _buildNavItem(
                4,
                Icons.person_outlined,
                Icons.person,
                'Profile',
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    bool hasNotification,
  ) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        // Add haptic feedback
        // HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                // Notification badge
                if (hasNotification && !isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasNewPosts() {
    // In a real app, this would check for unread posts
    return widget.currentIndex != 2; // Mock notification for forum tab
  }
}
