import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Reports/Departmental%20Reports/pdfOverallDepartmentReport.dart';

import '../../Reports/Departmental Reports/pdfDepartmentReport.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  String userName = '';
  final DepartmentPdfService departmentPdfService = DepartmentPdfService();
  final OverallDepartmentReportService overallDepartmentPdfService =
      OverallDepartmentReportService();

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser?.email;
    if (user != null) {
      DocumentReference document =
          FirebaseFirestore.instance.collection('employees').doc(user);
      DocumentSnapshot snapshot = await document.get();
      if (snapshot.exists) {
        var value = snapshot.data() as Map<String, dynamic>;

        setState(() {
          userName = '${value['firstName']} ${value['secondName']}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Department',
          style: GoogleFonts.lato(
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final data = await overallDepartmentPdfService
              .generateOverallDepartmentsReport();
          overallDepartmentPdfService.savePdfFile('IVMS PDF', data);
        },
        label: const Text('Generate Overall Report'),
        icon: const Icon(Icons.file_copy),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('departments')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> departments = [];
                for (var department in snapshot.data!.docs) {
                  var value = department.data() as Map<String, dynamic>;
                  String departmentName = value['name'] ?? '';
                  departments.add(
                    Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Color(0xFF111328),
                      child: ListTile(
                        title: Text(
                          departmentName,
                          style: GoogleFonts.lato(
                            fontSize: 17,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                        onTap: () async {
                          await _getCurrentUser();
                          final data = await departmentPdfService
                              .generateDepartmentPdf(userName, departmentName);
                          departmentPdfService.savePdfFile('IVMS PDF', data);
                        },
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: departments,
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          SizedBox(
            height: 60,
          ),
        ]),
      ),
    );
  }
}
