import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/app_database.dart';

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String temperature = "";
  String humidity = "";
  String condition = "";

  Future<void> fetchWeather(String city) async {
    final url = Uri.parse("https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=pt&format=json");

    final geoResponse = await http.get(url);

    if (geoResponse.statusCode == 200) {
      final geoData = json.decode(geoResponse.body);
      if (geoData["results"] != null && geoData["results"].isNotEmpty) {
        double lat = geoData["results"][0]["latitude"];
        double lon = geoData["results"][0]["longitude"];

        final weatherUrl = Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m&timezone=America/Sao_Paulo");

        final weatherResponse = await http.get(weatherUrl);

        if (weatherResponse.statusCode == 200) {
          final weatherData = json.decode(weatherResponse.body);
          setState(() {
            temperature = "Temperatura: ${weatherData["current"]["temperature_2m"]}°C";
            humidity = "Umidade: ${weatherData["current"]["relative_humidity_2m"]}%";
            condition = "Condição: Dados disponíveis";
          });

          // Salvar no banco de dados
          await DatabaseHelper.instance.insertWeather({
            'city': city,
            'temperature': temperature,
            'humidity': humidity,
            'condition': condition
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar os dados!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Previsão do Tempo")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "Digite o nome da cidade",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchWeather(_cityController.text);
              },
              child: Text("Buscar"),
            ),
            SizedBox(height: 20),
            Text(
              temperature,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              humidity,
              style: TextStyle(fontSize: 18),
            ),
            Text(
              condition,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
