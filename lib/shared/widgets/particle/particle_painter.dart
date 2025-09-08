import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'particle_model.dart';

/// 粒子效果绘制器
/// 负责在画布上绘制粒子动画效果
class ParticlePainter extends CustomPainter {
  /// 粒子列表
  final List<ParticleModel> particles;

  /// 构造函数，接收粒子列表
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    // 创建半透明白色画笔，用于绘制粒子
    final paint = Paint()..color = Colors.white.withAlpha(50);

    // 遍历所有粒子并绘制
    for (var particle in particles) {
      // 获取粒子当前动画进度
      final progress = particle.progress();
      // 根据进度计算粒子当前位置
      final Movie animation = particle.tween.transform(progress);
      final position = Offset(
        animation.get<double>(ParticleOffsetProps.x) * size.width,
        animation.get<double>(ParticleOffsetProps.y) * size.height,
      );
      // 在计算出的位置绘制圆形粒子
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // 始终重绘以保持动画流畅
}
