import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _HomeState();
}

class _HomeState extends State<home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  
  // Data variables
  List<Map<String, dynamic>> _companyData = [];
  int _totalCompanies = 0;
  Map<String, int> _companySizeDistribution = {};
  double _totalEnergyUsage = 0;
  
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch analytics data
      final analyticsSnapshot = await _firestore.collection('analytics').get();
      
      if (analyticsSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Process analytics data
      final List<Map<String, dynamic>> data = [];
      _companySizeDistribution = {'Small': 0, 'Medium': 0, 'Large': 0};
      double totalEnergy = 0;
      
      for (var doc in analyticsSnapshot.docs) {
        final Map<String, dynamic> item = doc.data();
        item['id'] = doc.id;
        data.add(item);
        
        // Update company size distribution
        final companySize = item['company_size'] as String? ?? 'Unknown';
        if (_companySizeDistribution.containsKey(companySize)) {
          _companySizeDistribution[companySize] = _companySizeDistribution[companySize]! + 1;
        }
        
        // Fetch prediction data for energy calculation
        try {
          final predictionSnapshot = await _firestore
              .collection('analytics')
              .doc(doc.id)
              .collection('predictions')
              .get();
          
          if (predictionSnapshot.docs.isNotEmpty) {
            final predictionData = predictionSnapshot.docs.first.data();
            
            // Calculate energy consumption
            final kw = predictionData['kw'] as double? ?? 0.0;
            final dayHours = predictionData['day_hours'] as int? ?? 0;
            final peakHours = predictionData['peak_hours'] as int? ?? 0;
            final offPeakHours = predictionData['off_peak_hours'] as int? ?? 0;
            final workingDays = item['working_days'] as int? ?? 0;
            
            // Calculate total energy for this company (kWh)
            final energy = kw * (dayHours + peakHours + offPeakHours) * workingDays;
            totalEnergy += energy;
          }
        } catch (e) {
          print('Error fetching prediction data: $e');
        }
      }
      
      // Update state with processed data
      setState(() {
        _companyData = data;
        _totalCompanies = data.length;
        _totalEnergyUsage = totalEnergy;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Electricity Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _companyData.isEmpty
              ? _buildEmptyState()
              : _buildDashboard(),
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
            'No data available yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/analytics');
            },
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text("Add Data in Analytics",
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

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(),
            const SizedBox(height: 24),
            
            // Company Size Distribution Chart
            _buildSectionHeader('Company Size Distribution'),
            const SizedBox(height: 8),
            _buildCompanyDistributionChart(),
            const SizedBox(height: 24),
            
            // Recent Companies List
            _buildSectionHeader('Recent Companies'),
            const SizedBox(height: 8),
            _buildRecentCompaniesList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Total Companies',
            _totalCompanies.toString(),
            Icons.business,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Energy Consumption',
            '${_totalEnergyUsage.toStringAsFixed(0)} kWh',
            Icons.electric_bolt,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildCompanyDistributionChart() {
    if (_companySizeDistribution.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final Map<String, Color> sizeColors = {
      'Small': Colors.blue,
      'Medium': Colors.green,
      'Large': Colors.orange,
    };
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: _companySizeDistribution.entries.map((entry) {
                    return PieChartSectionData(
                      color: sizeColors[entry.key] ?? Colors.grey,
                      value: entry.value.toDouble(),
                      title: entry.value.toString(),
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _companySizeDistribution.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sizeColors[entry.key],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentCompaniesList() {
    if (_companyData.isEmpty) {
      return const Center(child: Text('No companies available'));
    }
    
    // Take the most recent 5 companies
    final recentCompanies = _companyData.take(5).toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: recentCompanies.length,
        itemBuilder: (context, index) {
          final company = recentCompanies[index];
          final companySize = company['company_size'] as String? ?? 'Unknown';
          final tariffCategory = company['tariff_category'] as String? ?? 'Unknown';
          final workingDays = company['working_days'] as int? ?? 0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[100],
              child: Icon(
                Icons.business,
                color: Colors.orange[800],
              ),
            ),
            title: Text(
              '$companySize Company',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$tariffCategory • $workingDays working days'),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                Navigator.pushNamed(context, '/predict', arguments: company['id']);
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/predict', arguments: company['id']);
            },
          );
        },
      ),
    );
  }
}