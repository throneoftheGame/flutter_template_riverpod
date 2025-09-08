import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

/// 粒子偏移属性枚举
/// 用于定义粒子在 X 和 Y 轴上的位置属性
enum ParticleOffsetProps { x, y }

/// 粒子模型类
/// 管理单个粒子的动画状态、位置、大小等属性
class ParticleModel {
  /// 粒子动画补间对象
  late MovieTween tween;

  /// 粒子大小
  late double size;

  /// 动画持续时间
  late Duration duration;

  /// 动画开始时间
  late Duration startTime;

  /// 随机数生成器
  final Random random;

  /// 构造函数，初始化粒子并开始动画
  ParticleModel(this.random) {
    restart(); // 重启粒子动画
    shuffle(); // 随机化开始时间
  }

  /// 重新开始粒子动画
  /// 设置新的起始和结束位置，重新计算动画参数
  restart() {
    // 设置粒子从底部随机位置开始，向上移动到顶部随机位置
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);

    // 创建 X 和 Y 轴的动画补间
    tween = MovieTween()
      ..tween(
        ParticleOffsetProps.x,
        Tween(begin: startPosition.dx, end: endPosition.dx),
        duration: 2.seconds,
      )
      ..tween(
        ParticleOffsetProps.y,
        Tween(begin: startPosition.dy, end: endPosition.dy),
        duration: 2.seconds,
      );

    // 设置随机的动画持续时间（3-9秒）
    duration = 3000.milliseconds + random.nextInt(6000).milliseconds;
    startTime = DateTime.now().duration();

    // 设置随机的粒子大小（0.2-0.6倍）
    size = 0.2 + random.nextDouble() * 0.4;
  }

  /// 随机化粒子开始时间
  /// 避免所有粒子同时开始动画，创造更自然的效果
  void shuffle() {
    startTime -= (random.nextDouble() * duration.inMilliseconds)
        .round()
        .milliseconds;
  }

  /// 检查粒子是否需要重新开始
  /// 当动画完成时自动重启粒子
  checkIfParticleNeedsToBeRestarted() {
    if (progress() == 1.0) {
      restart();
    }
  }

  /// 计算粒子当前动画进度
  /// 返回 0.0 到 1.0 之间的值，表示动画完成度
  double progress() {
    return ((DateTime.now().duration() - startTime) / duration)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
