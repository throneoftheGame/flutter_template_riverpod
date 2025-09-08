import 'dart:io';
import 'dart:convert';

/// 国际化文件合并构建脚本
/// 
/// 功能：
/// 1. 自动扫描 modules/ 目录下的所有模块
/// 2. 合并每个语言的所有模块文件
/// 3. 生成到 generated/ 目录供 Flutter 使用
/// 
/// 使用方法：
/// dart run lib/l10n/build_i18n.dart
void main() async {
  print('🌍 开始构建国际化文件...');
  
  try {
    final builder = I18nBuilder();
    await builder.build();
    print('✅ 国际化文件构建完成！');
  } catch (e) {
    print('❌ 构建失败: $e');
    exit(1);
  }
}

class I18nBuilder {
  static const String modulesDir = 'lib/l10n/modules';
  static const String generatedDir = 'lib/l10n/generated';
  static const List<String> supportedLocales = ['en', 'zh'];
  
  /// 构建国际化文件
  Future<void> build() async {
    // 确保生成目录存在
    final genDir = Directory(generatedDir);
    if (!genDir.existsSync()) {
      genDir.createSync(recursive: true);
    }
    
    // 扫描所有模块
    final modules = await _scanModules();
    print('📦 发现模块: ${modules.join(', ')}');
    
    // 为每种语言生成合并文件
    for (final locale in supportedLocales) {
      await _buildLocaleFile(locale, modules);
      print('🔄 已生成 $locale 语言文件');
    }
  }
  
  /// 扫描模块目录，返回所有模块名称
  Future<List<String>> _scanModules() async {
    final modulesDirectory = Directory(modulesDir);
    if (!modulesDirectory.existsSync()) {
      throw Exception('模块目录不存在: $modulesDir');
    }
    
    final modules = <String>[];
    await for (final entity in modulesDirectory.list()) {
      if (entity is Directory) {
        final moduleName = entity.path.split('/').last;
        modules.add(moduleName);
      }
    }
    
    modules.sort(); // 确保模块顺序一致
    return modules;
  }
  
  /// 为指定语言构建合并文件
  Future<void> _buildLocaleFile(String locale, List<String> modules) async {
    final merged = <String, dynamic>{};
    
    // 添加语言标识
    merged['@@locale'] = locale;
    
    // 合并所有模块的翻译
    for (final module in modules) {
      final moduleFile = File('$modulesDir/$module/${module}_$locale.arb');
      if (moduleFile.existsSync()) {
        try {
          final content = await moduleFile.readAsString();
          final moduleData = json.decode(content) as Map<String, dynamic>;
          
          // 移除 @@locale 标识，避免重复
          moduleData.remove('@@locale');
          
          // 检查键冲突
          for (final key in moduleData.keys) {
            if (merged.containsKey(key)) {
              print('⚠️  警告: 发现重复的键 "$key" 在模块 $module 中');
            }
          }
          
          // 合并数据
          merged.addAll(moduleData);
          
        } catch (e) {
          print('❌ 解析模块文件失败: $moduleFile.path - $e');
          continue;
        }
      } else {
        print('⚠️  模块文件不存在: $moduleFile.path');
      }
    }
    
    // 写入合并后的文件
    final outputFile = File('$generatedDir/app_$locale.arb');
    const encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(merged));
    
    print('📝 已生成: ${outputFile.path} (${merged.length - 1} 个键)');
  }
}

