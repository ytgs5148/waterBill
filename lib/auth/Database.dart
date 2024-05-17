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
      'excessBill': user.excessBill,
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
        date: user.docs[0]['date'].toDate(),
        readings: Map<String, num>.from(user.docs[0]['readings']),
        usage: Map<String, num>.from(user.docs[0]['usage']),
        excessConsumed: Map<String, num>.from(user.docs[0]['excessConsumed']),
        minimumBill: Map<String, num>.from(user.docs[0]['minimumBill']),
        dueDate: user.docs[0]['dueDate'].toDate(),
        excessBill: Map<String, num>.from(user.docs[0]['excessBill']),
      );
    }
  }

  getUserSnapshots() {
    return _firestore.collection('users').snapshots();
  }

  deleteUser(String username) {
    return _firestore.collection('users').where('name', isEqualTo: username).get().then((snapshot) {
      snapshot.docs.first.reference.delete();
    });
  }

  markPayment(String username, num excessConsumed, num excessBill, num readings, num usage) {
    String currentMonthYear = '${DateTime.now().month}/${DateTime.now().year}';

    return _firestore.collection('users').where('name', isEqualTo: username).get().then((snapshot) {
      snapshot.docs.first.reference.update({
        'excessConsumed': {currentMonthYear: excessConsumed},
        'excessBill': {currentMonthYear: excessBill},
        'readings': {currentMonthYear: readings},
        'usage': {currentMonthYear: usage},
      });
    });
  }
}