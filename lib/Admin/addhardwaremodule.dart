import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddHardwareModule extends StatefulWidget {
  const AddHardwareModule({Key? key});

  @override
  _AddHardwareModuleState createState() => _AddHardwareModuleState();
}

class _AddHardwareModuleState extends State<AddHardwareModule> {
  Future<List<DocumentSnapshot>> getAvailablePatients() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .where('hardwareId', isEqualTo: '')
        .get();
    return querySnapshot.docs;
  }

  Future<void> assignHardwareToPatient(
      DocumentSnapshot patient, DocumentSnapshot hardware) async {
    // Assign hardware to the patient
    String patientId = patient.id;

    // Check if the patient document exists
    DocumentSnapshot<Map<String, dynamic>> patientDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(patientId)
        .get();

    if (patientDoc.exists && patientDoc.data() != null) {
      // Update the patient's document with the hardware ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .update({'hardwareId': hardware.id});

      // Update the selected hardware's document
      await FirebaseFirestore.instance
          .collection('hardware')
          .doc(hardware.id)
          .update({'isAvailable': false});

      // Save hardware readings to "readings" collection
      await saveHardwareReadings(patientId, hardware.id);

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hardware allocated to patient successfully'),
        ),
      );
    } else {
      throw Exception('Patient document not found.');
    }
  }

  Future<void> saveHardwareReadings(String patientId, String hardwareId) async {
    final url =
        'https://healthmonitoringsystem-557b3-default-rtdb.firebaseio.com/will.json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        final readingsCollectionRef =
            FirebaseFirestore.instance.collection('readings');
        final patientReadingsRef =
            readingsCollectionRef.doc(patientId).collection('readings');

        final database = FirebaseDatabase.instance.reference().child('will');
        final latestReadingRef = database.limitToLast(1);

        latestReadingRef.onChildAdded.listen((event) async {
          final dynamicValue = event.snapshot.value;
          if (dynamicValue != null && dynamicValue is Map<dynamic, dynamic>) {
            final latestReading = dynamicValue;

            final ecgValue = latestReading['ECG']?.toString();
            final heartRateValue = latestReading['HeartRate']?.toString();
            final spo2Value = latestReading['SpO2']?.toString();
            final temperatureValue = latestReading['Temperature']?.toString();

            if (ecgValue != null &&
                heartRateValue != null &&
                spo2Value != null &&
                temperatureValue != null) {
              // Save the latest reading to the "readings" collection
              await patientReadingsRef.add({
                'hardwareId': hardwareId,
                'ECG': ecgValue,
                'HeartRate': heartRateValue,
                'SpO2': spo2Value,
                'Temperature': temperatureValue,
                'Timestamp': Timestamp.now(),
              });
            }
          }
        });
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Hardware'),
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Hardware:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hardware')
                    .where('isAvailable', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  List<QueryDocumentSnapshot> hardwareList =
                      snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: hardwareList.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot hardware = hardwareList[index];
                      return ListTile(
                        title: Text(hardware['hardwareName']),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 92, 100, 104),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            // Get available patients
                            List<DocumentSnapshot> availablePatients =
                                await getAvailablePatients();

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const ListTile(
                                        title: Text('Assign hardware'),
                                      ),
                                      const Divider(),
                                      if (availablePatients.isNotEmpty)
                                        ...availablePatients.map((patient) {
                                          return ListTile(
                                            title: Text(patient['name']),
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              await assignHardwareToPatient(
                                                patient,
                                                hardware,
                                              );
                                            },
                                          );
                                        }).toList()
                                      else
                                        const ListTile(
                                          title: Text('No available patients'),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Allocate'),
                        ),
                      );
                    },
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
