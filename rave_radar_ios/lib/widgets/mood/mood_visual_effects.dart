import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/mood_model.dart';

class MoodVisualEffect extends StatefulWidget {
  final MoodEffect effect;
  final Color color;
  final bool isActive;
  final double size;
  
  const MoodVisualEffect({
    super.key,
    required this.effect,
    required this.color,
    this.isActive = true,
    this.size = 200,
  });

  @override
  State<MoodVisualEffect> createState() => _MoodVisualEffectState();
}

class _MoodVisualEffectState extends State<MoodVisualEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _secondaryController;
  late Animation<double> _animation;
  late Animation<double> _secondaryAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isActive) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    switch (widget.effect) {
      case MoodEffect.pulsingFlames:
        _controller = AnimationController(
          duration: const Duration(milliseconds: 800),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _secondaryController = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _secondaryController, curve: Curves.easeOut),
        );
        break;
        
      case MoodEffect.shimmeringParticles:
        _controller = AnimationController(
          duration: const Duration(seconds: 3),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
        _secondaryController = AnimationController(
          duration: const Duration(milliseconds: 1500),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: 0.5, end: 1).animate(
          CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
        );
        break;
        
      case MoodEffect.rippleGlitch:
        _controller = AnimationController(
          duration: const Duration(milliseconds: 1200),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _secondaryController = AnimationController(
          duration: const Duration(milliseconds: 100),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: -5, end: 5).animate(_secondaryController);
        break;
        
      case MoodEffect.electricSparks:
        _controller = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
        _secondaryController = AnimationController(
          duration: const Duration(milliseconds: 50),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_secondaryController);
        break;
        
      case MoodEffect.strobeFlash:
        _controller = AnimationController(
          duration: const Duration(milliseconds: 100),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
        _secondaryController = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: 0.2, end: 1).animate(_secondaryController);
        break;
        
      default:
        _controller = AnimationController(
          duration: const Duration(seconds: 2),
          vsync: this,
        );
        _animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _secondaryController = AnimationController(
          duration: const Duration(seconds: 1),
          vsync: this,
        );
        _secondaryAnimation = Tween<double>(begin: 0.8, end: 1).animate(_secondaryController);
    }
  }

  void _startAnimation() {
    switch (widget.effect) {
      case MoodEffect.pulsingFlames:
      case MoodEffect.shimmeringParticles:
      case MoodEffect.electricSparks:
        _controller.repeat(reverse: true);
        _secondaryController.repeat(reverse: true);
        break;
      case MoodEffect.rippleGlitch:
        _controller.repeat();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _secondaryController.repeat(reverse: true);
          }
        });
        break;
      case MoodEffect.strobeFlash:
        _controller.repeat();
        _secondaryController.repeat(reverse: true);
        break;
      default:
        _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _secondaryAnimation]),
      builder: (context, child) {
        return _buildEffect();
      },
    );
  }

  Widget _buildEffect() {
    switch (widget.effect) {
      case MoodEffect.pulsingFlames:
        return _buildPulsingFlames();
      case MoodEffect.shimmeringParticles:
        return _buildShimmeringParticles();
      case MoodEffect.rippleGlitch:
        return _buildRippleGlitch();
      case MoodEffect.electricSparks:
        return _buildElectricSparks();
      case MoodEffect.strobeFlash:
        return _buildStrobeFlash();
      case MoodEffect.rainbowWave:
        return _buildRainbowWave();
      case MoodEffect.sparkleRain:
        return _buildSparkleRain();
      case MoodEffect.bassThump:
        return _buildBassThump();
      default:
        return _buildDefaultGlow();
    }
  }

  Widget _buildPulsingFlames() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: 0.6),
                  widget.color.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 30 * _animation.value,
                  spreadRadius: 10 * _animation.value,
                ),
              ],
            ),
          ),
        ),
        ...List.generate(5, (index) {
          final angle = (index * 72) * math.pi / 180;
          return Transform.translate(
            offset: Offset(
              math.cos(angle) * 30 * _secondaryAnimation.value,
              math.sin(angle) * 30 * _secondaryAnimation.value,
            ),
            child: Container(
              width: 15,
              height: 30,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                  bottom: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShimmeringParticles() {
    return Stack(
      children: List.generate(12, (index) {
        final angle = (index * 30) * math.pi / 180 + _animation.value;
        final radius = 40 + (index % 3) * 20;
        return Transform.translate(
          offset: Offset(
            math.cos(angle) * radius * _secondaryAnimation.value,
            math.sin(angle) * radius * _secondaryAnimation.value,
          ),
          child: Container(
            width: 6 + (index % 3) * 2,
            height: 6 + (index % 3) * 2,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRippleGlitch() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(3, (index) {
          return Transform.translate(
            offset: Offset(_secondaryAnimation.value * (index - 1), 0),
            child: Container(
              width: widget.size * (1 + _animation.value * 0.5),
              height: widget.size * (1 + _animation.value * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: (1 - _animation.value) * 0.6),
                  width: 2,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildElectricSparks() {
    return Stack(
      children: List.generate(8, (index) {
        final random = math.Random(index);
        return Transform.translate(
          offset: Offset(
            (random.nextDouble() - 0.5) * widget.size,
            (random.nextDouble() - 0.5) * widget.size,
          ),
          child: Transform.scale(
            scale: _secondaryAnimation.value,
            child: Container(
              width: 2,
              height: 20 + random.nextDouble() * 20,
              decoration: BoxDecoration(
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStrobeFlash() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: _animation.value * _secondaryAnimation.value * 0.3),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: _animation.value * 0.6),
            blurRadius: 50,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRainbowWave() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
            Colors.red,
          ],
          transform: GradientRotation(_animation.value * 2 * math.pi),
        ),
      ),
    );
  }

  Widget _buildSparkleRain() {
    return Stack(
      children: List.generate(15, (index) {
        final random = math.Random(index);
        return Transform.translate(
          offset: Offset(
            (random.nextDouble() - 0.5) * widget.size,
            (_animation.value - 0.5) * widget.size,
          ),
          child: Icon(
            Icons.star,
            size: 8 + random.nextDouble() * 8,
            color: widget.color.withValues(alpha: random.nextDouble()),
          ),
        );
      }),
    );
  }

  Widget _buildBassThump() {
    return Transform.scale(
      scale: 1 + _animation.value * 0.3,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 30 * _animation.value,
              spreadRadius: 10 * _animation.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultGlow() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            widget.color.withValues(alpha: 0.6 * _animation.value),
            widget.color.withValues(alpha: 0.3 * _animation.value),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.4),
            blurRadius: 20 * _animation.value,
            spreadRadius: 5 * _animation.value,
          ),
        ],
      ),
    );
  }
}