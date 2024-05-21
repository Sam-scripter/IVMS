import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Components/profileTextBox.dart';
import '../Screens/Profiles/userProfile.dart';

class VehicleProfile extends StatefulWidget {
  final String chassisNumber;
  final String department;
  final String insuranceProvider;
  final String licensePlateNumber;
  final String makeAndModel;
  final String vehicleId;
  final String fuelType;

  const VehicleProfile(
      {super.key,
      required this.chassisNumber,
      required this.department,
      required this.insuranceProvider,
      required this.licensePlateNumber,
      required this.makeAndModel,
      required this.vehicleId,
      required this.fuelType});

  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  Uint8List? _image;
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<Uint8List> pickImage(ImageSource source) async {
    final _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      Uint8List bytes = await _file.readAsBytes();
      return bytes;
    }
    return Uint8List(0);
  }

  void selectImage() async {
    Uint8List _img = await pickImage(ImageSource.gallery);

    // Convert image to base64
    String base64Image = base64Encode(_img);

    // Save image to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({
        'image': base64Image,
        // Add any additional fields you need
        'ImageCreatedAt':
            Timestamp.now(), // If you want to timestamp the upload
      });

      setState(() {
        _image = _img;
      });

      // Image saved successfully
      print('Image saved to Firestore.');
    } catch (e) {
      // Error saving image
      print('Error saving image: $e');
    }
  }

  void fetchImageFromFirestore() async {
    try {
      // Replace 'images' with your Firestore collection name and document ID
      var snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
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

  final vehicleCollection = FirebaseFirestore.instance.collection('vehicles');

  @override
  void initState() {
    super.initState();
    fetchImageFromFirestore();
  }

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
                                                Icons.car_crash,
                                                size: 100,
                                                color: Colors.white60,
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              );
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
                                color: Colors.lightBlueAccent,
                              ),
                              child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(
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
                    ProfileTextBox1(
                      title: 'licensePlateNumber',
                      titleValue: widget.licensePlateNumber,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox1(
                      title: 'Department',
                      titleValue: widget.department,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox1(
                        title: 'Fuel type', titleValue: widget.fuelType),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox1(
                      title: 'Chassis Number',
                      titleValue: widget.chassisNumber,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox1(
                      title: 'Insurance Provider',
                      titleValue: widget.insuranceProvider,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ProfileTextBox1(
                      title: 'Make and Model',
                      titleValue: widget.makeAndModel,
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
