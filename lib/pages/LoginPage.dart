import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterbill/pages/Home.dart';
import 'package:waterbill/utils/GoogleSignIn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            } else if (!snapshot.hasData) {
              return Center(
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
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            final provider =
                                Provider.of<GoogleSignInProvider>(context, listen: false);
                            provider.googleLogin();
                          },
                          label: const Text(
                            'Login With Google',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          icon: const Icon(Icons.person),
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              );
            }
            return const HomePage();
          },
        ),
      ),
    );
  }
}