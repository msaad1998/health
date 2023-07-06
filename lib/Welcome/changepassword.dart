// // ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:health_monitoring_system/Doctor/doctordashboard.dart';

// class AdminPass extends StatefulWidget {
//   @override
//   _AdminPassState createState() => _AdminPassState();
// }

// class _AdminPassState extends State<AdminPass> {
//   final _formKey = GlobalKey<FormState>();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _auth = FirebaseAuth.instance;

//   String _errorMessage = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 184, 181, 182),
//       ),
//       backgroundColor: const Color.fromARGB(255, 184, 181, 182),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               const Text(
//                 'Change Password',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     fontSize: 35),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                 controller: _newPasswordController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   hintText: 'New Password',
//                   enabled: true,
//                   contentPadding:
//                       const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.white),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.white),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a new password';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   hintText: 'Confirm Password',
//                   enabled: true,
//                   contentPadding:
//                       const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.white),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.white),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please confirm your new password';
//                   }
//                   if (value != _newPasswordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   fixedSize: const Size(240, 80),
//                   alignment: Alignment.center,
//                   primary: const Color.fromARGB(255, 92, 100, 104),
//                   shape: RoundedRectangleBorder(
//                       //to set border radius to button
//                       borderRadius: BorderRadius.circular(30)),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const DoctorDashboard()));

//                   if (_formKey.currentState!.validate()) {
//                     _changePassword(_newPasswordController.text);
//                   }
//                 },
//                 child: const Text('Change Password'),
//               ),
//               if (_errorMessage.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     _errorMessage,
//                     style: const TextStyle(
//                       color: Colors.red,
//                       fontSize: 16.0,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _changePassword(String newPassword) async {
//     try {
//       await _auth.currentUser!.updatePassword(newPassword);
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Success'),
//             content: const Text('Password changed successfully'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _errorMessage = e.message!;
//       });
//     }
//   }
// }
