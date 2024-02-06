import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Components/profileTextBox.dart';
import '../Screens/Profiles/userProfile.dart';

class VehicleProfile extends StatefulWidget {
  final String chassisNumber;
  final String department;
  final String driver;
  final String insuranceProvider;
  final String lastServiceDate;
  final String licensePlateNumber;
  final String makeAndModel;
  final String nextServiceDate;
  final String odometerReading;
  final String primaryUse;
  final String vehicleId;

  const VehicleProfile(
      {super.key,
      required this.chassisNumber,
      required this.department,
      required this.driver,
      required this.insuranceProvider,
      required this.lastServiceDate,
      required this.licensePlateNumber,
      required this.makeAndModel,
      required this.nextServiceDate,
      required this.odometerReading,
      required this.primaryUse,
      required this.vehicleId});

  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
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
      await vehicleCollection.doc(widget.vehicleId).update({field: newvalue});
    }
  }

  Uint8List? _image;
  final vehicleCollection = FirebaseFirestore.instance.collection('vehicles');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.licensePlateNumber),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 20),
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
                                    Icons.car_crash,
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
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextBox(
                      title: 'licensePlateNumber',
                      titleValue: widget.licensePlateNumber,
                      function: () => editField('licensePlateNumber'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                        title: 'driver',
                        titleValue: widget.driver,
                        function: () => editField('driver')),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'lastServiceDate',
                      titleValue: widget.lastServiceDate,
                      function: () => editField('lastServiceDate'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Next Service Date',
                      titleValue: widget.nextServiceDate,
                      function: () => editField('nextServiceDate'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Odometer Reading',
                      titleValue: widget.odometerReading,
                      function: () => editField('odometerReading'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Chassis Number',
                      titleValue: widget.chassisNumber,
                      function: () => editField('chassisNumber'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Insurance Provider',
                      titleValue: widget.insuranceProvider,
                      function: () => editField('insuranceProvider'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Make and Model',
                      titleValue: widget.makeAndModel,
                      function: () => editField('makeAndModel'),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox(
                      title: 'Primary Use',
                      titleValue: widget.primaryUse,
                      function: () => editField('primaryUse'),
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
    );
  }
}
