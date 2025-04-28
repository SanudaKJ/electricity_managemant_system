// filepath: c:\Electricity Managment System\Mobile App\electricity_managemant_system\lib\pages\analytics\analytic.dart
import 'package:electricity_managemant_system/pages/analytics/predict.dart';
import 'package:electricity_managemant_system/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class Analytic extends StatefulWidget {
  const Analytic({super.key});

  @override
  State<Analytic> createState() => _AnalyticState();
}

class _AnalyticState extends State<Analytic>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  bool _isFilterVisible = false;
  String _selectedFilter = "All";
  final List<String> _filterOptions = ["All", "Small", "Medium", "Large"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[800],
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Navigationbar()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
        ],
        // bottom: TabBar(
        //   controller: _tabController,
        //   indicatorColor: Colors.white,
        //   tabs: const [
        //     Tab(icon: Icon(Icons.assessment), text: "Overview"),
        //     Tab(icon: Icon(Icons.list), text: "Raw Data"),
        //   ],
        // ),
      ),
      body: Column(
        children: [
          if (_isFilterVisible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: const Text(
                      "Filter by Company Size:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _filterOptions.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                // _buildOverviewTab(),
                // Raw Data Tab
                _buildRawDataTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showFormModal(context);
        },
        icon: const Icon(Icons.add, color: Colors.black,),
        label: const Text("Add Data", style: TextStyle(color: Colors.black)),
        
        backgroundColor: Colors.orange[800],
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No data available'}) {
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
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showFormModal(context);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Your First Entry"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntryCard(QueryDocumentSnapshot item) {
    final companySize = item['company_size'] as String? ?? 'Unknown';
    final tariffCategory = item['tariff_category'] as String? ?? 'Unknown';
    final workingDays = item['working_days'] as int? ?? 0;
    final year = item['year'] as int? ?? 0;
    final month = item['month'] as int? ?? 0;

    // Format month as name
    String monthName = 'Unknown';
    if (month >= 1 && month <= 12) {
      final dateTime = DateTime(year, month);
      monthName = DateFormat('MMMM').format(dateTime);
    }

    Color cardColor;
    switch (companySize.toLowerCase()) {
      case 'small':
        cardColor = Colors.blue[50]!;
        break;
      case 'medium':
        cardColor = Colors.green[50]!;
        break;
      case 'large':
        cardColor = Colors.orange[50]!;
        break;
      default:
        cardColor = Colors.grey[50]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.business,
                color: Colors.orange[800],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$companySize Company",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tariff: $tariffCategory",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text("$workingDays days"),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text("$monthName $year"),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('analytics').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final data = snapshot.data!.docs;
        // Filter data if needed
        final filteredData = _selectedFilter == "All"
            ? data
            : data
                .where((doc) => doc['company_size'] == _selectedFilter)
                .toList();

        if (filteredData.isEmpty) {
          return _buildEmptyState(message: "No data for the selected filter");
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final item = filteredData[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Text(
                  'Company Size: ${item['company_size']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tariff: ${item['tariff_category']}',
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.business , color: Color.fromARGB(255, 255, 115, 0)),
                  backgroundColor: Colors.orangeAccent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDataRow(
                            'Working Days', '${item['working_days']}'),
                        const Divider(),
                        _buildDataRow('Year', '${item['year']}'),
                        const Divider(),
                        _buildDataRow('Month', '${item['month']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PredictPage()),
                        );
                      },
                      icon: const Icon(Icons.analytics, color: Colors.black),
                      label: const Text("Predict" , style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value) {
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

  void _showFormModal(BuildContext context) {
    final TextEditingController companySizeController = TextEditingController();

    final TextEditingController tariffCategoryController =
        TextEditingController();
    final TextEditingController workingDaysController = TextEditingController();
    final TextEditingController yearController = TextEditingController()
      ..text = DateTime.now().year.toString();
    final TextEditingController monthController = TextEditingController()
      ..text = DateTime.now().month.toString();

    // Company size options
    final List<String> companySizes = ['Small', 'Medium', 'Large'];
    // Tariff category options
    final List<String> tariffCategories = [
      'Residential',
      'Commercial',
      'Industrial'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Add Analytics Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Company Size Dropdown
                  Text(
                    'Company Size',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint: const Text('Select Company Size'),
                      isExpanded: true,
                      value: companySizeController.text.isEmpty
                          ? null
                          : companySizeController.text,
                      items: companySizes.map((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        companySizeController.text = newValue ?? '';
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tariff Category Dropdown
                  Text(
                    'Tariff Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint: const Text('Select Tariff Category'),
                      isExpanded: true,
                      value: tariffCategoryController.text.isEmpty
                          ? null
                          : tariffCategoryController.text,
                      items: tariffCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        tariffCategoryController.text = newValue ?? '';
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Working Days
                  Text(
                    'Working Days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: workingDaysController,
                    decoration: InputDecoration(
                      hintText: 'Enter working days',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Year and Month in a row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Year',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: yearController,
                              decoration: InputDecoration(
                                hintText: 'YYYY',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Month',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: monthController,
                              decoration: InputDecoration(
                                hintText: 'MM',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate inputs
                        if (companySizeController.text.isEmpty ||
                            tariffCategoryController.text.isEmpty ||
                            workingDaysController.text.isEmpty ||
                            yearController.text.isEmpty ||
                            monthController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill in all fields')),
                          );
                          return;
                        }

                        await _firestore.collection('analytics').add({
                          'company_size': companySizeController.text,
                          'tariff_category': tariffCategoryController.text,
                          'working_days':
                              int.tryParse(workingDaysController.text) ?? 0,
                          'year': int.tryParse(yearController.text) ?? 0,
                          'month': int.tryParse(monthController.text) ?? 0,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text(
                        'Submit Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
