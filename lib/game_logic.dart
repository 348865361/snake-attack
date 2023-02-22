import 'dart:async';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  GameLogic(gameLevel) {
    init(gameLevel);
  }
  late Timer timer;
  int speed = 500;
  double width = 500;
  double height = 500;
  late int selectGameLevel;
  bool isPlaying = false;
  late DateTime stopTimer;

  final _snake = BehaviorSubject<List<Map>>();
  final _fruit = BehaviorSubject<Map>();
  final _score = BehaviorSubject<int>();
  final _direction = BehaviorSubject<int>();
  final _fruitblock = BehaviorSubject<List<Map>>();
  final _gameover = BehaviorSubject<bool>();
  final _endTime = BehaviorSubject<int>();

  Stream<List<Map>> get snake => _snake.stream;
  Stream<Map> get fruit => _fruit.stream;
  Stream<int> get score => _score.stream;
  Stream<int> get direction => _direction.stream;
  Stream<List<Map>> get fruitblock => _fruitblock.stream;

  Stream<bool> get gameover => _gameover.stream;
  Stream<int> get endTime => _endTime.stream;
  init(gameLevel) {
    selectGameLevel = gameLevel;

    List<Map> startingSnake = [
      {'x': 10, 'y': 90},
      {'x': 10, 'y': 70},
      {'x': 10, 'y': 50},
      {'x': 10, 'y': 30},
      {'x': 10, 'y': 10},
    ];
    _snake.sink.add(startingSnake);
    _fruit.sink.add({'x': 100, 'y': 100});
    _score.sink.add(0);
    _direction.sink.add(0);
    _fruitblock.sink.add([]);
    _gameover.sink.add(false);
    if (gameLevel == 1) {
      speed = 300;
    }
  }

  updatesSize(double newWidth, double newHeight) {
    width = newWidth;
    height = newHeight;
  }

  startTimer() {
    timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      checkBorderCrash();
      if (selectGameLevel == 3) {
        checkBombCrash();
      }
      if (selectGameLevel == 4) {
        updateDisplayTime();
        checkTimeRemaining();
      }
      checkSnakeCrash();
      checkFruitEaten();
      updateSnakePosition();
    });
  }

  checkTimeRemaining() {
    DateTime now = DateTime.now();
    int difference = stopTimer.difference(now).inSeconds;
    if (difference < 1) {
      setGameOver();
      timer.cancel();
    }
  }

  updateDisplayTime() {
    DateTime now = DateTime.now();
    int difference = stopTimer.difference(now).inSeconds;
    _endTime.sink.add(difference);
  }

  play() {
    isPlaying = true;
    if (selectGameLevel == 4) {
      DateTime now = DateTime.now();
      stopTimer = now.add(
        Duration(seconds: 10),
      );
    }
    timer.cancel();
  }

  pause() {
    isPlaying = false;
    startTimer();
  }

  updateSnakePosition() {
    List<Map> currentSnake = List.from(_snake.value);
    currentSnake.removeLast();

    Map firstPosition = currentSnake[0];
    if (_direction.value == 0) {
      currentSnake
          .insert(0, {'x': firstPosition['x'], 'y': firstPosition['y'] + 20});
    } else if (_direction.value == 1) {
      currentSnake
          .insert(0, {'x': firstPosition['x'] + 20, 'y': firstPosition['y']});
    } else if (_direction.value == 2) {
      currentSnake
          .insert(0, {'x': firstPosition['x'], 'y': firstPosition['y'] - 20});
    } else if (_direction.value == 3) {
      currentSnake
          .insert(0, {'x': firstPosition['x'] - 20, 'y': firstPosition['y']});
    }
    _snake.sink.add(currentSnake);
  }

  checkBorderCrash() {
    double headX = _snake.value[0]['x'];
    double headY = _snake.value[0]['y'];

    if (headX < 0) {
      timer.cancel();

      setGameOver();
    }
    if (headX > width) {
      timer.cancel();

      setGameOver();
    }
    if (headY < 0) {
      timer.cancel();

      setGameOver();
    }
    if (headY > height) {
      timer.cancel();

      setGameOver();
    }
  }

  checkSnakeCrash() {
    Map head = _snake.value[0];

    List<Map> body = List<Map>.from(_snake.value);
    List bodyList = [];
    body.removeAt(0);
    for (int x = 0; body.length > x; x++) {
      bodyList.add(body[x].toString());
    }

    if (bodyList.contains(head.toString())) {
      timer.cancel();
      isPlaying = false;
      setGameOver();
    }
  }

  checkFruitEaten() {
    double fruitX = _fruit.value['x'];
    double fruitY = _fruit.value['y'];
    double headX = _snake.value[0]['x'];
    double headY = _snake.value[0]['y'];

    if (-1 < headX - fruitX &&
        headX - fruitX < 21 &&
        -1 < headY - fruitY &&
        headY - fruitY < 21) {
      if (selectGameLevel == 3) {
        addFruitblock();
      }
      if (selectGameLevel == 4) {
        addTime();
      }
      resetFruit();
      if (selectGameLevel != 4) {
        addSnakeSegment();
      }
      if (selectGameLevel == 2 ||
          selectGameLevel == 3 ||
          selectGameLevel == 4) {
        speedUpTimer();
      }
    }

    if (-1 < fruitX - headX &&
        fruitX - headX < 21 &&
        -1 < fruitY - headY &&
        fruitY - headY < 21) {
      if (selectGameLevel == 3) {
        addFruitblock();
      }
      if (selectGameLevel == 4) {
        addTime();
      }
      resetFruit();

      if (selectGameLevel != 4) {
        addSnakeSegment();
      }
      if (selectGameLevel == 2 ||
          selectGameLevel == 3 ||
          selectGameLevel == 4) {
        speedUpTimer();
      }
    }
  }

  addTime() {
    print('distance to fruit');
    int xDistance = 0;
    int yDistance = 0;
    if (_fruit.value['x'] > _snake.value[0]['x']) {
      xDistance = (_fruit.value['x'] - _snake.value[0]['x']).abs();
    }
    if (_fruit.value['x'] < _snake.value[0]['x']) {
      xDistance = (_snake.value[0]['x'] - _fruit.value['x']).abs();
    }
    if (_fruit.value['y'] > _snake.value[0]['y']) {
      yDistance = (_fruit.value['y'] - _snake.value[0]['y']).abs();
    }
    if (_fruit.value['y'] < _snake.value[0]['y']) {
      yDistance = (_snake.value[0]['y'] - _fruit.value['y']).abs();
    }
    int distance = xDistance + yDistance;
    double bonusTime = distance * speed * 1.15;
    print(distance);
    print(bonusTime);
    stopTimer = stopTimer.add(
      Duration(milliseconds: bonusTime.toInt()),
    );
  }

  addSnakeSegment() {
    List<Map> snake = _snake.value;
    Map newpeice = snake.last;
    snake.add(newpeice);
    _snake.sink.add(snake);
  }

  checkBombCrash() {
    List bombList = _fruitblock.value;
    for (int i = 0; i < bombList.length; i++) {
      double fruitX = bombList[i]['x'];
      double fruitY = bombList[i]['y'];
      double headX = _snake.value.first['x'];
      double headY = _snake.value.first['y'];

      if (-1 < headX - fruitX &&
          headX - fruitX < 21 &&
          -1 < headY - fruitY &&
          headY - fruitY < 21) {
        timer.cancel();

        setGameOver();
      }

      if (-1 < fruitX - headX &&
          fruitX - headX < 21 &&
          -1 < fruitY - headY &&
          fruitY - headY < 21) {
        timer.cancel();

        setGameOver();
      }
    }
  }

  speedUpTimer() {
    timer.cancel();
    speed = speed - 15;
    startTimer();
  }

  addFruitblock() {
    Map thisFruit = _fruit.value;
    List<Map> newList = _fruitblock.value;
    newList.add(thisFruit);
    _fruitblock.sink.add(newList);
  }

  resetFruit() {
    _fruit.sink.add(
      {
        'x': Random().nextInt(width.toInt() - 10),
        'y': Random().nextInt(height.toInt() - 10)
      },
    );

    int oldScore = _score.value;
    oldScore++;
    _score.sink.add(oldScore);
  }

  goLeft() {
    if (_direction.value == 0) {
      _direction.sink.add(3);
    } else if (_direction.value == 1) {
      _direction.sink.add(0);
    } else if (_direction.value == 2) {
      _direction.sink.add(1);
    } else if (_direction.value == 3) {
      _direction.sink.add(2);
    }
  }

  goRight() {
    if (_direction.value == 0) {
      _direction.sink.add(1);
    } else if (_direction.value == 1) {
      _direction.sink.add(2);
    } else if (_direction.value == 2) {
      _direction.sink.add(3);
    } else if (_direction.value == 3) {
      _direction.sink.add(0);
    }
  }

  setGameOver() async {
    _gameover.sink.add(true);
    final prefs = await SharedPreferences.getInstance();
    int oldHighScore = await prefs.getInt('highScore') ?? 0;
    if (oldHighScore < _score.value) {
      await prefs.setInt('highScore', _score.value);
    }
  }
}
