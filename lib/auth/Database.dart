// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waterbill/models/User.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  createUser(User user) {
    return _firestore.collection('users').add({
      'name': user.name,
      'location': user.location,
      'date': user.date,
      'readings': user.readings,
      'usage': user.usage,
      'excessConsumed': user.excessConsumed,
      'minimumBill': user.minimumBill,
      'dueDate': user.dueDate,
    });
  }

  doesUserExist(String name) async {
    final user = await _firestore.collection('users').where('name', isEqualTo: name).get();
    if (user.docs.isEmpty) {
      return null;
    } else {
      return User(
        name: user.docs[0]['name'],
        location: user.docs[0]['location'],
        date: user.docs[0]['date'],
        readings: user.docs[0]['readings'],
        usage: user.docs[0]['usage'],
        excessConsumed: user.docs[0]['excessConsumed'],
        minimumBill: user.docs[0]['minimumBill'],
        dueDate: user.docs[0]['dueDate'],
      );
    }
  }
}