// ignore_for_file: library_private_types_in_public_api, unused_field, prefer_const_declarations

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Reading extends StatefulWidget {
  const Reading({super.key});

  @override
  _ReadingState createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  List<Map<String, dynamic>> _dataList = [];
  late Timer _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataList = [];
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _readECGData();
    });
  }

  Future<void> _readECGData() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        "https://healthmonitoringsystem-557b3-default-rtdb.firebaseio.com/will.json?orderBy=%22\$key%22&limitToLast=1";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        List<Map<String, dynamic>> dataList = [];
        data.forEach((key, value) {
          final ecg = value["ECG"]?.toStringAsFixed(3) ?? "NULL";
          final spo2 = value["SpO2"]?.toStringAsFixed(3) ?? "NULL";
          final temperature =
              value["Temperature"]?.toStringAsFixed(3) ?? "NULL";
          final heartrate = value["HeartRate"]?.toStringAsFixed(3) ?? "NULL";
          dataList.add({
            "ecg": ecg,
            "spo2": spo2,
            "temperature": temperature,
            "heartrate": heartrate,
          });
        });
        setState(() {
          _dataList = dataList;
          _isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to read data from Firebase');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel(); // Cancel the timer when the widget is disposed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 184, 181, 182),
        title: const Text(
          'Data from Firebase',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        child: ListView.builder(
          itemCount: _dataList.length,
          itemBuilder: (context, index) {
            final data = _dataList[index];
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
                  'ECG: ${data['ecg']}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SpO2: ${data['spo2']}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Temperature: ${data['temperature']}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('HeartRate: ${data['heartrate']}',
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
    );
  }
}
