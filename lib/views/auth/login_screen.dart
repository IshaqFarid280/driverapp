import 'package:driverapp/services/firestore_services.dart';
import 'package:driverapp/views/bottom_navigation/bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  LoginScreen({required this.role});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    print('Role in build: ${widget.role}');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (!_isLogin && widget.role == 'driver') ...[
              TextField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'Car Model'),
              ),
              // Add more fields for photos and documents if needed
            ],
            ElevatedButton(
              onPressed: () async {
                print('Button pressed. isLogin: $_isLogin');
                User? user;
                if (_isLogin) {
                  user = (await _auth.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  )).user;
                  print('User signed in: ${user?.uid}');
                } else {
                  user = (await _auth.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  )).user;
                  print('User signed up: ${user?.uid}');

                  String uid = user!.uid;
                  String email = _emailController.text;
                  String pass = _passwordController.text;

                  if (widget.role == 'driver') {
                    print('Creating driver in Firestore');
                    await _firestoreService.createDriver(
                      uid,
                      email,
                      _carModelController.text,
                      _passwordController.text
                    );
                  } else {
                    print('Creating user in Firestore');
                    await _firestoreService.createUser(uid, email, _passwordController.text);
                  }
                }

                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavigationScreen(userId: user!.uid),
                    ),
                  );
                }
              },
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
