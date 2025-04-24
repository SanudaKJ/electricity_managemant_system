import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Analytic extends StatefulWidget {
  const Analytic({super.key});

  @override
  State<Analytic> createState() => _AnalyticState();
}

class _AnalyticState extends State<Analytic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Analytics Page',
          style: TextStyle(fontSize: 24, color: Colors.orange[800]),
        ),
      ),
    );
  }
}
