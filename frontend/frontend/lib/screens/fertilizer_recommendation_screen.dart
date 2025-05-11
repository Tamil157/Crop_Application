import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FertilizerRecommendationScreen extends StatefulWidget {
  @override
  _FertilizerRecommendationScreenState createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  String? _fertilizer;
  String? _application;
  String? _steps; // Fixed the declaration of _steps
  final TextEditingController _diseaseController = TextEditingController();

  Future<void> _getFertilizerRecommendation(String disease) async {
    // Update with your backend URL
    var response = await http.post(
      Uri.parse(
          ' http://192.168.43.32:5000/recommend-fertilizer'), // Update with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'disease': disease}), // Send disease as JSON
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _fertilizer = responseData['recommended_fertilizer'];
        _application = responseData['application'];
        _steps = responseData['steps']; // Capture the steps information
      });
    } else {
      setState(() {
        _fertilizer = 'Error: ${response.statusCode}';
        _application = null; // Reset application if there is an error
        _steps = null; // Reset steps if there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fertilizer Recommendation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _diseaseController,
                decoration: InputDecoration(
                  labelText: 'Enter Disease Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String disease = _diseaseController.text;
                  if (disease.isNotEmpty) {
                    _getFertilizerRecommendation(
                        disease); // Call the recommendation function
                  } else {
                    setState(() {
                      _fertilizer = 'Please enter a disease name.';
                      _application =
                          null; // Reset application if no disease is entered
                      _steps = null; // Reset steps if no disease is entered
                    });
                  }
                },
                child: Text('Get Fertilizer Recommendation'),
              ),
              SizedBox(height: 20),
              if (_fertilizer != null) Text('Fertilizer: $_fertilizer'),
              if (_application != null)
                Text('Application: $_application'), // Display application info
              if (_steps != null) Text('Steps: $_steps'), // Display steps info
            ],
          ),
        ),
      ),
    );
  }
}
