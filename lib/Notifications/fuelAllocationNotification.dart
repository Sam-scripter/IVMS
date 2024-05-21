import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Components/profileTextBox.dart';

class FuelAllocationNotification extends StatefulWidget {
  final String notificationId;

  const FuelAllocationNotification({Key? key, required this.notificationId})
      : super(key: key);

  @override
  State<FuelAllocationNotification> createState() =>
      _FuelAllocationNotificationState();
}

class _FuelAllocationNotificationState
    extends State<FuelAllocationNotification> {
  String employeeName = '';
  String petrolLitres = '';
  String dieselLitres = '';
  String station = '';
  String shipmentDocumentId = '';
  double initialShipmentAmount = 0;
  double remainingPetrol = 0;
  double remainingDiesel = 0;
  bool isLoading = true;

  Future<void> _getAllocationDetails() async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.notificationId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        setState(() {
          employeeName = documentSnapshot['employeeName'];
          petrolLitres = documentSnapshot['petrolAmount'];
          dieselLitres = documentSnapshot['dieselAmount'];
          station = documentSnapshot['station'];
          shipmentDocumentId = documentSnapshot['shipmentId'];
          initialShipmentAmount =
              documentSnapshot['initial Fuel Shipment Amount'];
          remainingPetrol = documentSnapshot['remaining Petrol'];
          remainingDiesel = documentSnapshot['remaining Diesel'];
          isLoading = false;
        });
      } else {
        print('documentSnapshot does not exist, check this');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllocationDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Allocation Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                child: Column(
                  children: [
                    ProfileTextBox1(
                        title: 'Shipment ID', titleValue: shipmentDocumentId),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Initial Fuel Shipment Amount',
                        titleValue: initialShipmentAmount.toString()),
                    SizedBox(height: 20),
                    ProfileTextBox1(title: 'Station', titleValue: station),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Diesel Quantity Allocated',
                        titleValue: dieselLitres),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Petrol Quantity Allocated',
                        titleValue: petrolLitres),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Remaining Diesel After Allocation',
                        titleValue: remainingDiesel.toString()),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Remaining Petrol After Allocation',
                        titleValue: remainingPetrol.toString()),
                    SizedBox(height: 20),
                    ProfileTextBox1(
                        title: 'Employee Who Allocated',
                        titleValue: employeeName),
                  ],
                ),
              ),
            ),
    );
  }
}
