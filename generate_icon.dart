import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a custom painter for the icon
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 512, 512));

  // Background
  final bgPaint = Paint()..color = Color(0xFFF5F5DC);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 512, 512),
      Radius.circular(80),
    ),
    bgPaint,
  );

  // Orange color
  final orangePaint = Paint()
    ..color = Color(0xFFE57330)
    ..style = PaintingStyle.fill;

  final orangeStroke = Paint()
    ..color = Color(0xFFE57330)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12;

  // Draw monitor frame
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(136, 120, 240, 150),
      Radius.circular(20),
    ),
    orangeStroke,
  );

  // Draw chart bars
  canvas.drawRect(Rect.fromLTWH(176, 200, 30, 40), orangePaint);
  canvas.drawRect(Rect.fromLTWH(221, 170, 30, 70), orangePaint);
  canvas.drawRect(Rect.fromLTWH(266, 180, 30, 60), orangePaint);
  canvas.drawRect(Rect.fromLTWH(311, 150, 30, 90), orangePaint);

  // Draw monitor stand
  canvas.drawRect(Rect.fromLTWH(241, 270, 30, 35), orangePaint);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(196, 305, 120, 12),
      Radius.circular(6),
    ),
    orangePaint,
  );

  // Draw text "9SOFT"
  final textPainter = TextPainter(
    text: TextSpan(
      text: '9SOFT',
      style: TextStyle(
        color: Color(0xFFE57330),
        fontSize: 80,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(256 - textPainter.width / 2, 350));

  // Draw subtitle
  final subtitlePainter = TextPainter(
    text: TextSpan(
      text: 'نظام إدارة المبيعات',
      style: TextStyle(
        color: Color(0xFFE57330),
        fontSize: 28,
      ),
    ),
    textDirection: TextDirection.rtl,
  );
  subtitlePainter.layout();
  subtitlePainter.paint(canvas, Offset(256 - subtitlePainter.width / 2, 410));

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(512, 512);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file =
      File('c:\\Users\\HS_RW\\Desktop\\de3\\assets\\images\\app_icon.png');
  await file.writeAsBytes(buffer);

  print('✅ تم إنشاء ملف الأيقونة بنجاح!');
  print('📁 الموقع: ${file.path}');
}
