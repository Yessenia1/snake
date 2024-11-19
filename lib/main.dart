import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  String direction = 'right';
  Timer? timer;
  final double gridSize = 20.0;
  bool gameOver = false;

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!gameOver) {
        moveSnake();
      } else {
        timer.cancel();
      }
    });
  }

  void moveSnake() {
    setState(() {
      Offset newHead = snake.first;

      // Actualiza la posición de la serpiente según la dirección
      switch (direction) {
        case 'up':
          newHead = Offset(newHead.dx, newHead.dy - 1);
          break;
        case 'down':
          newHead = Offset(newHead.dx, newHead.dy + 1);
          break;
        case 'left':
          newHead = Offset(newHead.dx - 1, newHead.dy);
          break;
        case 'right':
          newHead = Offset(newHead.dx + 1, newHead.dy);
          break;
      }

      // Verifica colisiones con la comida
      if (newHead == food) {
        snake.insert(0, newHead);
        generateFood();
      } else {
        snake.insert(0, newHead);
        snake.removeLast();
      }

      // Verifica colisiones con el borde o consigo misma
      if (newHead.dx < 0 || newHead.dy < 0 || newHead.dx >= gridSize || newHead.dy >= gridSize || snake.skip(1).contains(newHead)) {
        gameOver = true;
      }
    });
  }

  void generateFood() {
    Random random = Random();
    food = Offset(random.nextInt(19).toDouble(), random.nextInt(19).toDouble());
  }

  void changeDirection(String newDirection) {
    setState(() {
      if ((direction == 'up' && newDirection != 'down') ||
          (direction == 'down' && newDirection != 'up') ||
          (direction == 'left' && newDirection != 'right') ||
          (direction == 'right' && newDirection != 'left')) {
        direction = newDirection;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.lightBlueAccent,
              child: Center(
                child: Container(
                  width: 400,
                  height: 440,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.white,
                  ),
                  child: CustomPaint(
                    painter: SnakePainter(snake, food, gameOver),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          if (!gameOver) buildControlButtons(), // Botones de dirección
        ],
      ),
      floatingActionButton: gameOver
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            snake = [Offset(5, 5)];
            direction = 'right';
            gameOver = false;
            startGame();
          });
        },
        child: Icon(Icons.replay),
      )
          : null,
    );
  }

  Widget buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => changeDirection('up'),
                icon: Icon(Icons.keyboard_arrow_up, size: 40),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => changeDirection('left'),
                icon: Icon(Icons.keyboard_arrow_left, size: 40),
              ),
              SizedBox(width: 20),
              IconButton(
                onPressed: () => changeDirection('right'),
                icon: Icon(Icons.keyboard_arrow_right, size: 40),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => changeDirection('down'),
                icon: Icon(Icons.keyboard_arrow_down, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final bool gameOver;

  SnakePainter(this.snake, this.food, this.gameOver);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final foodPaint = Paint()..color = Colors.red;

    // Dibuja la serpiente
    for (var segment in snake) {
      canvas.drawRect(Rect.fromLTWH(segment.dx * 20, segment.dy * 20, 20, 20), paint);
    }

    // Manzana
    canvas.drawRect(Rect.fromLTWH(food.dx * 20, food.dy * 20, 20, 20), foodPaint);

    // Texto de "Game Over"
    if (gameOver) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Game Over xd',
          style: TextStyle(color: Colors.red, fontSize: 40),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
