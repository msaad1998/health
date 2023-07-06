import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHistory extends StatefulWidget {
  @override
  _PatientHistoryState createState() => _PatientHistoryState();
}

class _PatientHistoryState extends State<PatientHistory> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentSnapshot? _currentPatient;
  List<DocumentSnapshot> _readingList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        setState(() {
          _currentPatient = snapshot;
        });
        _fetchReadings();
      });
    }
  }

  void _fetchReadings() {
    if (_currentPatient != null) {
      _firestore
          .collection('readings')
          .doc(_currentPatient!.id)
          .collection('readings')
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          _readingList = querySnapshot.docs;
        });
      });
    }
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return dateTime.toString(); // Update the date formatting as desired
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Patient History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            if (_currentPatient != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${_currentPatient!['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Text(
                  //   'Age: ${_currentPatient!['age']}',
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // Text(
                  //   'Gender: ${_currentPatient!['gender']}',
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              'Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _readingList.length,
                itemBuilder: (context, index) {
                  var reading = _readingList[index];
                  Timestamp timestamp = reading['Timestamp'];
                  String formattedTimestamp = formatDate(timestamp);

                  return Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      leading: const Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.blue,
                        size: 50,
                      ),
                      title: Text(
                        'Timestamp: $formattedTimestamp',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ECG: ${reading['ECG']}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Heart Rate: ${reading['HeartRate']}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SpO2: ${reading['SpO2']}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Temperature: ${reading['Temperature']}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
