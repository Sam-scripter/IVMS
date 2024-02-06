import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/stationAllocationProfile.dart';

class AllocateFuel extends StatefulWidget {
  final String documentId;

  const AllocateFuel({super.key, required this.documentId});

  @override
  State<AllocateFuel> createState() => _AllocateFuelState();
}

class _AllocateFuelState extends State<AllocateFuel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Allocate Fuel',
          style: GoogleFonts.lato(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              'Choose a fuel station to allocate fuel',
              style: GoogleFonts.lato(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('fuelStations')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> stations = [];
                    for (var station in snapshot.data!.docs) {
                      var value = station.data() as Map<String, dynamic>;
                      String stationName = value['stationName'];
                      String stationId = station.id;
                      String stationLocation = value['stationLocation'];
                      String stationContact = value['stationAttendant'];
                      String dieselTankCapacity = value['dieselTankCapacity'];
                      String petrolTankCapacity = value['petrolTankCapacity'];
                      String currentDieselAmount = value['currentDieselAmount'];
                      String currentPetrolAmount = value['currentPetrolAmount'];

                      stations.add(GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StationAllocationProfile(
                                    stationId: stationId,
                                    stationName: stationName,
                                    stationLocation: stationLocation,
                                    stationContact: stationContact,
                                    dieselTankCapacity: dieselTankCapacity,
                                    petrolTankCapacity: petrolTankCapacity,
                                    currentDieselAmount: currentDieselAmount,
                                    currentPetrolAmount: currentPetrolAmount,
                                    shipmentDocumentId: widget.documentId))),
                        child: ListTile(
                          leading: Text(
                            stationName,
                            style: GoogleFonts.lato(fontSize: 20),
                          ),
                        ),
                      ));
                    }
                    return Column(
                      children: stations,
                    );
                  } else {
                    return const Center(
                      child: Text('No Stations found'),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
