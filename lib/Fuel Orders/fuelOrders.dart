import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Fuel%20Orders/newFuelOrder.dart';
import 'fuelOrder_Profile.dart';

class FuelOrders extends StatefulWidget {
  const FuelOrders({super.key});

  @override
  State<FuelOrders> createState() => _FuelOrdersState();
}

class _FuelOrdersState extends State<FuelOrders> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Fuel Orders')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfOrders = snapshot.data!.docs.length;
              return Text('Fuel Orders ($numberOfOrders)');
            } else {
              return const Text('Fuel Orders');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewFuelOrder())),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Fuel Orders')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> fuelOrderWidgets = [];
            for (var order in snapshot.data!.docs) {
              var value = order.data() as Map<String, dynamic>;
              String orderId = order.id;
              String driver = value['Driver'];
              String vehicleInfo = value['Vehicle'];
              String fuelType = value['Fuel Type'];
              String origin = value['Origin'];
              String destination = value['Destination'];
              String purpose = value['Purpose'];
              double litresRequired = value['Litres Required'] ?? 0;
              String orderStatus = value['Status'];
              String litresAllocated = litresRequired.toString();

              fuelOrderWidgets.add(GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FuelOrderProfile(
                        orderId: orderId,
                        fuelType: fuelType,
                        origin: origin,
                        destination: destination,
                        driver: driver,
                        vehicleInfo: vehicleInfo,
                        purpose: purpose,
                        litresRequired: litresAllocated,
                        orderStatus: orderStatus),
                  ),
                ),
                child: ListTile(
                  leading: Text(
                    orderId,
                    style: GoogleFonts.lato(fontSize: 20),
                  ),

                ),
              ));
            }
            return Column(
              children: fuelOrderWidgets,
            );
          } else {
            return const Center(
              child: Text('No orders Found'),
            );
          }
        },
      ),
    );
  }
}
