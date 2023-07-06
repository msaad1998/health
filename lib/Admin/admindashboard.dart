// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_monitoring/Admin/changeadminpass.dart';
import 'package:health_monitoring/Admin/createuser.dart';
import 'package:health_monitoring/Admin/addhardwaremodule.dart';
import 'package:health_monitoring/Admin/removehardwaremodule.dart';

import 'package:health_monitoring/Welcome/mainscreen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(242, 240, 234, 236),
          body: SafeArea(
            child: Column(children: [
              Container(
                color: const Color.fromARGB(255, 184, 181, 182),
                child: Row(children: [
                  PopupMenuButton(
                    icon: const Icon(Icons.menu_rounded),
                    color: const Color.fromARGB(255, 59, 58, 58),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: TextButton(
                          child: const Text(
                            'ADD Hardware',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddHardwareModule(),
                                  ));
                            });
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          child: const Text(
                            'REMOVE Hardware',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RemoveHardwareModule(),
                                  ));
                            });
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateUser(),
                                  ));
                            });
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          child: const Text(
                            'Change Password',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminPass(),
                                  ));
                            });
                          },
                        ),
                      ),
                      // PopupMenuItem(
                      //   child: TextButton(
                      //     child: const Text(
                      //       'Contact us',
                      //       style: TextStyle(color: Colors.white, fontSize: 20),
                      //     ),
                      //     onPressed: () {
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => MyContact()));
                      //     },
                      //   ),
                      // ),
                      PopupMenuItem(
                        child: TextButton(
                          onPressed: () {
                            logout(context);
                          },
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 218,
                  ),
                  const Text(
                    'Admin',
                    style: TextStyle(
                        color: Color(0xff4c505b),
                        fontSize: 30,
                        fontWeight: FontWeight.w700),
                  ),
                  // const SizedBox(
                  //   width: 30,
                  // ),
                ]),
              ),
              const SizedBox(
                height: 60,
              ),
            ]),
          ),
        ),
      );
    });
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }
}
