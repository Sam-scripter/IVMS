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
                child: const AddDepartment(),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DepartmentProfile(
                              departmentName: departmentName,
                              departmentId: departmentId,
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

class AddDepartment extends StatefulWidget {
  const AddDepartment({super.key});

  @override
  _AddDepartmentState createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  String newDepartmentTitle = "";
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> positionControllers = [];

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    for (var controller in positionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPositionField() {
    setState(() {
      positionControllers.add(TextEditingController());
    });
  }

  Future<void> _saveDepartment() async {
    if (newDepartmentTitle.isNotEmpty) {
      DocumentReference departmentRef =
          await FirebaseFirestore.instance.collection('departments').add({
        'name': newDepartmentTitle,
        'timestamp': FieldValue.serverTimestamp(),
      });

      for (var controller in positionControllers) {
        if (controller.text.isNotEmpty) {
          await departmentRef.collection('positions').add({
            'name': controller.text,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Please enter a valid department name.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Form(
        key: _formKey,
        child: Container(
          color: Color(0xFF0A0D22),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30)),
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
                      style:
                          GoogleFonts.lato(textStyle: TextStyle(fontSize: 20)),
                    )),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Department Name'),
                      autofocus: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        newDepartmentTitle = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in the department';
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ...positionControllers.map((controller) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: TextFormField(
                          controller: controller,
                          decoration:
                              const InputDecoration(hintText: 'Position'),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please fill in this field';
                            }
                          },
                        ),
                      );
                    }).toList(),
                    ElevatedButton(
                      onPressed: _addPositionField,
                      child: Text(
                        'Add Position',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Dismiss the keyboard
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await _saveDepartment();
                          } catch (e) {
                            print(e);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          print('error');
                        }
                      },
                      child: Text(
                        'Add Department',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      if (_isLoading)
        Container(
          color: Colors.black.withOpacity(0.7),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }
}
