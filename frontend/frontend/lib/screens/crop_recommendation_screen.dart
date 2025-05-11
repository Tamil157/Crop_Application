import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropRecommendationScreen extends StatefulWidget {
  @override
  _CropRecommendationScreenState createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  String _predictionResult = '';

  Future<void> _predictCrop() async {
    // Define the API endpoint
    final url = Uri.parse('http://192.168.43.32:5000/recommend-crop');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'N': double.parse(_nController.text),
          'P': double.parse(_pController.text),
          'K': double.parse(_kController.text),
          'temperature': double.parse(_temperatureController.text),
          'humidity': double.parse(_humidityController.text),
          'ph': double.parse(_phController.text),
          'rainfall': double.parse(_rainfallController.text),
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _predictionResult = jsonResponse['recommended_crop'] ??
              'No crop prediction available';
        });
      } else {
        setState(() {
          _predictionResult = 'Error occurred during crop prediction';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Exception occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Recommendation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildTextField(_nController, 'Nitrogen (N)'),
            _buildTextField(_pController, 'Phosphorus (P)'),
            _buildTextField(_kController, 'Potassium (K)'),
            _buildTextField(_temperatureController, 'Temperature'),
            _buildTextField(_humidityController, 'Humidity'),
            _buildTextField(_phController, 'pH'),
            _buildTextField(_rainfallController, 'Rainfall'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictCrop,
              child: Text('Predict Crop'),
            ),
            SizedBox(height: 20),
            Text(
              _predictionResult.isEmpty
                  ? 'Prediction result will appear here'
                  : 'Predicted Crop: $_predictionResult',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }
}
