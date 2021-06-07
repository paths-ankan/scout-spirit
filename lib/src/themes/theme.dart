import 'package:flutter/material.dart';

final appTheme = ThemeData.light().copyWith(
  backgroundColor: Color.fromRGBO(73, 233, 255, 1),
  accentColor: Color.fromRGBO(80, 29, 222, 1.0),
  textTheme: ThemeData.light().textTheme.copyWith(
        headline1: TextStyle(color: Color(0xff3a3b45), fontSize: 24.0),
        headline2: TextStyle(color: Color(0xff3a3b45), fontSize: 18.0, fontFamily: 'Ubuntu'),
      ),
  primaryColor: Color.fromRGBO(93, 36, 255, 1),
  errorColor: Colors.pinkAccent,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.deepPurple[500],
    disabledColor: Colors.grey[600],
    focusColor: Colors.deepPurpleAccent[200],
    highlightColor: Colors.deepPurpleAccent[100],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0))
  ),
);

final TextStyle mutedTextTheme = ThemeData.light().textTheme.caption!;

final TextStyle codeStyle = TextStyle(fontSize: 24.0, fontFamily: 'Ubuntu', letterSpacing: 12.0);
