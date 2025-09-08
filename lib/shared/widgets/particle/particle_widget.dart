import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'particle_model.dart';
import 'particle_painter.dart';

/// 粒子效果组件
/// 在背景中显示飘动的粒子动画效果，增强视觉体验
class ParticlesWidget extends StatefulWidget {
  /// 粒子数量
  final int numberOfParticles;

  /// 构造函数，指定粒子数量
  const ParticlesWidget(this.numberOfParticles, {super.key});

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

/// 粒子组件状态类
/// 管理粒子的生命周期和动画循环
class _ParticlesWidgetState extends State<ParticlesWidget>
    with WidgetsBindingObserver {
  /// 随机数生成器，用于创建随机粒子效果
  final Random random = Random();

  /// 粒子列表，存储所有活跃的粒子对象
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    super.initState();
    // 根据指定数量创建粒子对象
    for (int i = 0; i < widget.numberOfParticles; i++) {
      particles.add(ParticleModel(random));
    }
    // 注册应用生命周期观察者，用于处理应用切换
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除应用生命周期观察者，防止内存泄漏
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用从后台切回前台时重置粒子状态
    // 确保动画能够正常继续播放
    if (state == AppLifecycleState.resumed) {
      for (var particle in particles) {
        particle.restart(); // 重启粒子动画
        particle.shuffle(); // 重新随机化时间
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用循环动画构建器来持续更新粒子状态
    return LoopAnimationBuilder(
      tween: ConstantTween(1), // 常量补间，用于触发重绘
      duration: const Duration(seconds: 1), // 每秒更新一次
      builder: (context, child, dynamic _) {
        _simulateParticles(); // 模拟粒子运动
        return CustomPaint(
          painter: ParticlePainter(particles), // 使用自定义画笔绘制粒子
        );
      },
    );
  }

  /// 模拟粒子运动
  /// 检查每个粒子是否需要重新开始动画
  void _simulateParticles() {
    for (var particle in particles) {
      particle.checkIfParticleNeedsToBeRestarted();
    }
  }
}
