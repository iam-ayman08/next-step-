import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Advanced UI Components for enhanced user experience

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: opacity)
                : Colors.white.withValues(alpha: opacity + 0.1),
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: opacity - 0.05)
                : Colors.white.withValues(alpha: opacity - 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: blur,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.05),
            spreadRadius: -1,
            blurRadius: blur * 0.5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final IconData? icon;
  final bool isLoading;

  const AnimatedGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [Color(0xFF2196F3), Color(0xFF1976D2)],
    this.icon,
    this.isLoading = false,
  });

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[0].withValues(alpha: 0.3),
                  spreadRadius: 2 + (_glowAnimation.value * 4),
                  blurRadius: 8 + (_glowAnimation.value * 8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingText!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey[300]!, Colors.white, Colors.grey[300]!],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    _startAnimations();
  }

  @override
  void didUpdateWidget(StaggeredAnimationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _disposeControllers();
      _initControllers();
      _startAnimations();
    }
  }

  void _initControllers() {
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerDelay * i);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

class AdvancedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final List<String> suggestions;
  final bool showVoiceSearch;

  const AdvancedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'Search...',
    this.suggestions = const [],
    this.showVoiceSearch = true,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: GoogleFonts.inter(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              onChanged: (value) {
                setState(() => _isSearching = value.isNotEmpty);
                widget.onSearch(value);
              },
              onSubmitted: widget.onSearch,
            ),
          ),
          if (widget.showVoiceSearch) ...[
            AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 48 * _widthAnimation.value,
                  child: Opacity(
                    opacity: _widthAnimation.value,
                    child: IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        // Voice search functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice search coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          if (_isSearching) ...[
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                _controller.clear();
                setState(() => _isSearching = false);
                widget.onSearch('');
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class MorphingFAB extends StatefulWidget {
  final List<FABAction> actions;
  final IconData mainIcon;
  final Color mainColor;

  const MorphingFAB({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.mainColor = const Color(0xFF2196F3),
  });

  @override
  State<MorphingFAB> createState() => _MorphingFABState();
}

class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const FABAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });
}

class _MorphingFABState extends State<MorphingFAB>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Action buttons
        if (_isOpen) ...[
          for (int i = 0; i < widget.actions.length; i++) ...[
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: _isOpen ? 80 + (i * 60) : 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isOpen ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton.extended(
                    heroTag: 'fab_action_$i',
                    onPressed: () {
                      _toggle();
                      widget.actions[i].onPressed();
                    },
                    backgroundColor: widget.actions[i].color,
                    foregroundColor: Colors.white,
                    icon: Icon(widget.actions[i].icon, size: 20),
                    label: Text(
                      widget.actions[i].label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
            ),
          ],
        ],

        // Main FAB
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FloatingActionButton(
                onPressed: _toggle,
                backgroundColor: widget.mainColor,
                foregroundColor: Colors.white,
                elevation: 8,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: Icon(widget.mainIcon),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class PullToRefreshContainer extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshText;

  const PullToRefreshContainer({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText = 'Pull to refresh',
  });

  @override
  State<PullToRefreshContainer> createState() => _PullToRefreshContainerState();
}

class _PullToRefreshContainerState extends State<PullToRefreshContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _animationController.repeat();
        await widget.onRefresh();
        _animationController.stop();
        _animationController.reset();
      },
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.white,
      displacement: 80,
      child: widget.child,
    );
  }
}

class AdvancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AdvancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<AdvancedBottomNavigation> createState() =>
      _AdvancedBottomNavigationState();
}

class _AdvancedBottomNavigationState extends State<AdvancedBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(AdvancedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildIcon(Widget? icon, bool isSelected) {
    if (icon == null) return const SizedBox.shrink();

    // If it's an Icon widget, extract the IconData
    if (icon is Icon) {
      final iconData = icon.icon;
      if (iconData != null) {
        return Icon(
          iconData,
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          size: 24,
        );
      }
    }

    // If it's an IconData, create an Icon widget
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
        size: 24,
      );
    }

    // For any other widget type, return as is
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;

          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _animations[index].value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIcon(item.icon, isSelected),
                        const SizedBox(height: 4),
                        Text(
                          item.label ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
