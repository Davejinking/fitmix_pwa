import 'package:flutter/material.dart';

/// RPG 스타일 장비 아이콘 위젯
class RPGEquipmentIcons {
  /// 투구 (Helmet)
  static Widget helmet({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HelmetPainter(color: color),
    );
  }

  /// 갑옷 (Armor/Chest)
  static Widget armor({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ArmorPainter(color: color),
    );
  }

  /// 바지 (Pants/Legs)
  static Widget pants({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PantsPainter(color: color),
    );
  }

  /// 장갑 (Gloves)
  static Widget gloves({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GlovesPainter(color: color),
    );
  }

  /// 부츠 (Boots)
  static Widget boots({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BootsPainter(color: color),
    );
  }

  /// 벨트 (Belt)
  static Widget belt({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BeltPainter(color: color),
    );
  }

  /// 반지/방패 (Ring/Shield)
  static Widget shield({Color color = Colors.grey, double size = 32}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShieldPainter(color: color),
    );
  }
}

/// 투구 페인터
class _HelmetPainter extends CustomPainter {
  final Color color;
  _HelmetPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // 투구 상단 (둥근 모양)
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.2,
      size.width * 0.5, size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.2,
      size.width * 0.8, size.height * 0.5,
    );
    
    // 투구 하단 (뺨 보호대)
    path.lineTo(size.width * 0.75, size.height * 0.7);
    path.lineTo(size.width * 0.65, size.height * 0.85);
    path.lineTo(size.width * 0.35, size.height * 0.85);
    path.lineTo(size.width * 0.25, size.height * 0.7);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 눈 구멍
    final eyePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.45, size.width * 0.15, size.height * 0.08),
      eyePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.45, size.width * 0.15, size.height * 0.08),
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 갑옷 페인터
class _ArmorPainter extends CustomPainter {
  final Color color;
  _ArmorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // 갑옷 상단 (어깨)
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.7, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    
    // 갑옷 몸통
    path.lineTo(size.width * 0.85, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.85,
      size.width * 0.65, size.height * 0.9,
    );
    path.lineTo(size.width * 0.35, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.85,
      size.width * 0.15, size.height * 0.7,
    );
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 중앙 라인 (디테일)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 바지 페인터
class _PantsPainter extends CustomPainter {
  final Color color;
  _PantsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // 허리 부분
    path.moveTo(size.width * 0.2, size.height * 0.15);
    path.lineTo(size.width * 0.8, size.height * 0.15);
    
    // 왼쪽 다리
    path.moveTo(size.width * 0.25, size.height * 0.15);
    path.lineTo(size.width * 0.3, size.height * 0.9);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.45, size.height * 0.15);
    
    // 오른쪽 다리
    path.moveTo(size.width * 0.55, size.height * 0.15);
    path.lineTo(size.width * 0.6, size.height * 0.9);
    path.lineTo(size.width * 0.7, size.height * 0.9);
    path.lineTo(size.width * 0.75, size.height * 0.15);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 장갑 페인터
class _GlovesPainter extends CustomPainter {
  final Color color;
  _GlovesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 손목 부분
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.15, size.width * 0.4, size.height * 0.2),
      paint,
    );
    
    // 손바닥
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.35);
    path.lineTo(size.width * 0.25, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.7,
      size.width * 0.35, size.height * 0.75,
    );
    path.lineTo(size.width * 0.65, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.7,
      size.width * 0.75, size.height * 0.6,
    );
    path.lineTo(size.width * 0.7, size.height * 0.35);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 손가락 (간단하게 3개)
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.35 + i * 0.15);
      canvas.drawLine(
        Offset(x, size.height * 0.75),
        Offset(x, size.height * 0.9),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 부츠 페인터
class _BootsPainter extends CustomPainter {
  final Color color;
  _BootsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // 왼쪽 부츠
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.15, size.height * 0.75);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.35, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.close();
    
    // 오른쪽 부츠
    path.moveTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.65, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(size.width * 0.85, size.height * 0.75);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 벨트 페인터
class _BeltPainter extends CustomPainter {
  final Color color;
  _BeltPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 벨트 스트랩
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.2),
      paint,
    );
    
    // 버클 (중앙)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.35, size.width * 0.2, size.height * 0.3),
      paint,
    );
    
    // 버클 중앙 구멍
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.06,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 방패 페인터
class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // 방패 외곽
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width * 0.85, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.9);
    path.lineTo(size.width * 0.15, size.height * 0.6);
    path.lineTo(size.width * 0.15, size.height * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 중앙 십자가
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.7),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.45),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
