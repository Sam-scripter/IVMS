import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../Components/profileTextBox.dart';

//TODO: IMPLEMENT USER ROLES TO EDIT THE PROFILE TEXT BOXES
//TODO: DISABLE EMAIL AMONG OTHER FIELDS FROM BEING EDITED
//TODO: SAVE PROFILE IMAGE IN THE DATABASE

class UserProfile extends StatefulWidget {
  UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Uint8List? _image;
  // late User? loggedInUser;

  void selectImage() async {
    Uint8List _img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = _img;
    });
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

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<String> getPositionName(String positionId) async {
    DocumentSnapshot positionSnapshot =
        await _firestore.collection('positions').doc(positionId).get();
    return positionSnapshot.exists
        ? positionSnapshot['name']
        : 'Unknown Position';
  }

  Future<String> getDepartmentName(String departmentId) async {
    DocumentSnapshot departmentSnapshot =
        await _firestore.collection('departments').doc(departmentId).get();
    return departmentSnapshot.exists
        ? departmentSnapshot['name']
        : 'Unknown Department';
  }

  Widget buildProfileTextBox(
      String title, Future<String> futureValue, Function()? function) {
    return FutureBuilder<String>(
      future: futureValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ProfileTextBox(
            title: title,
            titleValue: snapshot.data ?? 'Unknown',
            function: function,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Profile', style: GoogleFonts.lato()),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('employees')
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
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
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.lightBlueAccent),
                                        child: IconButton(
                                          onPressed: selectImage,
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                          iconSize: 35.0,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child:
                          TabBar(indicatorColor: Colors.lightBlueAccent, tabs: [
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
                                        "${userData['firstName'] ?? 'N/A'} ${userData['secondName'] ?? "N/A"} ",
                                    function: () => editField('firstName'),
                                    // "${userData['firstName']} ${userData['secondName']} "),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                      title: 'Email',
                                      titleValue:
                                          userData['emailAddress'] ?? 'N/A',
                                      function: () =>
                                          editField('emailAddress')),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Phone',
                                    titleValue:
                                        userData['mobileNumber'] ?? 'N/A',
                                    function: () => editField('mobileNumber'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'ID Number',
                                    titleValue: userData['idNumber'] ?? 'N/A',
                                    function: () => editField('idNumber'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Home Address',
                                    titleValue:
                                        userData['homeAddress'] ?? 'N/A',
                                    function: () => editField('homeAddress'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Gender',
                                    titleValue: userData['gender'] ?? 'N/A',
                                    function: () => editField('gender'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Date Of Birth',
                                    titleValue: userData['DOB'] ?? 'N/A',
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
                                    titleValue:
                                        userData['organizationNumber'] ?? 'N/A',
                                    function: () =>
                                        editField('organizationNumber'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Role',
                                    titleValue: userData['role'] ?? 'N/A',
                                    function: () => editField('role'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  buildProfileTextBox(
                                    'Position',
                                    getPositionName(
                                        userData['position'] ?? 'N/A'),
                                    () => editField('position'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  buildProfileTextBox(
                                    'Department',
                                    getDepartmentName(
                                        userData['department'] ?? 'N/A'),
                                    () => editField('department'),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  ProfileTextBox(
                                    title: 'Date Of Hire',
                                    titleValue: userData['DOH'] ?? 'N/A',
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
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error: Error is here'),
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
