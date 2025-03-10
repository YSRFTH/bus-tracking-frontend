import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> generateAssets() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Generate logo
  await _generateLogo(canvas, recorder, 'assets/logo.png');
  
  // Generate tutorial images
  await _generateTutorial1(canvas, recorder, 'assets/tutorial_1.png');
  await _generateTutorial2(canvas, recorder, 'assets/tutorial_2.png');
  await _generateTutorial3(canvas, recorder, 'assets/tutorial_3.png');
  
  // Generate social icons
  await _generateSocialIcon(canvas, recorder, 'assets/google.png', 'G');
  await _generateSocialIcon(canvas, recorder, 'assets/facebook.png', 'f');
}

Future<void> _generateLogo(Canvas canvas, ui.PictureRecorder recorder, String filePath) async {
  const size = Size(200, 200);
  canvas.drawColor(Colors.transparent, BlendMode.clear);
  
  final paint = Paint()
    ..color = const Color(0xFFD2B48C)
    ..style = PaintingStyle.fill;
    
  // Draw bus shape
  final busPath = Path()
    ..moveTo(50, 100)
    ..lineTo(150, 100)
    ..lineTo(150, 150)
    ..lineTo(50, 150)
    ..close();
    
  canvas.drawPath(busPath, paint);
  
  // Draw wheels
  canvas.drawCircle(const Offset(70, 150), 15, paint);
  canvas.drawCircle(const Offset(130, 150), 15, paint);
  
  await _savePicture(recorder, size, filePath);
}

Future<void> _generateTutorial1(Canvas canvas, ui.PictureRecorder recorder, String path) async {
  const size = Size(300, 300);
  canvas.drawColor(Colors.transparent, BlendMode.clear);
  
  final paint = Paint()
    ..color = const Color(0xFFD2B48C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
    
  canvas.drawCircle(const Offset(150, 150), 100, paint);
  canvas.drawLine(
    const Offset(150, 150),
    const Offset(150, 70),
    paint..style = PaintingStyle.fill,
  );
  
  await _savePicture(recorder, size, path);
}

Future<void> _generateTutorial2(Canvas canvas, ui.PictureRecorder recorder, String path) async {
  const size = Size(300, 300);
  canvas.drawColor(Colors.transparent, BlendMode.clear);
  
  final paint = Paint()
    ..color = const Color(0xFFD2B48C)
    ..style = PaintingStyle.fill;
    
  canvas.drawCircle(const Offset(150, 150), 80, paint);
  canvas.drawRect(
    const Rect.fromLTWH(120, 100, 60, 100),
    paint..color = Colors.white,
  );
  
  await _savePicture(recorder, size, path);
}

Future<void> _generateTutorial3(Canvas canvas, ui.PictureRecorder recorder, String path) async {
  const size = Size(300, 300);
  canvas.drawColor(Colors.transparent, BlendMode.clear);
  
  final paint = Paint()
    ..color = const Color(0xFFD2B48C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
    
  canvas.drawLine(
    const Offset(50, 150),
    const Offset(250, 150),
    paint,
  );
  canvas.drawCircle(const Offset(150, 150), 20, paint..style = PaintingStyle.fill);
  
  await _savePicture(recorder, size, path);
}

Future<void> _generateSocialIcon(Canvas canvas, ui.PictureRecorder recorder, String path, String letter) async {
  const size = Size(100, 100);
  canvas.drawColor(Colors.transparent, BlendMode.clear);
  
  final paint = Paint()
    ..color = const Color(0xFFD2B48C)
    ..style = PaintingStyle.fill;
    
  canvas.drawCircle(const Offset(50, 50), 40, paint);
  
  final textPainter = TextPainter(
    text: TextSpan(
      text: letter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  
  textPainter.paint(
    canvas,
    Offset(
      50 - textPainter.width / 2,
      50 - textPainter.height / 2,
    ),
  );
  
  await _savePicture(recorder, size, path);
}

Future<void> _savePicture(ui.PictureRecorder recorder, Size size, String path) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  final file = File(path);
  await file.writeAsBytes(buffer);
  
  // Reset recorder for next use
  recorder.endRecording();
} 