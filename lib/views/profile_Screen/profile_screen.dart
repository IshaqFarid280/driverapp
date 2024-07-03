import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late DocumentSnapshot _userDoc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    _userDoc = await _firestoreService.getUserDetails(widget.userId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Email: ${_userDoc['email']}'),
            Text('Role: ${_userDoc['role']}'),
            if (_userDoc['role'] == 'driver') ...[
              Text('Car Model: ${_userDoc['carModel']}'),
              // Add more fields for photos and documents if needed
            ],
            // Add more fields to display user/driver details
          ],
        ),
      ),
    );
  }
}
