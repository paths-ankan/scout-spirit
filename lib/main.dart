import 'package:flutter/material.dart';
import 'package:scout_spirit/src/pages/main.dart';
import 'package:scout_spirit/src/pages/login.dart';
import 'package:scout_spirit/src/pages/signup.dart';
import 'package:scout_spirit/src/pages/startup.dart';
import 'package:scout_spirit/src/pages/explore.dart';
import 'package:scout_spirit/src/pages/tasks/task-start-form.dart';


void main() => runApp(ScoutSpiritApp());

class ScoutSpiritApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scout Spirit App',
      initialRoute: '/',
      routes: {
        '/': (_) => StartupPage(),
        '/login': (_) => AuthenticationPage(),
        '/signup': (_) => SignUpPage(),
        '/home': (_) => MainPage(),
        '/explore': (_) => ExplorePage(),
        '/tasks/start': (context) => TaskStartFormPage(area: ModalRoute.of(context).settings.arguments),
      },
    );
  }
}
