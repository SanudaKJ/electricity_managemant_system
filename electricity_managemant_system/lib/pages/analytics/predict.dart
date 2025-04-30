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
  final List<Map<String, dynamic>> machines = [];
  bool isPredictionAvailable = false; // Track if prediction data exists
  String? predictionId; // Store the ID of the existing prediction document
  Map<String, dynamic> lastPredictionResponse = {}; // Store the last prediction response

  @override
  void initState() {
    super.initState();
    _fetchPredictionData();
  }

  Future<void> _submitMachines() async {
    if (machines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one machine")),
      );
      return;
    }
    
    try {
      // Prepare data for Firestore
      final firestoreData = {
        ...widget.analyticsData,
        "machines": machines,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Save data to Firestore
      await FirebaseFirestore.instance
          .collection('analytics')
          .doc(widget.companyId)
          .collection('predictions')
          .add(firestoreData);

      // Send prediction request to API
      final predictionResponse = await _sendPredictionRequest();
      
      if (predictionResponse != null) {
        // Store the response for future use
        setState(() {
          lastPredictionResponse = predictionResponse;
          isPredictionAvailable = true;
        });
        
        // Navigate to the Report page with the response data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Report(responseData: predictionResponse),
          ),
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prediction completed successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit prediction: $e")),
      );
    }
  }

  Future<Map<String, dynamic>?> _sendPredictionRequest() async {
    const String apiUrl = 'http://35.177.54.179:5000/predict';

    // Create a normalized copy of analytics data with lowercase fields
    final normalizedAnalyticsData = {
      "company_size": (widget.analyticsData["company_size"] as String).toLowerCase(), 
      "tariff_category": widget.analyticsData["tariff_category"],
      "working_days": widget.analyticsData["working_days"],
      // Remove year and month as they're not in the Postman example
      // "year": widget.analyticsData["year"],
      // "month": widget.analyticsData["month"],
    };

    // Combine normalized analytics and machine data
    final requestData = {
      ...normalizedAnalyticsData,
      "machines": machines, // Use the list of machines
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
        return responseData;
      } else {
        print('Failed to predict. Status code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to predict: ${response.body}')),
        );
        return null;
      }
    } catch (e) {
      print('Error sending prediction request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending prediction request: $e')),
      );
      return null;
    }
  }

  void _addMachine() {
    // Validate input fields
    if (machineNameController.text.isEmpty ||
        (double.tryParse(kwController.text) ?? 0.0) <= 0.0 ||
        (double.tryParse(powerFactorController.text) ?? 0.0) <= 0.0 ||
        (int.tryParse(dayHoursController.text) ?? 0) <= 0 ||
        (int.tryParse(peakHoursController.text) ?? 0) < 0 ||
        (int.tryParse(offPeakHoursController.text) ?? 0) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid machine details.")),
      );
      return;
    }

    // Add the current machine details to the list
    setState(() {
      machines.add({
        "name": machineNameController.text,
        "kw": double.tryParse(kwController.text) ?? 0.0,
        "power_factor": double.tryParse(powerFactorController.text) ?? 0.0,
        "day_hours": int.tryParse(dayHoursController.text) ?? 0,
        "peak_hours": int.tryParse(peakHoursController.text) ?? 0,
        "off_peak_hours": int.tryParse(offPeakHoursController.text) ?? 0,
      });

      // Clear the input fields for the next machine
      machineNameController.clear();
      kwController.clear();
      powerFactorController.clear();
      dayHoursController.clear();
      peakHoursController.clear();
      offPeakHoursController.clear();
    });
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

        // If there are existing machines in the data, populate the machines list
        if (data.containsKey('machines') && data['machines'] is List) {
          setState(() {
            machines.clear();
            for (var machine in data['machines']) {
              machines.add(Map<String, dynamic>.from(machine));
            }
            isPredictionAvailable = true;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch prediction data: $e");
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
              Text(
                "Machines (${machines.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              machines.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No machines added yet. Use the form below to add machines.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Column(
                      children: machines.map((machine) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(machine['name']),
                              subtitle: Text(
                                  'KW: ${machine['kw']}, Power Factor: ${machine['power_factor']}, Day Hours: ${machine['day_hours']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    machines.remove(machine);
                                  });
                                },
                              ),
                            ),
                          )).toList(),
                    ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Add New Machine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addMachine,
                      icon: Icon(Icons.add),
                      label: Text("Add Machine"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: isPredictionAvailable && lastPredictionResponse.isNotEmpty
                          ? 'View Prediction Report'
                          : 'Calculate Prediction',
                      onPressed: () async {
                        if (isPredictionAvailable && lastPredictionResponse.isNotEmpty) {
                          // Navigate to the Report page with the stored response data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Report(responseData: lastPredictionResponse),
                            ),
                          );
                        } else {
                          // Submit machines data and make prediction
                          await _submitMachines();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}