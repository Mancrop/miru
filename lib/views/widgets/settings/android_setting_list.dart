import 'package:flutter/material.dart';

class AndroidSettingList extends StatefulWidget {
  const AndroidSettingList({
    super.key,
    required this.icon,
    required this.mainTitle,
    required this.children,
  });

  final Widget icon;
  final String mainTitle;
  final List<Widget> children;

  @override
  State<AndroidSettingList> createState() => _AndroidSettingListState();
}

class _AndroidSettingListState extends State<AndroidSettingList>
    with SingleTickerProviderStateMixin {
  // Default to expanded for Updates section to match screenshot
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Animation curve: starts with initial velocity, accelerates in the middle, slows down rapidly at the end
  static final Animatable<double> _customTween = 
      CurveTween(curve: Curves.easeInOut);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<Offset> _slideTween =
      Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero);
  @override
  void initState() {
    super.initState();
    // Open the Updates section by default to match screenshot
    _isExpanded = widget.mainTitle == "Updates" || widget.mainTitle == "Display";
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
    
    _iconTurns = _controller.drive(_halfTween.chain(_customTween));
    _fadeAnimation = _controller.drive(_customTween);
    _slideAnimation = _controller.drive(_slideTween.chain(_customTween));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  Widget _buildHeader() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      ),
      onPressed: _toggleExpansion,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              child: widget.icon,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.mainTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RotationTransition(
            turns: _iconTurns,
            child: Icon(
              Icons.expand_more,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContent() {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _controller,
        axis: Axis.vertical,
        axisAlignment: 0.0,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildContent(),
      ],
    );
  }
}
