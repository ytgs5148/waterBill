import 'package:flutter/material.dart';
import 'package:waterbill/pages/AnalyticsPage.dart';
import 'package:waterbill/pages/CreatePage.dart';
import 'package:waterbill/pages/Home.dart';
import 'package:waterbill/pages/LoginPage.dart';
import 'package:waterbill/pages/UsersPage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String args = settings.arguments.toString();

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/create':
        return MaterialPageRoute(builder: (_) => const CreatePage());
      case '/users':
        return MaterialPageRoute(builder: (_) => UsersPage(data: args, args: args));
      case '/analytics':
        return MaterialPageRoute(builder: (_) => const AnalyticsPage());
      default:
        return errorRoute(args);
    }
  }

  static Route<dynamic> errorRoute(String args) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ERROR: $args',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(_, '/home', (route) => false, arguments: args);
                },
                label: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 26, fontFamily: 'ShortStack'),
                ),
                icon: const Icon(Icons.arrow_forward),
                backgroundColor: const Color.fromRGBO(97, 239, 159, 0.612),
                foregroundColor: Colors.white,
              )
            ],
          ),
        )
      );
    });
  }
}
