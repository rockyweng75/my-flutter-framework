import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BalloonShootingGamePage extends StatefulWidget {
  const BalloonShootingGamePage({super.key});

  @override
  State<BalloonShootingGamePage> createState() => _BalloonShootingGamePageState();
}

class _BalloonShootingGamePageState extends State<BalloonShootingGamePage> with SingleTickerProviderStateMixin {
  final double _arrowWidth = 40;
  final double _arrowHeight = 60;
  final double _balloonRadius = 30;
  final int _maxBalloons = 5;
  final Random _random = Random();

  double _arrowX = 0.5; // 0~1, 百分比
  double? _arrowY; // 射出時才有值
  bool _isArrowFlying = false;
  int _score = 0;
  List<_Balloon> _balloons = [];
  Timer? _gameTimer;
  Timer? _arrowTimer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _arrowTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _balloons = [];
    _spawnBalloons();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (_) => _updateBalloons());
  }

  void _spawnBalloons() {
    while (_balloons.length < _maxBalloons) {
      _balloons.add(_Balloon(
        x: _random.nextDouble(),
        y: 1.1 + _random.nextDouble() * 0.5, // 從畫面下方生成
        speed: 0.005 + _random.nextDouble() * 0.005,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
      ));
    }
  }

  void _updateBalloons() {
    setState(() {
      for (final balloon in _balloons) {
        balloon.y -= balloon.speed;
      }
      _balloons.removeWhere((b) => b.y + _balloonRadius / 400 < 0);
      _spawnBalloons();
      if (_isArrowFlying && _arrowY != null) {
        _arrowY = _arrowY! - 0.03;
        // 檢查碰撞
        for (final balloon in List<_Balloon>.from(_balloons)) {
          if ((balloon.x - _arrowX).abs() < 0.07 && (balloon.y - _arrowY!).abs() < 0.08) {
            _score++;
            _balloons.remove(balloon);
            _isArrowFlying = false;
            _arrowY = null;
            break;
          }
        }
        // 超出畫面
        if (_arrowY != null && _arrowY! < -0.1) {
          _isArrowFlying = false;
          _arrowY = null;
        }
      }
    });
  }

  void _moveArrow(double dx) {
    setState(() {
      _arrowX = (_arrowX + dx).clamp(0.0, 1.0);
    });
  }

  void _shootArrow() {
    if (_isArrowFlying) return;
    setState(() {
      _isArrowFlying = true;
      _arrowY = 0.85;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      appBar: AppBar(
        title: const Text('弓箭射氣球'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startGame,
            tooltip: '重新開始',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              // 氣球
              ..._balloons.map((b) => Positioned(
                left: b.x * (width - _balloonRadius * 2),
                top: b.y * height - _balloonRadius,
                child: _BalloonWidget(radius: _balloonRadius, color: b.color),
              )),
              // 弓箭
              if (!_isArrowFlying)
                Positioned(
                  left: _arrowX * (width - _arrowWidth),
                  top: height * 0.85,
                  child: _ArrowWidget(width: _arrowWidth, height: _arrowHeight),
                ),
              // 飛行中的箭
              if (_isArrowFlying && _arrowY != null)
                Positioned(
                  left: _arrowX * (width - _arrowWidth),
                  top: _arrowY! * height,
                  child: _ArrowWidget(width: _arrowWidth, height: _arrowHeight),
                ),
              // 控制區
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final btnWidth = (constraints.maxWidth - 64) / 3;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: btnWidth,
                            child: ElevatedButton(
                              onPressed: () => _moveArrow(-0.05),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.arrow_left, size: 36),
                            ),
                          ),
                          SizedBox(
                            width: btnWidth,
                            child: ElevatedButton(
                              onPressed: _shootArrow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('射擊'),
                            ),
                          ),
                          SizedBox(
                            width: btnWidth,
                            child: ElevatedButton(
                              onPressed: () => _moveArrow(0.05),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.arrow_right, size: 36),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // 分數
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('分數：$_score', style: const TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Balloon {
  double x;
  double y;
  double speed;
  Color color;
  _Balloon({required this.x, required this.y, required this.speed, required this.color});
}

class _BalloonWidget extends StatelessWidget {
  final double radius;
  final Color color;
  const _BalloonWidget({required this.radius, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 6,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowWidget extends StatelessWidget {
  final double width;
  final double height;
  const _ArrowWidget({required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ArrowPainter(),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    // 箭身
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width / 2, 10), paint);
    // 箭頭
    final arrowHead = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2 - 10, 20);
    path.lineTo(size.width / 2 + 10, 20);
    path.close();
    canvas.drawPath(path, arrowHead);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
