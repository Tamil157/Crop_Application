import 'package:flutter/material.dart';
import 'crop_recommendation_screen.dart';
import 'disease_prediction_screen.dart';
import 'fertilizer_recommendation_screen.dart';
import 'weather_recommendation_screen.dart';
import 'fertilizer_calculator.dart';  // Import the new calculator screen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Management App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiseasePredictionScreen()),
                );
              },
              child: Text('Plant Disease Prediction'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropRecommendationScreen()),
                );
              },
              child: Text('Crop Recommendation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FertilizerRecommendationScreen()),
                );
              },
              child: Text('Fertilizer Recommendation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherRecommendationScreen()),
                );
              },
              child: Text('Weather Recommendation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FertilizerCalculatorScreen()),
                );
              },
              child: Text('Fertilizer Calculator'),
            ),
          ],
        ),
      ),
    );
  }
}
