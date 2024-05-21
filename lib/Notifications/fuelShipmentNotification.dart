import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Components/profileTextBox.dart';

class FuelShipmentNotification extends StatefulWidget {
  final String orderId;

  const FuelShipmentNotification({super.key, required this.orderId});

  @override
  State<FuelShipmentNotification> createState() =>
      _FuelShipmentNotificationState();
}

class _FuelShipmentNotificationState extends State<FuelShipmentNotification> {
  String shipmentId = '';
  String supplier = '';
  String petrolQuantity = '';
  String dieselQuantity = '';
  String totalFuelLitres = '';
  String totalMoney = '';
  String invoiceNumber = '';

  Future<void> shipmentDetails() async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Fuel Shipments')
        .doc(widget.orderId);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      setState(() {
        shipmentId = documentSnapshot['shipmentId'];
        supplier = documentSnapshot['supplier'];
        petrolQuantity = documentSnapshot['petrolQuantity'];
        dieselQuantity = documentSnapshot['dieselQuantity'];
        totalFuelLitres = documentSnapshot['totalFuelLitres'].toString();
        totalMoney = documentSnapshot['totalMoney'];
        invoiceNumber = documentSnapshot['invoiceNumber'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    shipmentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Shipment details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            children: [
              ProfileTextBox1(title: 'Shipment ID', titleValue: shipmentId),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(title: 'Supplier', titleValue: supplier),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(
                  title: 'PetrolQuantity', titleValue: petrolQuantity),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(
                  title: 'Diesel Quantity', titleValue: dieselQuantity),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(
                  title: 'Total Fuel in Litres', titleValue: totalFuelLitres),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(
                  title: 'Total Money Spent', titleValue: totalMoney),
              SizedBox(
                height: 20,
              ),
              ProfileTextBox1(
                  title: 'Invoice Number', titleValue: invoiceNumber),
            ],
          ),
        ),
      ),
    );
  }
}
