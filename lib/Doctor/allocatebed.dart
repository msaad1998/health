// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllocateBedPage extends StatefulWidget {
  @override
  _AllocateBedPageState createState() => _AllocateBedPageState();
}

class _AllocateBedPageState extends State<AllocateBedPage> {
  Future<List<DocumentSnapshot>> getAvailablePatients() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .where('bedId', isEqualTo: '')
        .get();
    return querySnapshot.docs;
  }

  Future<void> assignBedToPatient(
      DocumentSnapshot patient, DocumentSnapshot bed) async {
    // Assign bed to the patient
    String patientId = patient.id;

    // Check if the patient document exists
    DocumentSnapshot<Map<String, dynamic>> patientDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(patientId)
        .get();

    if (patientDoc.exists && patientDoc.data() != null) {
      // Update the patient's document with the bed ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .update({'bedId': bed.id});

      // Update the selected bed's document
      await FirebaseFirestore.instance
          .collection('bed')
          .doc(bed.id)
          .update({'isAvailable': false});

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bed allocated to patient successfully')),
      );
    } else {
      throw Exception('Patient document not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Bed'),
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Beds:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bed')
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
                  List<QueryDocumentSnapshot> bedList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: bedList.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot bed = bedList[index];
                      return ListTile(
                        title: Text(bed['bedName']),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // fixedSize: const Size(240, 80),
                            // ignore: deprecated_member_use
                            primary: const Color.fromARGB(255, 92, 100, 104),
                            shape: RoundedRectangleBorder(
                                //to set border radius to button
                                borderRadius: BorderRadius.circular(30)),
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
                                        title: Text('Assign Bed'),
                                      ),
                                      const Divider(),
                                      if (availablePatients.isNotEmpty)
                                        ...availablePatients.map((patient) {
                                          return ListTile(
                                            title: Text(patient['name']),
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              await assignBedToPatient(
                                                  patient, bed);
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
                          child: const Text(
                            'Allocate',
                          ),
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
