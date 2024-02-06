import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/userProfile.dart';

import '../Components/profileTextBox.dart';

class RepairOrderProfile extends StatefulWidget {
  final String orderId;
  final String vehiclePlate;
  final String vehicleInfo;
  final String driver;
  final String description;
  final String spareParts;
  final String status;

  const RepairOrderProfile(
      {super.key,
      required this.orderId,
      required this.vehiclePlate,
      required this.vehicleInfo,
      required this.driver,
      required this.description,
      required this.spareParts,
      required this.status});

  @override
  State<RepairOrderProfile> createState() => _RepairOrderProfileState();
}

class _RepairOrderProfileState extends State<RepairOrderProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId),
      ),
      body: Column(
        children: [
          ProfileTextBox(title: 'Order Id', titleValue: widget.orderId),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(
              title: 'Vehicle Plate Number', titleValue: widget.vehiclePlate),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(
              title: 'Vehicle Information', titleValue: widget.vehicleInfo),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(title: 'Driver', titleValue: widget.driver),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(title: 'Description', titleValue: widget.description),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(title: 'Spare parts', titleValue: widget.spareParts),
          const SizedBox(
            height: 15,
          ),
          ProfileTextBox(title: 'Status', titleValue: widget.status),
        ],
      ),
    );
  }
}
