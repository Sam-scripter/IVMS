import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fuelStationProfile.dart';
import 'registerFuelStation.dart';

class FuelStations extends StatefulWidget {
  const FuelStations({super.key});

  @override
  State<FuelStations> createState() => _FuelStationsState();
}

class _FuelStationsState extends State<FuelStations> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('fuelStations').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfStations = snapshot.data!.docs.length;
              return Text(
                'Fuel Stations ($numberOfStations)',
                style: GoogleFonts.lato(),
              );
            } else {
              return const Text('Fuel Stations');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterFuelStation(),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fuelStations')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> stationWidgets = [];
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

              stationWidgets.add(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FuelStationProfile(
                          stationId: stationId,
                          stationName: stationName,
                          stationLocation: stationLocation,
                          stationContact: stationContact,
                          currentDieselAmount: currentDieselAmount,
                          currentPetrolAmount: currentPetrolAmount,
                          dieselTankCapacity: dieselTankCapacity,
                          petrolTankCapacity: petrolTankCapacity,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      stationName,
                      style: GoogleFonts.lato(fontSize: 20),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: stationWidgets,
            );
          } else {
            return const Center(
              child: Text('No fuel Stations found'),
            );
          }
        },
      ),
    );
  }
}
