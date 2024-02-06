import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/userProfile.dart';

import '../Components/profileTextBox.dart';

class FuelStationProfile extends StatefulWidget {
  final String stationId;
  final String stationName;
  final String stationLocation;
  final String stationContact;
  final String dieselTankCapacity;
  final String petrolTankCapacity;
  final String currentDieselAmount;
  final String currentPetrolAmount;
  const FuelStationProfile(
      {super.key,
      required this.stationId,
      required this.stationName,
      required this.stationLocation,
      required this.stationContact,
      required this.currentDieselAmount,
      required this.currentPetrolAmount,
      required this.dieselTankCapacity,
      required this.petrolTankCapacity});

  @override
  State<FuelStationProfile> createState() => _FuelStationProfileState();
}

class _FuelStationProfileState extends State<FuelStationProfile> {
  final stationCollection =
      FirebaseFirestore.instance.collection('fuelStations');

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
      await stationCollection.doc(widget.stationId).update({field: newvalue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stationName),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileTextBox(
                title: 'Station Name',
                titleValue: widget.stationName,
                function: () => editField('stationName'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Station Location',
                titleValue: widget.stationLocation,
                function: () => editField('stationLocation'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Station Attendant',
                titleValue: widget.stationContact,
                function: () => editField('stationAttendant'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Diesel Tank Capacity (litres)',
                titleValue: widget.dieselTankCapacity,
                function: () => editField('dieselTankCapacity'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Petrol Tank Capacity (litres)',
                titleValue: widget.petrolTankCapacity,
                function: () => editField('petrolTankCapacity'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Current Diesel Amount (litres)',
                titleValue: widget.currentDieselAmount,
                function: () => editField('currentDieselAmount'),
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox(
                title: 'Current Petrol Amount (litres)',
                titleValue: widget.currentPetrolAmount,
                function: () => editField('currentPetrolAmount'),
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
