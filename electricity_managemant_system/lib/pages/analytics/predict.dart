import 'package:electricity_managemant_system/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class PredictionService {
  static void submitPrediction(BuildContext context) {
    // Your form submission logic here

    // Example: Show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prediction submitted!")),
    );
  }
}

class _PredictPageState extends State<PredictPage> {
  final TextEditingController machineNameController = TextEditingController();
  final TextEditingController kwController = TextEditingController();
  final TextEditingController powerFactorController = TextEditingController();
  final TextEditingController dayHoursController = TextEditingController();
  final TextEditingController peakHoursController = TextEditingController();
  final TextEditingController offPeakHoursController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Predict Energy Usage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Machine Name',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: machineNameController,
                hintText: 'Machine Name',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'KW',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: kwController,
                hintText: 'KW',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Power Factor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: powerFactorController,
                hintText: 'Power Factor',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Day Hours',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: dayHoursController,
                hintText: 'Day Hours',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Peak Hours',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: peakHoursController,
                hintText: 'Peak Hours',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Off-Peak Hours',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: offPeakHoursController,
                hintText: 'Off-Peak Hours',
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Machine Details',
                onPressed: () {
                  PredictionService.submitPrediction(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
