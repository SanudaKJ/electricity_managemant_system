import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:electricity_managemant_system/pages/home/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:electricity_managemant_system/pages/analytics/analytic.dart';
import 'package:electricity_managemant_system/pages/settings/setting.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => NavigationbarState();
}

class NavigationbarState extends State<Navigationbar> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    // const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    const home(),
    const Analytic(), // Analytics Page
    const Setting(), // Settings Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex], // Display the selected page
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.orange[800]!,
        backgroundColor: Colors.transparent,
        items: const [
          Icon(Icons.home, size: 25, ),
          Icon(Icons.analytics, size: 25, ),
          Icon(Icons.settings, size: 25, ),
        ],
        index: selectedIndex,
        height: 55,
        onTap: (index) {
          setState(() {
            selectedIndex = index; // Update the selected index
          });
        },
      ),
    );
  }
}