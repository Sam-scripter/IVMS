import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/functions.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/Components/profileTextBox.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/allocateFuel.dart';
import 'fuelShipments.dart';

class StationAllocationProfile extends StatefulWidget {
  final String shipmentDocumentId;
  final String stationId;
  final String stationName;
  final String stationLocation;
  final String stationContact;
  final String dieselTankCapacity;
  final String petrolTankCapacity;
  final String currentDieselAmount;
  final String currentPetrolAmount;

  const StationAllocationProfile({
    Key? key,
    required this.stationId,
    required this.stationName,
    required this.stationLocation,
    required this.stationContact,
    required this.dieselTankCapacity,
    required this.petrolTankCapacity,
    required this.currentDieselAmount,
    required this.currentPetrolAmount,
    required this.shipmentDocumentId,
  }) : super(key: key);

  @override
  _StationAllocationProfileState createState() =>
      _StationAllocationProfileState();
}

class _StationAllocationProfileState extends State<StationAllocationProfile> {
  late double petrolAmount;
  double remainingPetrolAmount = 0;
  double dieselAmount = 0;
  double remainingDieselAmount = 0;
  late double totalAmount;
  TextEditingController _petrolAmountController = TextEditingController();
  TextEditingController _dieselAmountController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String employeeName = '';

  Future<void> _storeNotification(
    String notificationType,
    String employeeName,
    String petrolLitres,
    String dieselLitres,
    String thisId,
    double shipmentAmount,
    String stationId,
    double remainingPetrol,
    double remainingDiesel,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'orderId': thisId,
        'notificationType': notificationType,
        'employeeName': employeeName,
        'station': stationId,
        'petrolAmount': petrolLitres,
        'dieselAmount': dieselLitres,
        'shipmentId': widget.shipmentDocumentId,
        'initial Fuel Shipment Amount': shipmentAmount,
        'remaining Diesel': remainingDiesel,
        'remaining Petrol': remainingPetrol,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Query employees with the specified roles and positions
      QuerySnapshot employeesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('role', whereIn: ['SuperUser', 'Admin']).get();

      // Create a list of Map objects representing the initial read status for selected employees
      List<Map<String, dynamic>> initialReadStatus =
          employeesSnapshot.docs.where((employeeDoc) {
        // For SuperUsers, add all employees to the subcollection
        if (employeeDoc['role'] == 'SuperUser') {
          return true;
        }
        // For Admins, only add Transport Managers
        else if (employeeDoc['position'] == 'Transport Manager') {
          return true;
        }
        return false;
      }).map((employeeDoc) {
        return {
          'userId': employeeDoc.id,
          'read': false,
        };
      }).toList();

      // Add the users subcollection to the notification document and initialize read status for selected employees
      WriteBatch batch = FirebaseFirestore.instance.batch();
      initialReadStatus.forEach((readStatus) {
        batch.set(
          notificationRef.collection('users').doc(readStatus['userId']),
          readStatus,
        );
      });

      // Commit the batch write operation
      await batch.commit();
    }
  }

  Future<void> _getEmployee() async {
    if (user != null) {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('employees').doc(user?.email);
      DocumentSnapshot snapshot = await documentRef.get();
      if (snapshot.exists) {
        setState(() {
          employeeName = '${snapshot['firstName']} ${snapshot['secondName']}';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getTotalFuelLitres();
    _getEmployee();
  }

  Future<void> getTotalFuelLitres() async {
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('Fuel Shipments')
        .doc(widget.shipmentDocumentId);
    DocumentSnapshot snapshot = await documentRef.get();
    if (snapshot.exists) {
      setState(() {
        petrolAmount = double.parse(snapshot['petrolQuantity']);
        dieselAmount = double.parse(snapshot['dieselQuantity']);
        totalAmount = petrolAmount + dieselAmount;
        remainingDieselAmount = snapshot['unallocatedDiesel'] ?? 0;
        remainingPetrolAmount = snapshot['unallocatedPetrol'] ?? 0;
      });
    }
  }

  Future<void> updateShipmentDetails(
      double unallocatedDiesel, double unallocatedPetrol) async {
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('Fuel Shipments')
        .doc(widget.shipmentDocumentId);
    await documentRef.update({
      'unallocatedDiesel': unallocatedDiesel,
      'unallocatedPetrol': unallocatedPetrol
    });
  }

  String _generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      List.generate(length,
          (index) => characters.codeUnitAt(random.nextInt(characters.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stationName),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileTextBox1(
                title: 'Station Name',
                titleValue: widget.stationName,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Station Location',
                titleValue: widget.stationLocation,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Station Attendant',
                titleValue: widget.stationContact,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Diesel Tank Capacity (litres)',
                titleValue: widget.dieselTankCapacity,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Petrol Tank Capacity (litres)',
                titleValue: widget.petrolTankCapacity,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Current Diesel Amount (litres)',
                titleValue: widget.currentDieselAmount,
              ),
              const SizedBox(height: 18),
              ProfileTextBox1(
                title: 'Current Petrol Amount (litres)',
                titleValue: widget.currentPetrolAmount,
              ),
              const SizedBox(height: 18),
              inputRegister(
                text: const Text('Allocate Petrol Litres'),
                textController: _petrolAmountController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the amount of petrol in litres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              inputRegister(
                text: const Text('Allocate Diesel Litres'),
                textController: _dieselAmountController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the amount of diesel in litres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Material(
                borderRadius: BorderRadius.circular(30),
                child: MaterialButton(
                  minWidth: 320,
                  height: 42,
                  elevation: 5.0,
                  onPressed: () async {
                    double enteredPetrol =
                        double.parse(_petrolAmountController.text);
                    double enteredDiesel =
                        double.parse(_dieselAmountController.text);
                    double stationCurrentDieselAmount =
                        double.parse(widget.currentDieselAmount);
                    double stationCurrentPetrolAmount =
                        double.parse(widget.currentPetrolAmount);
                    double dieselTank = double.parse(widget.dieselTankCapacity);
                    double petrolTank = double.parse(widget.petrolTankCapacity);

                    if (enteredPetrol > remainingPetrolAmount) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error!'),
                            content: const Text(
                                'The entered petrol allocation exceeds the remaining fuel shipment amount. Try entering an amount equal to or less than the available amount.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK')),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (enteredDiesel > remainingDieselAmount) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error!'),
                            content: const Text(
                                'The entered diesel allocation exceeds the remaining fuel shipment amount. Try entering an amount equal to or less than the available amount.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK')),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    double newDieselAmount =
                        enteredDiesel + stationCurrentDieselAmount;
                    double newPetrolAmount =
                        enteredPetrol + stationCurrentPetrolAmount;

                    if (newDieselAmount > dieselTank) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error!'),
                            content: const Text(
                                'The entered diesel amount added with the existing diesel amount exceeds the tank capacity. Try entering a smaller amount.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK')),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (newPetrolAmount > petrolTank) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error!'),
                            content: const Text(
                                'The entered petrol amount added with the existing petrol amount exceeds the tank capacity. Try entering a smaller amount.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK')),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    double remainingDiesel =
                        remainingDieselAmount - enteredDiesel;
                    double remainingPetrol =
                        remainingPetrolAmount - enteredPetrol;

                    await FirebaseFirestore.instance
                        .collection('fuelStations')
                        .doc(widget.stationId)
                        .update({
                      'currentPetrolAmount': newPetrolAmount.toString(),
                      'currentDieselAmount': newDieselAmount.toString(),
                    });

                    String customId =
                        'fuelAllocation_' + _generateRandomString(8);

                    await _storeNotification(
                      'Fuel Allocation',
                      employeeName,
                      _petrolAmountController.text,
                      _dieselAmountController.text,
                      customId,
                      totalAmount,
                      widget.stationId,
                      remainingPetrol,
                      remainingDiesel,
                    );

                    await updateSuperUserUnreadCount();
                    await updateTransportUnreadCount();
                    await updateFuelUserUnreadCount();

                    await FirebaseFirestore.instance
                        .collection('Fuel Shipments')
                        .doc(widget.shipmentDocumentId)
                        .collection('stations')
                        .add({
                      'station': widget.stationName,
                      'addedPetrol': enteredPetrol,
                      'addedDiesel': enteredDiesel,
                    });

                    await updateShipmentDetails(
                        remainingDiesel, remainingPetrol);
                    await getTotalFuelLitres();

                    if (remainingDiesel == 0 && remainingPetrol == 0) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FuelShipments()),
                        (route) => route.isFirst,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Allocate Fuel',
                    style: GoogleFonts.lato(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
