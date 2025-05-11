import 'package:flutter/material.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  @override
  _FertilizerCalculatorScreenState createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen> {
  final TextEditingController landAreaController = TextEditingController();
  double? ureaAmount;
  double? potassiumAmount;

  void calculateFertilizer() {
    double landAreaAcres = double.tryParse(landAreaController.text) ?? 0.0;

    // Example calculation for urea and potassium based on land area
    ureaAmount = landAreaAcres * 20; // Assuming 20 kg per acre as an example
    potassiumAmount = landAreaAcres * 10; // Assuming 10 kg per acre as an example

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fertilizer Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: landAreaController,
              decoration: InputDecoration(
                labelText: 'Land Area (acres)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateFertilizer,
              child: Text('Calculate Fertilizer'),
            ),
            SizedBox(height: 20),
            if (ureaAmount != null && potassiumAmount != null) ...[
              Text('Urea Required: ${ureaAmount!.toStringAsFixed(2)} kg'),
              Text('Potassium Required: ${potassiumAmount!.toStringAsFixed(2)} kg'),
            ],
          ],
        ),
      ),
    );
  }
}
