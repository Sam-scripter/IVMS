import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../Components/profileTextBox.dart';

class UserProfile extends StatefulWidget {
  UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String position = '';
  final currentUser = FirebaseAuth.instance.currentUser!;

  Uint8List? _image;
  // late User? loggedInUser;
  void selectImage() async {
    Uint8List _img = await pickImage(ImageSource.gallery);

    // Convert image to base64
    String base64Image = base64Encode(_img);

    // Save image to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUser.email)
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

  Future<Uint8List> pickImage(ImageSource source) async {
    final _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      Uint8List bytes = await _file.readAsBytes();
      return bytes;
    }
    return Uint8List(0);
  }

  Widget buildProfileTextBox(String title, Future<String> futureValue) {
    return FutureBuilder<String>(
      future: futureValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ProfileTextBox1(
            title: title,
            titleValue: snapshot.data ?? 'Unknown',
          );
        }
      },
    );
  }

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
                newvalue = value;
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
      await employeeCollection.doc(currentUser.email).update({field: newvalue});
    }
  }

  void fetchImageFromFirestore() async {
    try {
      // Replace 'images' with your Firestore collection name and document ID
      var snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUser.email)
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

  @override
  void initState() {
    super.initState();
    fetchImageFromFirestore();
    fetchPosition();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: position == 'Driver' ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Profile', style: GoogleFonts.lato()),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('employees')
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;

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

                List<Widget> myTabViews = [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileTextBox(
                            title: 'Name',
                            titleValue: userData['firstName'] ?? 'N/A',
                            function: () => editField('firstName'),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox(
                            title: 'Last Name',
                            titleValue: userData['secondName'] ?? "N/A",
                            function: () => editField('secondName'),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Email',
                            titleValue: userData['emailAddress'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox(
                            title: 'Phone',
                            titleValue: userData['mobileNumber'] ?? 'N/A',
                            function: () => editField('mobileNumber'),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox(
                            title: 'ID Number',
                            titleValue: userData['idNumber'] ?? 'N/A',
                            function: () => editField('idNumber'),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox(
                            title: 'Home Address',
                            titleValue: userData['homeAddress'] ?? 'N/A',
                            function: () => editField('homeAddress'),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Gender',
                            titleValue: userData['gender'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Date of Birth',
                            titleValue: userData['DOB'] ?? 'N/A',
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
                          ProfileTextBox1(
                            title: 'Position',
                            titleValue: userData['position'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Department',
                            titleValue: userData['department'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Organization Number',
                            titleValue: userData['organizationNumber'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Date of Hire',
                            titleValue: userData['DOH'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                          ProfileTextBox1(
                            title: 'Role',
                            titleValue: userData['role'] ?? 'N/A',
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ];

                if (position == 'Driver') {
                  myTabs.add(
                    Tab(
                      child: Text(
                        'My vehicle',
                        style: GoogleFonts.lato(),
                      ),
                    ),
                  );
                  myTabViews.add(
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileTextBox(
                              title: 'License Number',
                              titleValue: userData['licenseNumber'] ?? 'N/A',
                              function: () => editField('licenseNumber'),
                            ),
                            const SizedBox(height: 18),
                            ProfileTextBox(
                              title: 'License Expiry Date',
                              titleValue:
                                  userData['licenseExpiryDate'] ?? 'N/A',
                              function: () => editField('licenseExpiryDate'),
                            ),
                            const SizedBox(height: 18),
                            ProfileTextBox(
                              title: 'Vehicle Assigned',
                              titleValue: userData['vehicleAssigned'] ?? 'N/A',
                              function: () => editField('vehicleAssigned'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                                    Icons.person,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 20),
                          child: TabBar(
                              indicatorColor: Colors.lightBlueAccent,
                              tabs: myTabs),
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
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error Loading profile data'),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
