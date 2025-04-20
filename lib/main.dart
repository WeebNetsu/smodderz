import 'package:flutter/material.dart';
import 'package:smodderz/constants/constants.dart';
import 'package:smodderz/routes.dart';
import 'package:smodderz/theme/theme.dart';
import 'package:smodderz/views/mods/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //   await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The navigator key is necessary to allow to navigate through static methods (AwesomeNotifications)
      navigatorKey: MyApp.navigatorKey,
      title: AppConstants.name,
      theme: AppTheme.theme,
      routes: routes,
      home: ModsView(),
    );
  }
}
