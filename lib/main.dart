import 'package:flutter/material.dart';
import 'package:raissangarambe/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _checkLoginStatus();
    _setupConnectivity();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = _themeMode == ThemeMode.dark;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
    await prefs.setBool('isDarkMode', !isDarkMode);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _setupConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      String message;
      if (result == ConnectivityResult.none) {
        message = 'No internet connection';
      } else {
        message = 'Connected to internet';
      }
      Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
      _showPopup('Connection Status', message); // Show notification here
      setState(() {
        _MyHomePageState._connectionStatus = message;
      });
    });
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.white,
          secondary: Colors.black,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.black,
          secondary: Colors.white,
          surface: Colors.black,
          background: Colors.black,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,  // Use the current theme mode
      home: _isLoggedIn ? MyHomePage(title: 'Home Page', toggleThemeMode: _toggleThemeMode) : LoginPage(), // Navigate based on login state
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleThemeMode});
  final String title;
  final Function toggleThemeMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String _connectionStatus = 'Unknown';
  String _batteryStatus = 'Unknown';
  int _batteryLevel = -1; // -1 indicates that the battery level is unknown
  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();
  Timer? _batteryTimer; // Timer for periodic battery level updates

  @override
  void initState() {
    super.initState();
    _updateConnectionStatus();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _setupBatteryListener();
    _getBatteryLevel();
    _startBatteryTimer();
  }

  @override
  void dispose() {
    _batteryTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  Future<void> _updateConnectionStatus([ConnectivityResult? result]) async {
    ConnectivityResult connectivityResult = result ?? await _connectivity.checkConnectivity();
    String message;
    if (connectivityResult == ConnectivityResult.none) {
      message = 'No internet connection';
    } else {
      message = 'Connected to internet';
    }
    setState(() {
      _connectionStatus = message;
    });
  }

  void _setupBatteryListener() {
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (state == BatteryState.charging) {
        int batteryLevel = await _battery.batteryLevel;
        if (batteryLevel >= 90) {
          _batteryStatus = 'Battery level reached 90% while charging';
          Fluttertoast.showToast(msg: _batteryStatus, toastLength: Toast.LENGTH_SHORT);
          _showPopup('Battery Status', _batteryStatus);
        } else {
          _batteryStatus = 'Battery is charging';
        }
      } else if (state == BatteryState.full) {
        _batteryStatus = 'Battery is full';
      } else if (state == BatteryState.discharging) {
        _batteryStatus = 'Battery is discharging';
      } else {
        _batteryStatus = 'Battery status unknown';
      }
      setState(() {});
    });
  }

  Future<void> _getBatteryLevel() async {
    int batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void _startBatteryTimer() {
    _batteryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getBatteryLevel();
    });
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () => widget.toggleThemeMode(),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.wifi,
                      color: Colors.blue,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connectivity Status:',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      _MyHomePageState._connectionStatus,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.battery_full,
                      color: Colors.green,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Battery Status:',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      _batteryStatus,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'Battery Level: ${_batteryLevel >= 0 ? _batteryLevel.toString() + '%' : 'Unknown'}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}