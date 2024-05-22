import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [ Color.fromRGBO(85, 76, 240, 0.612), Color.fromRGBO(3, 1, 23, 100)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const Text(
                  'Water Bill',
                  style: TextStyle(
                    fontSize: 70,
                    color: Colors.white,
                    fontFamily: 'Grandstander',
                    fontWeight: FontWeight.w800
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 376,
                  width: 355,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),  // Change this line
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),  // Add this line
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text == 'abc1234') {
                      // navigate to /home
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect password'),
                        ),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}