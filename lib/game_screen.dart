import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_logic.dart';
import 'menu_screen.dart';

class GameScreen extends StatefulWidget {
  GameScreen({Key? key, required this.gameLevel, required this.snakeColor})
      : super(key: key);
  int gameLevel;
  String snakeColor;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameLogic logic;
  late AnimationController controller;
  final FocusNode _focusNode = FocusNode();

  void _handleKeyEvent(RawKeyEvent event) {
    print(event.runtimeType);
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        logic.goLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        logic.goRight();
      }
    }
  }

  List<Widget> getBlocks(List<Map>? data) {
    List<Widget> children = [];
    data = data ?? [];
    for (int x = 0; x < data.length; x++) {
      Map block = data[x];
      children.add(
        Positioned(
          bottom: block['y'],
          left: block['x'],
          child: Container(
            child: Image.asset('assets/bomb.gif'),
            width: 30,
            height: 30,
          ),
        ),
      );
    }
    return children;
  }

  List<Widget> getSnake(List<Map>? data) {
    List<Widget> children = [];
    data = data ?? [];
    for (int x = 0; x < data.length; x++) {
      Map segment = data[x];
      if (x == 0) {
        children.add(
          StreamBuilder<int>(
              stream: logic.direction,
              builder: (context, snapshot) {
                return Positioned(
                  bottom: segment['y'] as double,
                  left: segment['x'] as double,
                  width: 20,
                  child: RotatedBox(
                    quarterTurns: (snapshot.data ?? 0) + 2,
                    child: Container(
                      child:
                          Image.asset('assets/${widget.snakeColor} head.png'),
                      height: 20,
                    ),
                  ),
                );
              }),
        );
      } else {
        children.add(
          Positioned(
            bottom: segment['y'] as double,
            left: segment['x'] as double,
            width: 20,
            child: Container(
              child: Image.asset('assets/${widget.snakeColor} body.png'),
              height: 20,
            ),
          ),
        );
      }
    }
    return children;
  }

  @override
  void initState() {
    logic = GameLogic(widget.gameLevel);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 46;
    double height = MediaQuery.of(context).size.height - 46;
    logic.updatesSize(width - 20, height - 20);
    return Scaffold(
      body: RawKeyboardListener(
        onKey: _handleKeyEvent,
        focusNode: _focusNode,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_focusNode),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                color: Colors.lightGreen,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/background grass.jpg'),
                            fit: BoxFit.cover)),
                    width: width,
                    height: height,
                    child: StreamBuilder<List<Map>>(
                        stream: logic.snake,
                        builder: (context, snap) {
                          return StreamBuilder<List<Map>>(
                              stream: logic.fruitblock,
                              builder: (context, snapshot) {
                                List<Widget> blocks = getBlocks(snapshot.data);
                                List<Widget> snake = getSnake(snap.data);
                                return Stack(
                                  children: [
                                    ...blocks,
                                    ...snake,
                                    StreamBuilder<int>(
                                        stream: logic.score,
                                        builder: (context, snapshot) {
                                          return Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                                color: Colors.white54,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'score: ${snapshot.data}'),
                                                )),
                                          );
                                        }),
                                    StreamBuilder<int>(
                                        stream: logic.endTime,
                                        builder: (context, snapshot) {
                                          return snapshot.data != null
                                              ? Positioned(
                                                  top: 0,
                                                  right: 100,
                                                  child: Container(
                                                      color: Colors.white54,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            'Time Left: ${snapshot.data}'),
                                                      )),
                                                )
                                              : SizedBox();
                                        }),
                                    StreamBuilder<Map>(
                                        stream: logic.fruit,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Positioned(
                                              bottom: snapshot.data!['y'],
                                              left: snapshot.data!['x'],
                                              child: Container(
                                                child: Image.asset(
                                                    'assets/fruit.gif'),
                                                width: 30,
                                                height: 30,
                                              ),
                                            );
                                          } else {
                                            return SizedBox();
                                          }
                                        }),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(_focusNode);
                                            logic.goLeft();
                                          },
                                          child: Container(
                                            width: width / 2,
                                            height: height,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(_focusNode);
                                            logic.goRight();
                                          },
                                          child: Container(
                                            width: width / 2,
                                            height: height,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (logic.isPlaying == true) {
                                          logic.pause();
                                          controller.forward();
                                        } else {
                                          logic.play();
                                          controller.reverse();
                                        }
                                      },
                                      child: AnimatedIcon(
                                        icon: AnimatedIcons.play_pause,
                                        progress: controller,
                                      ),
                                    ),
                                    StreamBuilder<bool>(
                                        stream: logic.gameover,
                                        builder: (context, snapshot) {
                                          if (snapshot.data == true) {
                                            return Container(
                                              width: width,
                                              height: height,
                                              color: Colors.black54,
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Game Over',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 50,
                                                          fontFamily:
                                                              "PressStart2P"),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () =>
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MenuScreen(),
                                                                  ),
                                                                ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                Icons.home,
                                                                size: 45,
                                                              ),
                                                            )),
                                                        GestureDetector(
                                                            onTap: () {
                                                              logic.init(widget
                                                                  .gameLevel);
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                Icons.refresh,
                                                                size: 45,
                                                              ),
                                                            )),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return SizedBox();
                                          }
                                        })
                                  ],
                                );
                              });
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
