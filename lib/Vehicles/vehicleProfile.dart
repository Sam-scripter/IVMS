import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../Components/profileTextBox.dart';
import 'package:image/image.dart' as img;

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
    try {
      // Pick an image
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        Uint8List _img = await pickedFile.readAsBytes();

        // Resize image
        img.Image decodedImage = img.decodeImage(_img)!;
        img.Image resizedImage =
            img.copyResize(decodedImage, width: 800); // Resize to 800px wide
        Uint8List resizedImageData =
            Uint8List.fromList(img.encodePng(resizedImage));

        // Upload to Firebase Storage
        String filePath =
            'images/${widget.licensePlateNumber}/${DateTime.now().millisecondsSinceEpoch}.png';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(filePath)
            .putData(resizedImageData);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save download URL to Firestore
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .update({
          'imageUrl': downloadUrl,
          'ImageCreatedAt': Timestamp.now(),
        });

        setState(() {
          _image = _img;
        });

        print('Image saved to Firebase Storage and URL saved to Firestore.');
      } else {
        print('No image selected.');
      }
    } catch (e) {
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
        // Get the download URL from Firestore
        String imageUrl = snapshot.data()!['imageUrl'];

        // Download the image data from the URL
        http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          Uint8List imageData = response.bodyBytes;

          // Update the UI
          setState(() {
            _image = imageData;
          });

          print('Image fetched successfully.');
        } else {
          print('Failed to download image.');
        }
      } else {
        print('Document does not exist.');
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
