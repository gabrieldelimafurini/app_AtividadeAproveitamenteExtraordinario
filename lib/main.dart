import 'package:flutter/material.dart';
import './pages/HomePage.dart'; // Importa a tela principal

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Usa a HomePage como tela principal
    );
  }
}
