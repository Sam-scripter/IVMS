import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/employeeProfile.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final HttpsCallable _deleteUserCallable =
      FirebaseFunctions.instance.httpsCallable('deleteUser');
  final HttpsCallable _disableUserCallable =
      FirebaseFunctions.instance.httpsCallable('disableUser');

  Future<void> disableEmployee(String uid) async {
    try {
      final HttpsCallableResult result =
          await _disableUserCallable.call({'uid': uid});
      if (result.data['success']) {
        print('User successfully disabled');
      } else {
        print('Error disabling user: ${result.data['error']}');
      }
    } catch (e) {
      print('Error disabling user: $e');
    }
  }

  Future<void> deleteEmployeeAccount(String uid) async {
    try {
      final HttpsCallableResult result =
          await _deleteUserCallable.call({'uid': uid});
      if (result.data['success']) {
        print('User successfully deleted');
      } else {
        print('Error deleting user: ${result.data['error']}');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  void showDeleteDialog(String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Employee'),
          content: const Text(
              'Are you sure you want to delete this employee? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Disable Account'),
              onPressed: () async {
                await disableEmployee(uid);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete Account'),
              onPressed: () async {
                await deleteEmployeeAccount(uid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('employees').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error loading data');
            }
            if (snapshot.hasData) {
              int numberOfEmployees = snapshot.data!.docs.length;
              return Text(
                'Employees($numberOfEmployees)',
                style: GoogleFonts.lato(),
              );
            } else {
              return const Text('Employees');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/registration');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('employees')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text('Error loading data');
                }
                if (snapshot.hasData) {
                  List<Widget> employeeWidgets = [];
                  for (var employee in snapshot.data!.docs) {
                    var value = employee.data() as Map<String, dynamic>;
                    String employeeFirstName = value['firstName'];
                    String employeeSecondName = value['secondName'];
                    String employeeEmail = value['emailAddress'];
                    String employeeRole = value['role'];
                    String employeePosition = value['position'];
                    String employeeMobileNumber = value['mobileNumber'];
                    String employeeDOB = value['DOB'];
                    String employeeDOH = value['DOH'];
                    String employeeHomeAddress = value['homeAddress'];
                    String employeeDepartment = value['department'];
                    String employeeIdNumber = value['idNumber'];
                    String employeeOrganizationNumber =
                        value['organizationNumber'];
                    String employeeGender = value['gender'];

                    String employeeId = employee.id;

                    employeeWidgets.add(
                      ListTile(
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmployeeProfile(
                                        employeeFirstName: employeeFirstName,
                                        employeeSecondName: employeeSecondName,
                                        employeeEmail: employeeEmail,
                                        employeeRole: employeeRole,
                                        employeePosition: employeePosition,
                                        employeeMobileNumber:
                                            employeeMobileNumber,
                                        employeeDOB: employeeDOB,
                                        employeeDOH: employeeDOH,
                                        employeeHomeAddress:
                                            employeeHomeAddress,
                                        employeeDepartment: employeeDepartment,
                                        employeeIdNumber: employeeIdNumber,
                                        employeeOrganizationNumber:
                                            employeeOrganizationNumber,
                                        employeeGender: employeeGender)));
                          },
                          child: Row(
                            children: [
                              Text(
                                employeeFirstName,
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(fontSize: 20.0),
                                ),
                              ),
                              Text(
                                ' $employeeSecondName',
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(fontSize: 20.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDeleteDialog(employeeId);
                          },
                        ),
                      ),
                    );
                  }
                  return Column(children: employeeWidgets);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
