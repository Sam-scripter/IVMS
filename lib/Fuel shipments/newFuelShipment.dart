import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/allocateFuel.dart';

class FuelShipment extends StatelessWidget {
  const FuelShipment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Fuel Shipment',
          style: GoogleFonts.lato(),
        ),
      ),
      body: NewFuelShipment(),
    );
  }
}

class NewFuelShipment extends StatefulWidget {
  const NewFuelShipment({super.key});

  @override
  State<NewFuelShipment> createState() => _NewFuelShipmentState();
}

class _NewFuelShipmentState extends State<NewFuelShipment> {
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _supplierInformationController =
      TextEditingController();
  TextEditingController _shipmentInformationController =
      TextEditingController();
  TextEditingController _petrolQuantityController = TextEditingController();
  TextEditingController _dieselQuantityController = TextEditingController();
  TextEditingController _totalAmountController = TextEditingController();
  TextEditingController _invoiceNumberController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  String name = '';
  String employeeName = '';

  Future<void> _storeNotification(
    String notificationType,
    String employeeName,
    String thisId,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'notificationType': notificationType,
        'employeeName': employeeName,
        'orderId': thisId,
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
        employeeName = '${snapshot['firstName']} ${snapshot['secondName']}';
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getEmployee();
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
    return Stack(children: [
      Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              inputRegister(
                  text: Text('Supplier Information'),
                  textController: _supplierInformationController,
                  inputType: TextInputType.text,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter the supplier information';
                    }
                  }),
              inputRegister(
                  text: Text('Shipment ID/Number'),
                  textController: _shipmentInformationController,
                  inputType: TextInputType.text,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Fill in this field';
                    }
                  }),
              inputRegister(
                  text: Text('Quantity of Petrol'),
                  textController: _petrolQuantityController,
                  inputType: TextInputType.number,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify the quantity of petrol';
                    }
                  }),
              inputRegister(
                  text: Text('Quantity of Diesel'),
                  textController: _dieselQuantityController,
                  inputType: TextInputType.number,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity of Diesel';
                    }
                  }),
              inputRegister(
                  text: Text('Total amount'),
                  textController: _totalAmountController,
                  inputType: TextInputType.number,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total amount';
                    }
                  }),
              inputRegister(
                  text: Text('Invoice number'),
                  textController: _invoiceNumberController,
                  inputType: TextInputType.text,
                  valueValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the invoice number';
                    }
                  }),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Colors.lightBlue,
                  child: MaterialButton(
                    minWidth: 320,
                    height: 42,
                    elevation: 5.0,
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          double petrolAmount =
                              double.parse(_petrolQuantityController.text);
                          double dieselAmount =
                              double.parse(_dieselQuantityController.text);
                          double totalFuel = petrolAmount + dieselAmount;
                          String customId =
                              'fuelShipment_' + _generateRandomString(8);

                          DocumentReference documentRef = FirebaseFirestore
                              .instance
                              .collection('employees')
                              .doc(user?.email);
                          DocumentSnapshot snapshot = await documentRef.get();
                          if (snapshot.exists) {
                            setState(() {
                              name =
                                  '${snapshot['firstName']} ${snapshot['secondName']}';
                            });
                          }
                          DocumentReference addedDocumentRef = FirebaseFirestore
                              .instance
                              .collection('Fuel Shipments')
                              .doc(customId);

                          await addedDocumentRef.set({
                            'supplier': _supplierInformationController.text,
                            'shipmentId': _shipmentInformationController.text,
                            'petrolQuantity': _petrolQuantityController.text,
                            'dieselQuantity': _dieselQuantityController.text,
                            'totalFuelLitres': totalFuel,
                            'unallocatedDiesel':
                                double.parse(_dieselQuantityController.text),
                            'unallocatedPetrol':
                                double.parse(_petrolQuantityController.text),
                            'totalMoney': _totalAmountController.text,
                            'invoiceNumber': _invoiceNumberController.text,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          // Extract the document ID
                          // String shipmentDocumentId = addedDocumentRef.id;

                          _storeNotification(
                              'Fuel Shipment', employeeName, customId);

                          // Navigate to the AllocateFuel screen with the document ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllocateFuel(documentId: customId),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      'Add Fuel Shipment',
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_isLoading)
        Container(
          color: Colors.black.withOpacity(0.7),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }
}
