import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<DocumentSnapshot> _patientList = [];
  DocumentSnapshot? _selectedPatient;
  List<DocumentSnapshot> _readingList = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  void _fetchPatients() {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _patientList = querySnapshot.docs;
      });
    });
  }

  void _fetchReadings() {
    if (_selectedPatient != null) {
      FirebaseFirestore.instance
          .collection('readings')
          .doc(_selectedPatient!.id)
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
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient List',
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
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.blue, Colors.lightBlueAccent],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select a Patient',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            DropdownButton(
              value: _selectedPatient,
              hint: const Text('Select a patient',
                  style: TextStyle(color: Colors.black)),
              onChanged: (value) {
                setState(() {
                  _selectedPatient = value as DocumentSnapshot?;
                  _fetchReadings();
                });
              },
              items: _patientList.map((patient) {
                return DropdownMenuItem(
                  value: patient,
                  child: Text(patient['name'],
                      style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Readings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
                          Text('ECG: ${reading['ECG']}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Heart Rate: ${reading['HeartRate']}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('SpO2: ${reading['SpO2']}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Temperature: ${reading['Temperature']}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
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
