// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:waterbill/auth/Database.dart';
import 'package:waterbill/models/User.dart';
import 'package:waterbill/utils/StringFormatter.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({
    super.key,
  });

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minimumBill = TextEditingController();

  late DateTime currentSelectedDate;
  late DateTime dueDateSelected;

  @override
  void initState() {
    super.initState();

    currentSelectedDate = DateTime.now();
    dueDateSelected = DateTime.now().add(const Duration(days: 30));
  }

  Database db = Database();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                "Date: ${currentSelectedDate.month}/${currentSelectedDate.year}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: currentSelectedDate,
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != currentSelectedDate) {
                  setState(() {
                    currentSelectedDate = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text(
                "Due Date: ${dueDateSelected.day}/${dueDateSelected.month}/${dueDateSelected.year}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: dueDateSelected,
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != dueDateSelected) {
                  setState(() {
                    dueDateSelected = picked;
                  });
                }
              },
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _minimumBill,
              decoration: const InputDecoration(
                labelText: 'Minimum Bill',
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  User? user = await db.doesUserExist(toCamelCase(_nameController.text));

                  if (user != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('User already exists'),
                          content: const Text('This user already exists in the database'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    await db.createUser(User(
                      name: toCamelCase(_nameController.text), 
                      location: _locationController.text, 
                      date: currentSelectedDate, 
                      readings: {}, 
                      usage: {}, 
                      excessConsumed: {}, 
                      dueDate: dueDateSelected, 
                      minimumBill: { "${currentSelectedDate.month}/${currentSelectedDate.year}": double.parse(_minimumBill.text) },
                      excessBill: {}
                    ));

                    // open a poup and say added it 
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('User added'),
                          content: const Text('This user has been added to the database'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                _nameController.clear();
                                _locationController.clear();
                                _minimumBill.clear();
                                Navigator.pushNamed(context, '/create');
                              },
                              child: const Text('New User'),
                            ),
                            TextButton(
                              onPressed: () {
                                _nameController.clear();
                                _locationController.clear();
                                _minimumBill.clear();
                                Navigator.pushNamed(context, '/');
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                label: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                icon: const Icon(Icons.send),
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                foregroundColor: Colors.white,
                splashColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}