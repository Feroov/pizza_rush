import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _pizzaCount = 0;
  int startPizzaCount = 0;
  int _autoClickerCost = 20;
  int _autoClickerLevel = 1;
  int _autoFastClickerCost = 500;
  int _autoFastClickerLevel = 1;
  int _numAutoClickers = 0;
  Timer? _autoClickerTimer;
  Timer? _autoFastClickerTimer;

  AudioCache _audioCache = AudioCache();
  AudioPlayer? _audioPlayer;

  DateTime _lastPizzaClickTime = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadPizzaCount();
    _loadAutoClickerLevel();
    _loadAutoClickerCost();
    _loadAutoClickerState();
    _initAudio();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initAudio() async {
    _audioCache = AudioCache();
    _audioPlayer = await _audioCache.loop('theme.mp3');
  }

  void _onPizzaTap() {
    setState(() {
      _pizzaCount++;
      _isPizzaChanged = true;
    });

    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _isPizzaChanged = false;
      });
    });
  }


  void _buyAutoClicker() {
    if (_pizzaCount >= _autoClickerCost) {
      setState(() {
        _pizzaCount -= _autoClickerCost;
        _autoClickerLevel++;
        _autoClickerCost = (_autoClickerCost * 1.1).round();
        _autoClickerTimer?.cancel();
        _autoClickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _pizzaCount += _autoClickerLevel;
            _savePizzaCount();
          });
        });
        _numAutoClickers++;
        _saveAutoClickerLevel();
        _saveAutoClickerCost();
        _saveAutoClickerState();
      });
    }
  }


  void _buyFasterAutoClicker() {
    if (_pizzaCount >= _autoFastClickerCost) {
      setState(() {
        _pizzaCount -= _autoFastClickerCost;
        _autoFastClickerLevel++;
        _autoFastClickerCost = (_autoFastClickerCost * 1.1).round();
        _autoFastClickerTimer?.cancel();
        _autoFastClickerTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          setState(() {
            _pizzaCount += _autoFastClickerLevel;
            _savePizzaCount();
          });
        });

        _numAutoClickers++;
        _saveAutoClickerLevel();
        _saveAutoClickerCost();
        _saveAutoClickerState();
      });
    }
  }


  Future<void> _loadAutoClickerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _numAutoClickers = prefs.getInt('numAutoClickers') ?? 0;
    });
    bool autoClickerTimerActive = prefs.getBool('autoClickerTimerActive') ?? false;
    bool autoFastClickerTimerActive = prefs.getBool('autoFastClickerTimerActive') ?? false;
    int autoClickerLevel = prefs.getInt('autoClickerLevel') ?? 1;
    int autoFastClickerLevel = prefs.getInt('autoFastClickerLevel') ?? 1;
    int autoClickerCost = prefs.getInt('autoClickerCost') ?? 20;
    int autoFastClickerCost = prefs.getInt('autoFastClickerCost') ?? 500;
    for (int i = 0; i < _numAutoClickers; i++) {
      _autoClickerLevel = autoClickerLevel;
      _autoFastClickerLevel = autoFastClickerLevel;
      _autoClickerCost = autoClickerCost;
      _autoFastClickerCost = autoFastClickerCost;
      if (autoClickerTimerActive && _autoClickerTimer == null) {
        int delaySeconds = 1;
        _autoClickerTimer = Timer.periodic(Duration(seconds: delaySeconds), (_) {
          setState(() {
            _pizzaCount += autoClickerLevel;
            _savePizzaCount();
          });
        });
      }
      if (autoFastClickerTimerActive && _autoFastClickerTimer == null) {
        _autoFastClickerTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          setState(() {
            _pizzaCount += autoFastClickerLevel;
            _savePizzaCount();
          });
        });
      }
    }
  }





  Future<void> _saveAutoClickerState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('numAutoClickers', _numAutoClickers);
    prefs.setBool('autoClickerTimerActive', _autoClickerTimer?.isActive ?? false);
    prefs.setBool('autoFastClickerTimerActive', _autoFastClickerTimer?.isActive ?? false);
  }



  Future<void> _loadAutoClickerCost() async {
    final prefs = await SharedPreferences.getInstance();
    _autoClickerCost = prefs.getInt('autoClickerCost') ?? 20;
    _autoFastClickerCost = prefs.getInt('autoFastClickerCost') ?? 500;
  }

  Future<void> _loadAutoClickerLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoClickerLevel = prefs.getInt('autoClickerLevel') ?? 1;
      _autoFastClickerLevel = prefs.getInt('autoFastClickerLevel') ?? 1;
    });
  }

  Future<void> _saveAutoClickerLevel() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('autoClickerLevel', _autoClickerLevel);
    prefs.setInt('autoFastClickerLevel', _autoFastClickerLevel);
  }

  Future<void> _loadPizzaCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startPizzaCount = prefs.getInt('pizzaCount') ?? 0;
      _pizzaCount = startPizzaCount;
    });
  }

  Future<void> _savePizzaCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('pizzaCount', _pizzaCount);
  }

  void _saveAutoClickerCost() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('autoClickerCost', _autoClickerCost);
    prefs.setInt('autoFastClickerCost', _autoFastClickerCost);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer?.stop();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer?.resume();
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer?.stop();
    _autoClickerTimer?.cancel();
    _autoFastClickerTimer?.cancel();
    super.dispose();
  }


  bool _isPizzaChanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 40,
              ),
              child: GestureDetector(
                onTap: _onPizzaTap,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 250.0, bottom: 250),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return Image.asset(
                                _isPizzaChanged
                                    ? 'assets/images/pizza1.gif'
                                    : 'assets/images/pizza.gif',
                                width: 500,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Text(
                            '$_pizzaCount Pizzas',
                            style: const TextStyle(
                              fontSize: 44,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Redwing',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 200,
            child: ElevatedButton(
              onPressed: _buyAutoClicker,
              child: Text(
                'Auto Clicker\n${_autoClickerLevel > 0 ? "Level $_autoClickerLevel\n" : ""}Cost: $_autoClickerCost Pizzas',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 200,
            right: 0,
            child: ElevatedButton(
              onPressed: _buyFasterAutoClicker,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Faster Auto Clicker\n${_autoFastClickerLevel > 0 ? "Level $_autoFastClickerLevel\n" : ""}Cost: $_autoFastClickerCost Pizzas',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
