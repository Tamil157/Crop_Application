import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherRecommendationScreen extends StatefulWidget {
  @override
  _WeatherRecommendationScreenState createState() => _WeatherRecommendationScreenState();
}

class _WeatherRecommendationScreenState extends State<WeatherRecommendationScreen> {
  TextEditingController cityController = TextEditingController();
  String apiKey = "48227ee7ce2bd662acbe1a69e0308af3";
  String city = "";
  String description = "Sky Conditions : _ _ _";
  String temp = "Temperature : _ _ _ °C";
  String minTemp = "Minimum Temperature : _ _ _ °C";
  String maxTemp = "Maximum Temperature : _ _ _ °C";
  String windSpeed = "Wind Speed : _ _ _ km/h";
  String recommendation = "Actions to be taken: _ _ _";

  double convertKelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  String getRecommendation(double temp, String weather) {
    if (temp < 15) {
      return "Monitor for frost damage and consider using frost protection methods.";
    } else if (temp > 30) {
      return "Increase irrigation to prevent crop dehydration.";
    } else if (weather == "clear") {
      return "It's a good day for planting new crops and general fieldwork.";
    } else if (weather == "clouds") {
      return "Consider watering crops today as it might not rain.";
    } else if (weather == "rain") {
      return "Ensure proper drainage in the fields to prevent waterlogging.";
    } else if (weather == "storm") {
      return "Postpone field activities and secure equipment.";
    } else if (weather == "snow") {
      return "Protect crops from frost and ensure proper insulation.";
    } else {
      return "No specific recommendations.";
    }
  }

  void fetchWeather() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        city = data['name'];
        double tempKelvin = data['main']['temp'];
        double minKelvin = data['main']['temp_min'];
        double maxKelvin = data['main']['temp_max'];
        String weather = data['weather'][0]['main'].toLowerCase();
        double wind = data['wind']['speed'];

        description = "Sky Conditions : ${data['weather'][0]['description']}";
        temp = "Temperature : ${convertKelvinToCelsius(tempKelvin).toStringAsFixed(2)} °C";
        minTemp = "Minimum Temperature : ${convertKelvinToCelsius(minKelvin).toStringAsFixed(2)} °C";
        maxTemp = "Maximum Temperature : ${convertKelvinToCelsius(maxKelvin).toStringAsFixed(2)} °C";
        windSpeed = "Wind Speed : ${wind.toStringAsFixed(2)} km/h";
        recommendation = "Actions to be taken: ${getRecommendation(convertKelvinToCelsius(tempKelvin), weather)}";
      });
    } else {
      setState(() {
        recommendation = "Failed to fetch weather data. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Recommendations'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "Enter city name",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  city = value;
                });
                fetchWeather();
              },
            ),
            SizedBox(height: 20),
            Text(description, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(temp, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(minTemp, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(maxTemp, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(windSpeed, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(recommendation, style: TextStyle(fontSize: 18, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
