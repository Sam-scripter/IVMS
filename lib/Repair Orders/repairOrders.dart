import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Repair%20Orders/newRepairOrder.dart';
import 'package:integrated_vehicle_management_system/Repair%20Orders/repairOrderProfile.dart';

class RepairOrders extends StatefulWidget {
  const RepairOrders({super.key});

  @override
  State<RepairOrders> createState() => _RepairOrdersState();
}

class _RepairOrdersState extends State<RepairOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('repairOrders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfRepairOrders = snapshot.data!.docs.length;
              return Text('Repair Orders ($numberOfRepairOrders)');
            } else {
              return const Text('Repair Orders');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => NewRepairOorder())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('repairOrders')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> repairWidgets = [];
            for (var value in snapshot.data!.docs) {
              var order = value.data() as Map<String, dynamic>;
              String repairId = value.id ?? '';
              String orderType = order['order Type'];
              String vehiclePlate = order['vehicle'] ?? '';
              String vehicleId = order['vehicleId'] ?? '';
              String driver = order['driver'] ?? '';
              String description = order['description'] ?? '';
              String status = order['Status'] ?? '';

              repairWidgets.add(GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RepairOrderProfile(
                              orderId: repairId,
                              vehiclePlate: vehiclePlate,
                              vehicleId: vehicleId,
                              driver: driver,
                              description: description,
                              status: status,
                              orderType: orderType,
                            ))),
                child: ListTile(
                  title: Text(
                    repairId,
                    style: GoogleFonts.lato(fontSize: 20),
                  ),
                ),
              ));
            }
            return Column(
              children: repairWidgets,
            );
          } else {
            return const Center(
              child: Text('No repair orders found'),
            );
          }
        },
      ),
    );
  }
}
