
import 'package:flutter/cupertino.dart';

class SkeletonPulsar extends StatefulWidget {
  final Widget child;
  const SkeletonPulsar({required this.child});

  @override
  State<SkeletonPulsar> createState() => _SkeletonPulsarState();
}

class _SkeletonPulsarState extends State<SkeletonPulsar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: widget.child,
    );
  }
}