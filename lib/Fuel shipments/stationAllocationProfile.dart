import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/Components/profileTextBox.dart';

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

  const StationAllocationProfile(
      {super.key,
      required this.stationId,
      required this.stationName,
      required this.stationLocation,
      required this.stationContact,
      required this.dieselTankCapacity,
      required this.petrolTankCapacity,
      required this.currentDieselAmount,
      required this.currentPetrolAmount,
      required this.shipmentDocumentId});

  @override
  State<StationAllocationProfile> createState() =>
      _StationAllocationProfileState();
}

class _StationAllocationProfileState extends State<StationAllocationProfile> {
  late double petrolAmount;
  late double dieselAmount;
  TextEditingController _petrolAmountController = TextEditingController();
  TextEditingController _dieselAmountController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String employeeName = '';

  Future<void> _storeNotification(String notificationType, String employeeName,
      String petrolLitres, String dieselLitres) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'notificationType': notificationType,
        'employeeName': employeeName,
        'petrolAmount': petrolLitres,
        'dieselAmount': dieselLitres,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _getEmployee() async {
    if (user != null) {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('employees').doc(user?.email);
      DocumentSnapshot snapshot = await documentRef.get();
      if (snapshot.exists) {
        employeeName = '${snapshot['firstName']} ${snapshot['secondName']}';
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
      petrolAmount = double.parse(snapshot['petrolQuantity']);
      dieselAmount = double.parse(snapshot['dieselQuantity']);
    }
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
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Station Location',
                titleValue: widget.stationLocation,
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Station Attendant',
                titleValue: widget.stationContact,
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Diesel Tank Capacity (litres)',
                titleValue: widget.dieselTankCapacity,
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Petrol Tank Capacity (litres)',
                titleValue: widget.petrolTankCapacity,
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Current Diesel Amount (litres)',
                titleValue: widget.currentDieselAmount,
              ),
              const SizedBox(
                height: 18,
              ),
              ProfileTextBox1(
                title: 'Current Petrol Amount (litres)',
                titleValue: widget.currentPetrolAmount,
              ),
              const SizedBox(
                height: 18,
              ),
              inputRegister(
                  text: Text('Allocate Petrol Litres'),
                  textController: _petrolAmountController,
                  inputType: TextInputType.number,
                  valueValidator: (value) {
                    if (value == null) {
                      return 'Please specify the amount of petrol in litres';
                    }
                  }),
              inputRegister(
                  text: const Text('Allocate Diesel Litres'),
                  textController: _dieselAmountController,
                  inputType: TextInputType.number,
                  valueValidator: (value) {
                    if (value == null) {
                      return 'Please specify the amount of petrol in litres';
                    }
                  }),
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
                    if (enteredPetrol > petrolAmount) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'The entered petrol allocation exceeds the specified fuel shipment amount'),
                              content: const Text(
                                  'Try entering an amount equal to or less than the amount specified in the fuel Shipment'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK')),
                              ],
                            );
                          });
                    } else if (enteredDiesel > dieselAmount) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'The entered diesel allocation exceeds the specified fuel shipment amount'),
                              content: const Text(
                                  'Try entering an amount equal to or less than the amount specified in the fuel Shipment'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK')),
                              ],
                            );
                          });
                    } else {
                      await FirebaseFirestore.instance
                          .collection('fuelStations')
                          .doc(widget.shipmentDocumentId)
                          .update({
                        'currentPetrolAmount': _petrolAmountController.text,
                        'currentDieselAmount': _dieselAmountController.text,
                      });

                      _storeNotification(
                          'Fuel Allocation',
                          employeeName,
                          _petrolAmountController.text,
                          _dieselAmountController.text);
                    }
                  },
                  child: Text(
                    'Allocate Fuel',
                    style: GoogleFonts.lato(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
