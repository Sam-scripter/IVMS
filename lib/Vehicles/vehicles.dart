import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vehicleProfile.dart';

class Vehicles extends StatelessWidget {
  Vehicles({super.key});

  final _firestore = FirebaseFirestore.instance;

  Future<void> deleteVehicle(String vehicleId) async {
    _firestore.collection('vehicles').doc(vehicleId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _firestore.collection('vehicles').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfVehicles = snapshot.data!.docs.length;
              return Text('Vehicles ($numberOfVehicles)');
            } else {
              return const Text('Vehicles');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/addVehicle');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: _firestore
                  .collection('vehicles')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> vehicles = [];
                  for (var value in snapshot.data!.docs) {
                    String vehiclePlate = value['licensePlateNumber'] ?? '';
                    String vehicleId = value.id ?? '';
                    String chassisNumber = value['chassisNumber'] ?? '';
                    String insuranceProvider = value['insuranceProvider'] ?? '';
                    String makeAndModel = value['makeAndModel'] ?? '';
                    String department = value['department'] ?? '';
                    String fuelType = value['fuelType'] ?? '';

                    vehicles.add(ListTile(
                      title: Text(
                        vehiclePlate,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VehicleProfile(
                                      chassisNumber: chassisNumber,
                                      department: department,
                                      insuranceProvider: insuranceProvider,
                                      licensePlateNumber: vehiclePlate,
                                      makeAndModel: makeAndModel,
                                      vehicleId: vehicleId,
                                      fuelType: fuelType,
                                    )));
                      },
                    ));
                  }
                  return Column(
                    children: vehicles,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
