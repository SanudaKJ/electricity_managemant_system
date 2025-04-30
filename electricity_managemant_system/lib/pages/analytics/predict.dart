import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_managemant_system/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'report.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;

class PredictPage extends StatefulWidget {
  final String companyId; // Accept company ID as a parameter
  final Map<String, dynamic> analyticsData;
  const PredictPage(
      {super.key, required this.companyId, required this.analyticsData});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final TextEditingController machineNameController = TextEditingController();
  final TextEditingController kwController = TextEditingController();
  final TextEditingController powerFactorController = TextEditingController();
  final TextEditingController dayHoursController = TextEditingController();
  final TextEditingController peakHoursController = TextEditingController();
  final TextEditingController offPeakHoursController = TextEditingController();

  bool isPredictionAvailable = false; // Track if prediction data exists
  String? predictionId; // Store the ID of the existing prediction document

  @override
  void initState() {
    super.initState();
    _fetchPredictionData();
  }

Future<void> _sendPredictionRequest() async {
  const String apiUrl = 'http://35.177.54.179:5000/predict';

  // Collect machine data
  final machineData = [
    {
      "name": machineNameController.text,
      "kw": double.tryParse(kwController.text) ?? 0.0,
      "power_factor": double.tryParse(powerFactorController.text) ?? 0.0,
      "day_hours": int.tryParse(dayHoursController.text) ?? 0,
      "peak_hours": int.tryParse(peakHoursController.text) ?? 0,
      "off_peak_hours": int.tryParse(offPeakHoursController.text) ?? 0,
    }
  ];

  // Combine analytics and machine data
  final requestData = {
    ...widget.analyticsData,
    "machines": machineData,
  };

  print('Request Data: ${jsonEncode(requestData)}'); // Log the request data

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Prediction Response: $responseData');

      // Navigate to the Report page with the response data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Report(responseData: responseData),
        ),
      );
    } else {
      print('Failed to predict. Status code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print('Error sending prediction request: $e');
  }
}

  Future<void> _fetchPredictionData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('analytics')
          .doc(widget.companyId)
          .collection('predictions')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        predictionId = snapshot.docs.first.id;

        // Populate text fields with fetched data
        machineNameController.text = data['machine_name'] ?? '';
        kwController.text = (data['kw'] ?? '').toString();
        powerFactorController.text = (data['power_factor'] ?? '').toString();
        dayHoursController.text = (data['day_hours'] ?? '').toString();
        peakHoursController.text = (data['peak_hours'] ?? '').toString();
        offPeakHoursController.text = (data['off_peak_hours'] ?? '').toString();

        setState(() {
          isPredictionAvailable = true; // Mark that prediction data exists
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch prediction data: $e")),
      );
    }
  }

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
        color: Colors.white,
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
                text: isPredictionAvailable
                    ? 'View Report'
                    : 'Submit Machine Details',
                onPressed: () async {
                  if (isPredictionAvailable) {
                    // Navigate to the Report page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Report(responseData: {},),
                      ),
                    );
                  } else {
                    // Collect form data
                    final predictionData = {
                      'machine_name': machineNameController.text,
                      'kw': double.tryParse(kwController.text) ?? 0.0,
                      'power_factor':
                          double.tryParse(powerFactorController.text) ?? 0.0,
                      'day_hours': int.tryParse(dayHoursController.text) ?? 0,
                      'peak_hours': int.tryParse(peakHoursController.text) ?? 0,
                      'off_peak_hours':
                          int.tryParse(offPeakHoursController.text) ?? 0,
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    // Save data to Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('analytics')
                          .doc(widget.companyId)
                          .collection('predictions')
                          .add(predictionData);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Prediction submitted successfully!")),
                      );

                      // Reload the page to fetch the new data
                      _sendPredictionRequest();
                      _fetchPredictionData();
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Failed to submit prediction: $e")),
                      );
                    }
                  }
                },
              ),
              // CustomButton(
              //   text: 'Predict Bill',
              //   onPressed: () async {
              //     await _sendPredictionRequest();
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
