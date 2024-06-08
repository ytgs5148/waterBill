import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbill/auth/Database.dart';
import 'package:waterbill/models/User.dart';
import 'package:waterbill/pages/Home.dart';
import 'package:waterbill/utils/Chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else {
            Navigator.pushNamed(context, '/analytics');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/create');
          });
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.create),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: Database().getUserSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong!'),
            );
          } else if (snapshot.hasData) {
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

            DateTime now = DateTime.now();
            DateTime previousMonth = DateTime(now.year, now.month - 1);
            String previousMonthYear = '${previousMonth.month}/${previousMonth.year}';
            String currentMonthYear = '${DateTime(now.year, now.month).month}/${DateTime(now.year, now.month).year}';

            Map<String, num> totalMoneyEarntPerMonthYear = {};

            for (var user in users) {
              for (var key in user.minimumBill.keys) {
                if (totalMoneyEarntPerMonthYear.containsKey(key)) {
                  totalMoneyEarntPerMonthYear[key] = (user.minimumBill[key] ?? 0) + (user.excessBill[key] ?? 0) + (totalMoneyEarntPerMonthYear[key] ?? 0);
                } else {
                  totalMoneyEarntPerMonthYear[key] = (user.minimumBill[key] ?? 0) + (user.excessBill[key] ?? 0);
                }
              }
            }

            Map<String, num> readingsPerMonthYear = {};

            for (var user in users) {
              for (var key in user.readings.keys) {
                if (readingsPerMonthYear.containsKey(key)) {
                  readingsPerMonthYear[key] = (user.readings[key] ?? 0) + (readingsPerMonthYear[key] ?? 0);
                } else {
                  readingsPerMonthYear[key] = (user.readings[key] ?? 0);
                }
              }
            }

            Map<String, num> usagePerMonthYear = {};

            for (var user in users) {
              for (var key in user.usage.keys) {
                if (usagePerMonthYear.containsKey(key)) {
                  usagePerMonthYear[key] = (user.usage[key] ?? 0) + (usagePerMonthYear[key] ?? 0);
                } else {
                  usagePerMonthYear[key] = (user.usage[key] ?? 0);
                }
              }
            }

            num percentageIncrease = ((totalMoneyEarntPerMonthYear[currentMonthYear]! - (totalMoneyEarntPerMonthYear[previousMonthYear] ?? 0)) / (totalMoneyEarntPerMonthYear[previousMonthYear] ?? 0)) * 100;
            num percentageIncreaseReadings = ((readingsPerMonthYear[currentMonthYear]! - (readingsPerMonthYear[previousMonthYear] ?? 0)) / (readingsPerMonthYear[previousMonthYear] ?? 0)) * 100;
            num percentageIncreaseUsage = ((usagePerMonthYear[currentMonthYear]! - usagePerMonthYear[currentMonthYear]!) / usagePerMonthYear[currentMonthYear]!) * 100;

            final chartDataTotalMoney = totalMoneyEarntPerMonthYear.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
            final chartDataReadings = readingsPerMonthYear.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
            final chartDataUsage = usagePerMonthYear.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();

            return Scaffold(
              appBar: AppBar(
                title: const Text('Analytics'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Card(
                        color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Money Earned This Month:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${totalMoneyEarntPerMonthYear[currentMonthYear]!.toStringAsFixed(2)} php',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    percentageIncrease >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: percentageIncrease >= 0 ? const Color.fromARGB(255, 0, 255, 8) : Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${percentageIncrease.abs().toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Readings this month:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                readingsPerMonthYear[currentMonthYear]!.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    percentageIncreaseReadings >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: percentageIncreaseReadings >= 0 ? const Color.fromARGB(255, 0, 255, 8) : Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${percentageIncreaseReadings.abs().toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Usage this month:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                usagePerMonthYear[currentMonthYear]!.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    percentageIncreaseUsage >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: percentageIncreaseUsage >= 0 ? const Color.fromARGB(255, 0, 255, 8) : Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${percentageIncreaseUsage.abs().toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        title: const ChartTitle(text: 'Total Money', textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        series: <BarSeries<ChartData, String>>[
                          BarSeries<ChartData, String>(
                            dataSource: chartDataTotalMoney,
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
                      SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        title: const ChartTitle(text: 'Usage', textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        series: <BarSeries<ChartData, String>>[
                          BarSeries<ChartData, String>(
                            dataSource: chartDataUsage,
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
                    ],
                  ),
                ),
              ),
            );
          }
          return const HomePage();
        },
      ),
    );
  }
}