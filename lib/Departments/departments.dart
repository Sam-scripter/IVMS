import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'departmentProfile.dart';

class Departments extends StatefulWidget {
  const Departments({super.key});

  @override
  State<Departments> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<Departments> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<dynamic> departmentsStream() async {
    await for (var snapshot
        in _firestore.collection('departments').snapshots()) {
      for (var department in snapshot.docs) {
        var value = department.data();
        print(value);
      }
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    await _firestore.collection('departments').doc(departmentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('departments').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfDepartments = snapshot.data!.docs.length;
              return Text(
                'Departments ($numberOfDepartments)',
                style: GoogleFonts.lato(),
              );
            } else {
              return Text('Departments');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddDepartment(),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('departments')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> departmentWidgets = [];
                for (var department in snapshot.data!.docs) {
                  var value = department.data() as Map<String, dynamic>;
                  String departmentName = value['name'].toString();
                  String departmentId = department.id;

                  departmentWidgets.add(
                    ListTile(
                      title: Text(
                        departmentName,
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 20.0)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteDepartment(departmentId);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DepartmentProfile(
                              departmentName: departmentName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return SingleChildScrollView(
                    child: Column(children: departmentWidgets));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}

class AddDepartment extends StatelessWidget {
  const AddDepartment({super.key});

  @override
  Widget build(BuildContext context) {
    String newDepartmentTitle = "";
    return Container(
      color: Color(0xFF0A0D22),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30)),
          color: Color(0xFF1D1E33),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  'Add Department',
                  style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 20)),
                )),
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    newDepartmentTitle = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newDepartmentTitle.isNotEmpty) {
                      // Check if the department title is not empty before adding
                      FirebaseFirestore.instance.collection('departments').add({
                        'name': newDepartmentTitle,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    } else {
                      // Handle case where the department title is empty
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: const Text(
                                'Please enter a valid department name.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    'Add Department',
                    style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
