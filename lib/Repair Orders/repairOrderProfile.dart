import 'package:flutter/material.dart';

import '../Components/profileTextBox.dart';

class RepairOrderProfile extends StatefulWidget {
  final String orderType;
  final String orderId;
  final String vehiclePlate;
  final String vehicleId;
  final String driver;
  final String description;
  final String status;

  const RepairOrderProfile(
      {super.key,
      required this.orderId,
      required this.vehiclePlate,
      required this.vehicleId,
      required this.driver,
      required this.description,
      required this.status,
      required this.orderType});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            children: [
              ProfileTextBox1(
                  title: 'Order Type', titleValue: widget.orderType),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(title: 'Order Id', titleValue: widget.orderId),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(
                  title: 'Vehicle Plate Number',
                  titleValue: widget.vehiclePlate),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(
                  title: 'Vehicle Id', titleValue: widget.vehicleId),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(title: 'Driver', titleValue: widget.driver),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(
                  title: 'Description', titleValue: widget.description),
              const SizedBox(
                height: 15,
              ),
              ProfileTextBox1(title: 'Status', titleValue: widget.status),
            ],
          ),
        ),
      ),
    );
  }
}
