import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/profileTextBox.dart';

class FuelShipmentProfile extends StatefulWidget {
  final String supplier;
  final String shipmentId;
  final String petrolQuantity;
  final String dieselQuantity;
  final String totalFuel;
  final String totalMoney;
  final String invoiceNumber;

  const FuelShipmentProfile(
      {super.key,
      required this.supplier,
      required this.shipmentId,
      required this.petrolQuantity,
      required this.dieselQuantity,
      required this.totalFuel,
      required this.totalMoney,
      required this.invoiceNumber});

  @override
  State<FuelShipmentProfile> createState() => _FuelShipmentProfileState();
}

class _FuelShipmentProfileState extends State<FuelShipmentProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shipmentId,
          style: GoogleFonts.lato(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            children: [
              ProfileTextBox1(
                  title: 'Supplier Information', titleValue: widget.supplier),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                  title: 'Petrol Quantity', titleValue: widget.petrolQuantity),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                  title: 'Diesel Quantity', titleValue: widget.dieselQuantity),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                  title: 'Total Fuel', titleValue: widget.totalFuel),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                  title: 'Total money Spent', titleValue: widget.totalMoney),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                  title: 'Invoice Number', titleValue: widget.invoiceNumber),
              const SizedBox(
                height: 28,
              ),
              Text(
                'Stations Allocated Fuel:',
                style: GoogleFonts.lato(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Fuel Shipments')
                      .doc(widget.shipmentId)
                      .collection('stations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> stationWidgets = [];
                      for (var station in snapshot.data!.docs) {
                        var value = station.data() as Map<String, dynamic>;
                        String stationName = value['station'];
                        double addedPetrol = value['addedPetrol'];
                        double addedDiesel = value['addedDiesel'];
                        double totalAddedFuel = addedDiesel + addedPetrol;

                        stationWidgets.add(ListTile(
                          isThreeLine: true,
                          leading: Text(
                            stationName,
                            style: GoogleFonts.lato(fontSize: 20),
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Added Petrol: ',
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                  Text(
                                    addedPetrol.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Added Diesel: ',
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                  Text(
                                    addedDiesel.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Total Fuel: ',
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                  Text(
                                    totalAddedFuel.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                      }
                      return Column(
                        children: stationWidgets,
                      );
                    } else {
                      return const Center(child: Text('No Stations'));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
