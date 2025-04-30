import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  final Map<String, dynamic> responseData;
  const Report({super.key, required this.responseData});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  Widget build(BuildContext context) {
    final calculation = widget.responseData['calculation'];
    final features = widget.responseData['features'];
    final prediction = widget.responseData['prediction'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report",
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
              const Text(
                'Calculation Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Tariff Used: ${calculation['actual_tariff_used']}"),
              Text("Day Charge: ${calculation['day_charge']}"),
              Text("Demand Charge: ${calculation['demand_charge']}"),
              Text("Fixed Charge: ${calculation['fixed_charge']}"),
              Text("Off-Peak Charge: ${calculation['off_peak_charge']}"),
              Text("Peak Charge: ${calculation['peak_charge']}"),
              Text("Tariff Name: ${calculation['tariff_name']}"),
              Text("Total Bill: ${calculation['total_bill']}"),
              Text("Total Consumption (kWh): ${calculation['total_consumption_kwh']}"),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Company Size: ${features['company_size']}"),
              Text("Average Day Hours: ${features['avg_day_hours']}"),
              Text("Average KW: ${features['avg_kw']}"),
              Text("Average Power Factor: ${features['avg_power_factor']}"),
              Text("Total Monthly kWh: ${features['total_monthly_kwh']}"),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Prediction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Predicted Bill: ${prediction['predicted_bill']}"),
              Text("Difference: ${prediction['difference']}"),
              Text("Difference Percentage: ${prediction['difference_percent']}%"),
            ],
          ),
        ),
      ),
    );
  }
}