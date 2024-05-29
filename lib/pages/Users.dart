import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waterbill/auth/Database.dart';
import 'package:waterbill/models/User.dart';
import 'package:waterbill/pages/LoginPage.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final searchInputNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: TextField(
                onChanged: (value) {
                  searchInputNotifier.value = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                ),
              ),
            ),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: searchInputNotifier,
              builder: (context, searchInput, child) {
                return StreamBuilder<QuerySnapshot>(
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
                
                      List<User> sortedByDueDate = users..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
                
                      if (searchInput.isNotEmpty) {
                        sortedByDueDate = sortedByDueDate.where((user) {
                          return user.name.toLowerCase().contains(searchInput.toLowerCase()) || user.location.toLowerCase().contains(searchInput.toLowerCase());
                        }).toList();
                      }
                
                      return Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: ListView.builder(
                          itemCount: sortedByDueDate.length,
                          itemBuilder: (context, index) {
                            final user = sortedByDueDate[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(user.name),
                                subtitle: Text('Location: ${user.location}\n Due Date In: ${user.dueDate!.difference(DateTime.now()).inDays} days'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/users', arguments: user.name);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const LoginPage();
                  },
                );
              }
            )
          ),
        ],
      ),
    );
  }
}