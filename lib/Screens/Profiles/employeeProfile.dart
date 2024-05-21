import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
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
  final currentUser = FirebaseAuth.instance.currentUser!;
  String position = '';
  String vehicleId = '';
  List<Widget> myTabViews = [];

  final employeeCollection = FirebaseFirestore.instance.collection('employees');

  Future<void> fetchVehicleId() async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('employees')
        .doc(currentUser.email);
    DocumentSnapshot snapshot = await documentReference.get();
    if (snapshot.exists) {
      var value = snapshot.data() as Map<String, dynamic>;
      setState(() {
        vehicleId = value['vehicleId'] ?? '';
      });
    }
  }

  void _fetchImageFromFirestore() async {
    try {
      // Replace 'images' with your Firestore collection name and document ID
      var snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(widget.employeeEmail)
          .get();

      if (snapshot.exists) {
        // Get the base64 string from Firestore
        String base64Image = snapshot.data()!['image'];

        // Update the UI
        setState(() {
          // Convert base64 string to Uint8List
          _image = base64Decode(base64Image);
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

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

  Future<void> fetchPosition() async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('employees')
        .doc(currentUser.email);
    DocumentSnapshot snapshot = await documentReference.get();
    if (snapshot.exists) {
      var value = snapshot.data() as Map<String, dynamic>;
      setState(() {
        position = value['position'];
      });
    }
  }

  void setTabViews() {
    setState(() {
      myTabViews = [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileTextBox1(
                  title: 'Name',
                  titleValue:
                      "${widget.employeeFirstName} ${widget.employeeSecondName} ",
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Email',
                  titleValue: widget.employeeEmail,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Phone',
                  titleValue: widget.employeeMobileNumber,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'ID Number',
                  titleValue: widget.employeeIdNumber,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Home Address',
                  titleValue: widget.employeeHomeAddress,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Gender',
                  titleValue: widget.employeeGender,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Date Of Birth',
                  titleValue: widget.employeeDOB,
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
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileTextBox1(
                  title: 'Organization Number',
                  titleValue: widget.employeeOrganizationNumber,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Role',
                  titleValue: widget.employeeRole,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Position',
                  titleValue: widget.employeePosition,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Department',
                  titleValue: widget.employeeDepartment,
                ),
                const SizedBox(
                  height: 18,
                ),
                ProfileTextBox1(
                  title: 'Date Of Hire',
                  titleValue: widget.employeeDOH,
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
      ];
    });

    if (position == 'Driver') {
      setState(() {
        myTabs.add(Tab(
          child: Text('Vehicle Details'),
        ));
        myTabViews.add(
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vehicles')
                  .doc(vehicleId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var vehicleData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileTextBox1(
                            title: 'Make and Model',
                            titleValue: vehicleData['makeAndModel']),
                        const SizedBox(
                          height: 18,
                        ),
                        ProfileTextBox1(
                            title: 'Vehicle number Plate',
                            titleValue: vehicleData['licensePlatenumber']),
                        const SizedBox(
                          height: 18,
                        ),
                        ProfileTextBox1(
                            title: 'Fuel Type',
                            titleValue: vehicleData['fuelType']),
                        const SizedBox(
                          height: 18,
                        ),
                        ProfileTextBox1(
                            title: 'Fuel Consumption',
                            titleValue: vehicleData['fuelConsumption']),
                        const SizedBox(
                          height: 18,
                        ),
                        ProfileTextBox1(
                            title: 'Insurance Provider',
                            titleValue: vehicleData['insuranceProvider']),
                        const SizedBox(
                          height: 18,
                        ),
                        ProfileTextBox1(
                            title: 'Department',
                            titleValue: vehicleData['department']),
                        const SizedBox(
                          height: 18,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                      ],
                    ),
                  ));
                }
                return Container();
              }),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosition();
    fetchVehicleId();
    _fetchImageFromFirestore();
    setTabViews();
  }

  List<Tab> myTabs = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: position == 'Driver' ? 3 : 2,
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
                      padding: const EdgeInsets.only(bottom: 5.0, top: 17),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: InteractiveViewer(
                                          child: _image != null
                                              ? Image.memory(
                                                  _image!,
                                                  fit: BoxFit.contain,
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 100,
                                                  color: Colors.white60,
                                                ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: _image != null
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
                                      Icons.car_crash,
                                      size: 60,
                                    ),
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
              child:
                  TabBar(indicatorColor: Colors.lightBlueAccent, tabs: myTabs),
            ),
            Expanded(
              child: TabBarView(
                children: myTabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
