import 'package:flutter/material.dart';
import 'package:waterbill/pages/Users.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: UsersPage(),
      ),
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
            Navigator.pushNamed(context, '/');
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
    );
  }
}
