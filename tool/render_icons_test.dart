// Explicit original vector rasterization task, not part of the normal test suite.
// Run: flutter test tool/render_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('render the original Loop arc into reviewed native assets', () async {
    final sizes = <String, int>{
      for (final entry in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      }.entries)
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png':
            entry.value,
    };
    const iosRoot = 'ios/Runner/Assets.xcassets';
    final Object? decoded = jsonDecode(
      await File('$iosRoot/AppIcon.appiconset/Contents.json').readAsString(),
    );
    final contents = decoded! as Map<String, dynamic>;
    for (final image in contents['images'] as List<dynamic>) {
      final spec = image as Map<String, dynamic>;
      final dimension = double.parse((spec['size'] as String).split('x').first);
      final scale = double.parse((spec['scale'] as String).replaceAll('x', ''));
      sizes['$iosRoot/AppIcon.appiconset/${spec['filename']}'] =
          (dimension * scale).round();
    }
    for (var scale = 1; scale <= 3; scale++) {
      final suffix = scale == 1 ? '' : '@${scale}x';
      sizes['$iosRoot/LaunchImage.imageset/LaunchImage$suffix.png'] =
          96 * scale;
    }
    for (final entry in sizes.entries) {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final dimension = entry.value.toDouble();
      canvas.scale(dimension / 1024);
      canvas.drawColor(const Color(0xFFF7F8FA), BlendMode.src);
      // Same original circular open arc as assets/branding/loop-mark.svg,
      // inset to 70% for app-icon/launcher mask safety. No imported artwork.
      canvas.translate(153.6, 153.6);
      canvas.scale(0.7);
      canvas.drawArc(
        const Rect.fromLTWH(104, 104, 816, 816),
        -math.pi / 3,
        math.pi * 5 / 3,
        false,
        Paint()
          ..color = const Color(0xFF365CF5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 110
          ..strokeCap = StrokeCap.round,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(entry.value, entry.value);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      await File(entry.key).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    }
    expect(sizes.length, 23);
  });
}
