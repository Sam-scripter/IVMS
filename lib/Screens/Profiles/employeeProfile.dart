import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/userProfile.dart';

import '../../Components/profileTextBox.dart';

class EmployeeProfile extends StatefulWidget {
  final String employeeFirstName;
  final String employeeSecondName;
  final String employeeEmail;
  final String employeeRole;
  final String employeePosition;
  final String employeeMobileNumber;
  final String employeeDOB;
  final String employeeDOH;
  final String? employeeVehicle;
  final String employeeHomeAddress;
  final String employeeDepartment;
  final String employeeIdNumber;
  final String employeeOrganizationNumber;
  final String employeeGender;

  const EmployeeProfile(
      {super.key,
      required this.employeeFirstName,
      required this.employeeSecondName,
      required this.employeeEmail,
      required this.employeeRole,
      required this.employeePosition,
      required this.employeeMobileNumber,
      required this.employeeDOB,
      required this.employeeDOH,
      this.employeeVehicle,
      required this.employeeHomeAddress,
      required this.employeeDepartment,
      required this.employeeIdNumber,
      required this.employeeOrganizationNumber,
      required this.employeeGender});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  Uint8List? _image;

  final employeeCollection = FirebaseFirestore.instance.collection('employees');

  Future<void> editField(String field) async {
    String newvalue = '';
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Edit $field',
              style: const TextStyle(color: Colors.white),
            ),
            content: TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Enter new $field',
                  hintStyle: const TextStyle(color: Colors.grey)),
              onChanged: (value) {
                setState(() {
                  newvalue = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(newvalue),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });

    if (newvalue.trim().isNotEmpty) {
      await employeeCollection
          .doc(widget.employeeEmail)
          .update({field: newvalue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.employeeFirstName} ${widget.employeeSecondName}",
            style: GoogleFonts.lato(),
          ),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(_image!),
                                  backgroundColor: Colors.white60,
                                  radius: 65,
                                )
                              : const CircleAvatar(
                                  backgroundImage: null,
                                  backgroundColor: Colors.white60,
                                  radius: 65,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            left: 80,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  color: Colors.lightBlueAccent),
                              child: const IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                iconSize: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: TabBar(indicatorColor: Colors.lightBlueAccent, tabs: [
                Tab(
                  child: Text(
                    'User Details',
                    style: GoogleFonts.lato(),
                  ),
                ),
                Tab(
                  child: Text(
                    'Organization Details',
                    style: GoogleFonts.lato(),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileTextBox(
                            title: 'Name',
                            titleValue:
                                "${widget.employeeFirstName} ${widget.employeeSecondName} ",
                            function: () => editField('firstName'),
                            // "${userData['firstName']} ${userData['secondName']} "),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                              title: 'Email',
                              titleValue: widget.employeeEmail,
                              function: () => editField('emailAddress')),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Phone',
                            titleValue: widget.employeeMobileNumber,
                            function: () => editField('mobileNumber'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'ID Number',
                            titleValue: widget.employeeIdNumber,
                            function: () => editField('idNumber'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Home Address',
                            titleValue: widget.employeeHomeAddress,
                            function: () => editField('homeAddress'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Gender',
                            titleValue: widget.employeeGender,
                            function: () => editField('gender'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Date Of Birth',
                            titleValue: widget.employeeDOB,
                            function: () => editField('DOB'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileTextBox(
                            title: 'Organization Number',
                            titleValue: widget.employeeOrganizationNumber,
                            function: () => editField('organizationNumber'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Role',
                            titleValue: widget.employeeRole,
                            function: () => editField('role'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Position',
                            titleValue: widget.employeePosition,
                            function: () => editField('position'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Department',
                            titleValue: widget.employeeDepartment,
                            function: () => editField('department'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ProfileTextBox(
                            title: 'Date Of Hire',
                            titleValue: widget.employeeDOH,
                            function: () => editField('DOH'),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
