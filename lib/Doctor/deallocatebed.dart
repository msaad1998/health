// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignedBedsPage extends StatefulWidget {
  @override
  _AssignedBedsPageState createState() => _AssignedBedsPageState();
}

class _AssignedBedsPageState extends State<AssignedBedsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Beds'),
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      ),
      backgroundColor: const Color.fromARGB(255, 184, 181, 182),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Patients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('bedId', isNotEqualTo: '')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  List<QueryDocumentSnapshot> patientList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot patient = patientList[index];
                      String bedId = patient['bedId'];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('bed')
                            .doc(bedId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading...');
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text('Bed not found');
                          }
                          String bedName = snapshot.data!.get('bedName');
                          return ListTile(
                            title: Text(patient['name']),
                            subtitle:
                                Text('Bed ID: $bedId, Bed Name: $bedName'),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                //fixedSize: const Size(240, 80),
                                primary:
                                    const Color.fromARGB(255, 92, 100, 104),
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Deallocate Bed'),
                                      content: Text(
                                          'Are you sure you want to deallocate the bed from ${patient['name']}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            // Deallocate bed from the patient
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(patient.id)
                                                .update({'bedId': ''});

                                            // Update the bed document
                                            await FirebaseFirestore.instance
                                                .collection('bed')
                                                .doc(bedId)
                                                .update({'isAvailable': true});

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Deallocate'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Deallocate',
                              ),
                            ),
                          );
                        },
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
