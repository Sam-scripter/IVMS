import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/userProfile.dart';

import '../Components/profileTextBox.dart';

class FuelOrderProfile extends StatefulWidget {
  final String orderId;
  final String fuelType;
  final String origin;
  final String destination;
  final String driver;
  final String vehicleInfo;
  final String purpose;
  final String litresRequired;
  final String orderStatus;

  const FuelOrderProfile({
    super.key,
    required this.orderId,
    required this.fuelType,
    required this.origin,
    required this.destination,
    required this.driver,
    required this.vehicleInfo,
    required this.purpose,
    required this.orderStatus,
    required this.litresRequired,
  });

  @override
  State<FuelOrderProfile> createState() => _FuelOrderProfileState();
}

class _FuelOrderProfileState extends State<FuelOrderProfile> {
  final fuelOrdersCollection =
      FirebaseFirestore.instance.collection('Fuel Orders');

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
      await fuelOrdersCollection.doc(widget.orderId).update({field: newvalue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileTextBox1(title: 'Driver', titleValue: widget.driver),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(title: 'Vehicle', titleValue: widget.vehicleInfo),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(title: 'Fuel Type', titleValue: widget.fuelType),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(
                  title: 'Starting Location', titleValue: widget.origin),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(
                  title: 'Destination', titleValue: widget.destination),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(title: 'Purpose', titleValue: widget.purpose),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(
                  title: 'Litres Required', titleValue: widget.litresRequired),
              const SizedBox(
                height: 15.0,
              ),
              ProfileTextBox1(
                  title: 'Order Status', titleValue: widget.orderStatus),
            ],
          ),
        ),
      ),
    );
  }
}
