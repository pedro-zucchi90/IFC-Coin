import 'package:flutter/material.dart';
import 'dart:math';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final int numberOfParticles = 50;
  final double maxDistance = 300;
  Size? screenSize;
  double? devicePixelRatio;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(hours: 1))
          ..addListener(_updateParticles)
          ..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa partículas apenas uma vez, quando o contexto estiver disponível
    if (_particles.isEmpty) {
      screenSize = MediaQuery.of(context).size;
      devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final random = Random();
      for (var i = 0; i < numberOfParticles; i++) {
        _particles.add(
          Particle(
            position: Offset(
              random.nextDouble() * screenSize!.width * devicePixelRatio!,
              random.nextDouble() * screenSize!.height * devicePixelRatio!,
            ),
            velocity: Offset(
              random.nextDouble() * 2 - 1,
              random.nextDouble() * 2 - 1,
            ),
          ),
        );
      }
    }
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.update(screenSize!, devicePixelRatio!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Garante que screenSize e devicePixelRatio estejam atualizados
    screenSize = MediaQuery.of(context).size;
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Container(
      color: const Color(0xFFEAF2FB),
      child: CustomPaint(
        painter: ParticlePainter(
          particles: _particles,
          maxDistance: maxDistance,
          devicePixelRatio: devicePixelRatio ?? 1.0,
        ),
        child: Container(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Particle {
  Offset position;
  Offset velocity;

  Particle({required this.position, required this.velocity});

  void update(Size screenSize, double devicePixelRatio) {
    position += velocity;

    final width = screenSize.width * devicePixelRatio;
    final height = screenSize.height * devicePixelRatio;

    // Bounce on edges
    if (position.dx <= 0 || position.dx >= width) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy <= 0 || position.dy >= height) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double maxDistance;
  final double devicePixelRatio;

  ParticlePainter({
    required this.particles,
    required this.maxDistance,
    required this.devicePixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.indigo;

    for (var p in particles) {
      canvas.drawCircle(p.position / devicePixelRatio, 1, paint);
    }

    for (var i = 0; i < particles.length; i++) {
      for (var j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;
        if (distance < maxDistance) {
          final opacity = ((1 - (distance / maxDistance)) * 0.3).clamp(0.0, 1.0);
          final baseColor = Colors.indigo;
          final blendedColor = Color.alphaBlend(
            baseColor.withAlpha((opacity * 255).toInt()),
            Colors.transparent,
          );
          final linePaint = Paint()
            ..color = blendedColor
            ..strokeWidth = 1;
          canvas.drawLine(
            particles[i].position / devicePixelRatio,
            particles[j].position / devicePixelRatio,
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}