import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Core/DashboardScreen.dart';
import 'screen/Signin.dart';
import 'services/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await _initializeApp();
}


Future<void> _initializeApp() async {
  try {
    await Firebase.initializeApp();
    print("Firebase initialized");
    await NotificationHelper.initialize();
    print("Notifications initialized");
    _requestNotificationPermission();
  } catch (e) {
    print("Initialization error: $e");
  }
}

/// Request notification permission using permission_handler
Future<void> _requestNotificationPermission() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    await prefs.setBool('isFirstLaunch', false);
  }
}

Future<void> openExactAlarmSettings() async {
  const platform = MethodChannel('alarm_permission');

  try {
    await platform.invokeMethod('openExactAlarmSettings');
  } on PlatformException catch (e) {
    print("Failed to open settings: '${e.message}'.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
      },
      home: const SplashWrapper(),
    );
  }
}


class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print("Firebase init error: $e");
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Scaffold(
        body: Center(
          child: Text("Error initializing Firebase"),
        ),
      );
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    return const SignIn();
  }
}
