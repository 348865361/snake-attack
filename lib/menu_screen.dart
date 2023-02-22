import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String snakeColor = 'blue';
  int highScore = 0;

  getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = await prefs.getInt('highScore') ?? 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/menu background.png'),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'SNAKE GAME',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 50, fontFamily: "PressStart2P"),
              ),
            )),
            Expanded(
              child: SizedBox(),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Card(
                      child: Column(
                        children: [
                          Text('High Score'),
                          Text(highScore.toString())
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Select snake color'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    snakeColor = 'blue';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    size: snakeColor == 'blue' ? 35 : 30,
                                    color: Colors.blue,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    snakeColor = 'green';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    size: snakeColor == 'green' ? 35 : 30,
                                    color: Colors.green,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    snakeColor = 'orange';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    size: snakeColor == 'orange' ? 35 : 30,
                                    color: Colors.orange,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    snakeColor = 'red';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    size: snakeColor == 'red' ? 35 : 30,
                                    color: Colors.red,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    snakeColor = 'yellow';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.circle,
                                    size: snakeColor == 'yellow' ? 35 : 30,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          gameLevel: 1,
                          snakeColor: snakeColor,
                        ),
                      ),
                    );
                  },
                  child: Text('Easy(level 1)'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          gameLevel: 2,
                          snakeColor: snakeColor,
                        ),
                      ),
                    );
                  },
                  child: Text('Medium(level 2)'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          gameLevel: 3,
                          snakeColor: snakeColor,
                        ),
                      ),
                    );
                  },
                  child: Text('Hard(level 3)'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 70),
              child: Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          gameLevel: 4,
                          snakeColor: snakeColor,
                        ),
                      ),
                    );
                  },
                  child: Text('Speed Run'),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
