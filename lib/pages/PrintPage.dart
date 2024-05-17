import 'package:flutter/material.dart';
import 'package:waterbill/auth/Database.dart';

class PrintPage extends StatefulWidget {
  final String data;
  final String args;

  const PrintPage({
    super.key,
    required this.data,
    required this.args,
  });

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  @override
  void initState() {
    super.initState();
  }

  Database db = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}