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
        child: Column(
          children: [
            ProfileTextBox1(
                title: 'Supplier Information', titleValue: widget.supplier),
            ProfileTextBox1(
                title: 'Petrol Quantity', titleValue: widget.petrolQuantity),
            ProfileTextBox1(
                title: 'Diesel Quantity', titleValue: widget.dieselQuantity),
            ProfileTextBox1(title: 'Total Fuel', titleValue: widget.totalFuel),
            ProfileTextBox1(
                title: 'Total money Spent', titleValue: widget.totalMoney),
            ProfileTextBox1(
                title: 'Invoice Number', titleValue: widget.invoiceNumber),
          ],
        ),
      ),
    );
  }
}
