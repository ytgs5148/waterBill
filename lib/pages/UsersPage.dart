// ignore_for_file: file_names, use_build_context_synchronously, must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbill/auth/Database.dart';
import 'package:waterbill/models/User.dart';
import 'package:waterbill/utils/Chart.dart';
import 'package:waterbill/utils/GoogleSignIn.dart';
import 'package:collection/collection.dart';
import 'package:waterbill/utils/PDFManager.dart';
import '../utils/FileHandleAPI.dart';
import 'package:pdf/widgets.dart' as pw;

class UsersPage extends StatelessWidget {
  final String data;
  final String args;

  UsersPage({
    super.key,
    required this.data,
    required this.args,
  });
 
  Database db = Database();

  PdfColor themeColor = PdfColors.black;
  pw.Font font = pw.Font.courier();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Bill Admin Panel'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Database().getUserSnapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.docs.isEmpty) {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    }

                    List<User> users = snapshot.data!.docs.map((DocumentSnapshot document) {
                      final user = User(
                        name: document['name'],
                        location: document['location'],
                        date: document['date'].toDate(),
                        readings: Map<String, num>.from(document['readings']),
                        usage: Map<String, num>.from(document['usage']),
                        excessConsumed: Map<String, num>.from(document['excessConsumed']),
                        minimumBill: Map<String, num>.from(document['minimumBill']),
                        dueDate: document['dueDate'].toDate(),
                        excessBill: Map<String, num>.from(document['excessBill']),
                      );
                      return user;
                    }).toList();

                    User? user = users.firstWhereOrNull((element) => element.name == data);

                    if (user == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      });
                      return const Center(child: Text('User not found'));
                    }

                    DateTime now = DateTime.now();
                    DateTime previousMonth = DateTime(now.year, now.month - 1);
                    String previousMonthYear = '${previousMonth.month}/${previousMonth.year}';
                    String currentMonthYear = '${DateTime(now.year, now.month).month}/${DateTime(now.year, now.month).year}';
                    num minBillPreviousMonth = user.minimumBill[previousMonthYear] ?? 0;
                    num excessBillPreviousMonth = user.excessBill[previousMonthYear] ?? 0;

                    Map<String, num> totalBill = {};
                    user.minimumBill.forEach((key, value) {
                      totalBill[key] = value + (user.excessBill[key] ?? 0);
                    });

                    double minimumBill = 0;
                    double excessConsumed = 0;
                    double excessBill = 0;
                    double readings = 0;
                    double total = 0;
                    double usage = 0;

                    final chartDataReadings = user.readings.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
                    final chartDataTotalBill = totalBill.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();

                    chartDataReadings.sort((a, b) => a.month.compareTo(b.month));
                    chartDataTotalBill.sort((a, b) => a.month.compareTo(b.month));

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton.extended(
                                heroTag: null,
                                onPressed: () {
                                  // Check if the user has already paid for the current month
                                  if (user.minimumBill[currentMonthYear] != null && user.excessBill[currentMonthYear] != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Payment already marked'),
                                          content: const Text('The user has already paid for this month'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async {
                                                final pdfFile = await PdfInvoiceApi.generate(
                                                  themeColor,
                                                  pw.Font.courier(),
                                                  user
                                                );

                                                FileHandleApi.openFile(pdfFile);
                                              },
                                              child: const Text('Print'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          setState(() {
                                            minimumBill = user.minimumBill[currentMonthYear]?.toDouble() ?? 0;
                                            total = minimumBill + excessBill;
                                          });
                                          TextEditingController minimumBillController = TextEditingController(text: minimumBill.toString());

                                          return BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                            child: Dialog(
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width * 1,
                                                height: MediaQuery.of(context).size.height * 1,
                                                child: AlertDialog(
                                                  title: const Text('Mark Payment'),
                                                  content: Column(
                                                    children: <Widget>[
                                                      TextField(
                                                        controller: minimumBillController,
                                                        decoration: const InputDecoration(labelText: 'Minimum Bill (php)'),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          minimumBill = double.tryParse(value) ?? 0;
                                                          setState(() {
                                                            total = minimumBill + excessBill;
                                                          });
                                                        },
                                                      ),
                                                      TextField(
                                                        decoration: const InputDecoration(labelText: 'Excess Consumed'),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          excessConsumed = double.tryParse(value) ?? 0;
                                                        },
                                                      ),
                                                      TextField(
                                                        decoration: const InputDecoration(labelText: 'Readings'),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          readings = double.tryParse(value) ?? 0;
                                                        },
                                                      ),
                                                      TextField(
                                                        decoration: const InputDecoration(labelText: 'Usage'),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          usage = double.tryParse(value) ?? 0;
                                                        },
                                                      ),
                                                      TextField(
                                                        decoration: const InputDecoration(labelText: 'Excess Bill'),
                                                        keyboardType: TextInputType.number,
                                                        onChanged: (value) {
                                                          excessBill = double.tryParse(value) ?? 0;
                                                          setState(() {
                                                            total = minimumBill + excessBill;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      Text('Total: $total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('Save and Print'),
                                                      onPressed: () async {
                                                        await db.markPayment(user.name, excessConsumed, excessBill, readings, usage);
                                                
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text('Payment marked'),
                                                              content: const Text('The payment has been marked and the user has been notified'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    final pdfFile = await PdfInvoiceApi.generate(
                                                                      themeColor,
                                                                      pw.Font.courier(),
                                                                      user
                                                                    );

                                                                    FileHandleApi.openFile(pdfFile);
                                                                  },
                                                                  child: const Text('Print'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                label: const Text(
                                  'Mark Payment',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                icon: const Icon(Icons.payment),
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                splashColor: Colors.grey,
                              ),
                              FloatingActionButton.extended(
                                heroTag: null,
                                onPressed: () {
                                  db.deleteUser(user.name);

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('User deleted'),
                                        content: const Text('This user has been deleted from the database'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context, '/');
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                label: const Text(
                                  'Delete User',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                icon: const Icon(Icons.delete),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                          Card(
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  RichText(
                                    text: TextSpan(
                                      text: 'Name: ',
                                      style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(text: user.name, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Location: ',
                                      style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(text: user.location, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Bill (Previous): ',
                                      style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(text: '${minBillPreviousMonth + excessBillPreviousMonth} php', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Date: ',
                                      style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(text: '${user.date}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SfCartesianChart(
                            primaryXAxis: const CategoryAxis(),
                            title: const ChartTitle(text: 'Readings', textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            series: <BarSeries<ChartData, String>>[
                              BarSeries<ChartData, String>(
                                dataSource: chartDataReadings,
                                xValueMapper: (ChartData data, _) => data.month,
                                yValueMapper: (ChartData data, _) => data.value,
                                animationDuration: 2000,
                              )
                            ],
                            trackballBehavior: TrackballBehavior(
                              enable: true,
                              activationMode: ActivationMode.longPress,
                              shouldAlwaysShow: true,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SfCartesianChart(
                            primaryXAxis: const CategoryAxis(),
                            title: const ChartTitle(text: 'Total Bill', textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            series: <BarSeries<ChartData, String>>[
                              BarSeries<ChartData, String>(
                                dataSource: chartDataTotalBill,
                                xValueMapper: (ChartData data, _) => data.month,
                                yValueMapper: (ChartData data, _) => data.value,
                                animationDuration: 2000,
                              )
                            ],
                            trackballBehavior: TrackballBehavior(
                              enable: true,
                              activationMode: ActivationMode.longPress,
                              shouldAlwaysShow: true,
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text('No players in lobby'));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
