import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              String repairId = value.id;
              String vehiclePlate = order['licensePlateNumber'];
              String vehicleInfo = order['makeAndModel'];
              String driver = order['driver'];
              String description = order['description'];
              String spareParts = order['spareparts'];
              String status = order['status'];

              repairWidgets.add(ListTile(
                title: Text(
                  repairId,
                  style: GoogleFonts.lato(),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RepairOrderProfile(
                              orderId: repairId,
                              vehiclePlate: vehiclePlate,
                              vehicleInfo: vehicleInfo,
                              driver: driver,
                              description: description,
                              spareParts: spareParts,
                              status: status))),
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
