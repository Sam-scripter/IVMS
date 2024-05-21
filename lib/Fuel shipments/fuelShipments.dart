import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/fuelShipmentProfile.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/newFuelShipment.dart';

class FuelShipments extends StatefulWidget {
  const FuelShipments({super.key});

  @override
  State<FuelShipments> createState() => _FuelShipmentsState();
}

class _FuelShipmentsState extends State<FuelShipments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Fuel Shipments')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfShipments = snapshot.data!.docs.length;
              return Text(
                'Fuel Shipments($numberOfShipments)',
                style: GoogleFonts.lato(),
              );
            } else {
              return Text(
                'Fuel Shipments',
                style: GoogleFonts.lato(),
              );
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => FuelShipment())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Fuel Shipments')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> shipmentsWidget = [];
            for (var shipment in snapshot.data!.docs) {
              var value = shipment.data() as Map<String, dynamic>;
              String documentShipmentId = shipment.id;
              String shipmentId = value['shipmentId'];
              String supplier = value['supplier'];
              String petrolQuantity = value['petrolQuantity'];
              String dieselQuantity = value['dieselQuantity'];
              String totalFuelLitres = value['totalFuelLitres'].toString();
              String totalMoney = value['totalMoney'].toString();
              String invoiceNumber = value['invoiceNumber'];

              shipmentsWidget.add(GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FuelShipmentProfile(
                            supplier: supplier,
                            shipmentId: documentShipmentId,
                            petrolQuantity: petrolQuantity,
                            dieselQuantity: dieselQuantity,
                            totalFuel: totalFuelLitres,
                            totalMoney: totalMoney,
                            invoiceNumber: invoiceNumber))),
                child: ListTile(
                  leading: Text(
                    shipmentId,
                    style: GoogleFonts.lato(fontSize: 20),
                  ),
                ),
              ));
            }
            return Column(
              children: shipmentsWidget,
            );
          } else {
            return const Center(
              child: Text('No fuel shipments Found'),
            );
          }
        },
      ),
    );
  }
}
