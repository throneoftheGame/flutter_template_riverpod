import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Riverpod 观察者，用于调试状态变化
class TalkerRiverpodObserver extends ProviderObserver {
  const TalkerRiverpodObserver({required this.talker});

  final Talker talker;

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    talker.debug('Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    talker.debug('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    talker.debug(
      'Provider updated: ${provider.name ?? provider.runtimeType}\n'
      'Previous: $previousValue\n'
      'New: $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    talker.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}
