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
    // Safely extract fields with null checking
    final calculation =
        widget.responseData['calculation'] as Map<String, dynamic>? ?? {};
    final features =
        widget.responseData['features'] as Map<String, dynamic>? ?? {};
    final prediction =
        widget.responseData['prediction'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Prediction Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
      ),
      body: widget.responseData.isEmpty
          ? _buildEmptyState()
          : _buildReportContent(calculation, features, prediction),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No prediction data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text("Go Back and Add Data",
                style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(Map<String, dynamic> calculation,
      Map<String, dynamic> features, Map<String, dynamic> prediction) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildReportSection(
              title: 'Prediction Summary',
              iconData: Icons.analytics,
              backgroundColor: Colors.blue[50]!,
              borderColor: Colors.blue[200]!,
              content: [
                _buildInfoRow('Predicted Bill',
                    '${prediction['predicted_bill'] ?? 'N/A'}'),
                _buildInfoRow(
                    'Actual Bill', '${calculation['total_bill'] ?? 'N/A'}'),
                _buildInfoRow(
                    'Difference', '${prediction['difference'] ?? 'N/A'}'),
                _buildInfoRow('Difference Percentage',
                    '${prediction['difference_percent'] ?? 'N/A'}%'),
              ],
            ),
            const SizedBox(height: 24),
            // _buildReportSection(
            //   title: 'Calculation Details',
            //   iconData: Icons.calculate,
            //   backgroundColor: Colors.green[50]!,
            //   borderColor: Colors.green[200]!,
            //   content: [
            //     _buildInfoRow('Tariff Used',
            //         '${calculation['actual_tariff_used'] ?? 'N/A'}'),
            //     _buildInfoRow(
            //         'Tariff Name', '${calculation['tariff_name'] ?? 'N/A'}'),
            //     _buildInfoRow('Total Consumption (kWh)',
            //         '${calculation['total_consumption_kwh'] ?? 'N/A'}'),
            //     _buildInfoRow(
            //         'Day Charge', '${calculation['day_charge'] ?? 'N/A'}'),
            //     _buildInfoRow(
            //         'Peak Charge', '${calculation['peak_charge'] ?? 'N/A'}'),
            //     _buildInfoRow('Off-Peak Charge',
            //         '${calculation['off_peak_charge'] ?? 'N/A'}'),
            //     _buildInfoRow('Demand Charge',
            //         '${calculation['demand_charge'] ?? 'N/A'}'),
            //     _buildInfoRow(
            //         'Fixed Charge', '${calculation['fixed_charge'] ?? 'N/A'}'),
            //     _buildInfoRow(
            //         'Total Bill', '${calculation['total_bill'] ?? 'N/A'}'),
            //   ],
            // ),
            const SizedBox(height: 24),
            _buildReportSection(
              title: 'Features',
              iconData: Icons.business,
              backgroundColor: Colors.orange[50]!,
              borderColor: Colors.orange[200]!,
              content: [
                _buildInfoRow(
                    'Company Size', '${features['company_size'] ?? 'N/A'}'),
                _buildInfoRow('Average KW', '${features['avg_kw'] ?? 'N/A'}'),
                _buildInfoRow('Average Power Factor',
                    '${features['avg_power_factor'] ?? 'N/A'}'),
                _buildInfoRow('Average Day Hours',
                    '${features['avg_day_hours'] ?? 'N/A'}'),
                _buildInfoRow('Total Monthly kWh',
                    '${features['total_monthly_kwh'] ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection({
    required String title,
    required IconData iconData,
    required Color backgroundColor,
    required Color borderColor,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: borderColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
