import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class DiseasePredictionScreen extends StatefulWidget {
  @override
  _DiseasePredictionScreenState createState() => _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  File? _image;
  String? _predictedDisease;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _predictDisease();
    }
  }

  Future<void> _predictDisease() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.43.32:5000/predict-disease'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
    
    var response = await request.send();
    
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      setState(() {
        _predictedDisease = decodedData['disease'];
      });
    } else {
      setState(() {
        _predictedDisease = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Prediction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            if (_predictedDisease != null) Text('Predicted Disease: $_predictedDisease'),
          ],
        ),
      ),
    );
  }
}
