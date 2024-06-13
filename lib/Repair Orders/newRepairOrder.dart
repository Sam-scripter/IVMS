import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/alertDialog.dart';
import 'package:integrated_vehicle_management_system/Components/functions.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/Repair%20Orders/repairOrders.dart';

class NewRepairOorder extends StatefulWidget {
  const NewRepairOorder({super.key});

  @override
  State<NewRepairOorder> createState() => _NewRepairOorderState();
}

class _NewRepairOorderState extends State<NewRepairOorder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New repair order',
          style: GoogleFonts.lato(),
        ),
      ),
      body: NewRepairOrderForm(),
    );
  }
}

class NewRepairOrderForm extends StatefulWidget {
  const NewRepairOrderForm({super.key});

  @override
  State<NewRepairOrderForm> createState() => _NewRepairOrderFormState();
}

class _NewRepairOrderFormState extends State<NewRepairOrderForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String driver = '';
  String vehicleId = '';
  String vehicle = '';

  TextEditingController descriptionController = TextEditingController();

  String _generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      List.generate(length,
          (index) => characters.codeUnitAt(random.nextInt(characters.length))),
    );
  }

  Future<void> _storeNotification(
      String notificationType, String driverName, String orderId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'notificationType': notificationType,
        'employeeName': driverName,
        'orderId': orderId,
        'vehicleId': vehicleId,
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
        else if (employeeDoc['position'] == 'Repair Manager') {
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

  Future<void> _getRequiredDetails() async {
    final user = FirebaseAuth.instance.currentUser?.email;
    if (user != null) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('employees').doc(user);
      DocumentSnapshot snapshot = await documentReference.get();
      if (snapshot.exists) {
        var value = snapshot.data() as Map<String, dynamic>;
        setState(() {
          driver = '${value['firstName']} ${value['secondName']}';
          vehicleId = value['vehicleId'] ?? '';
          vehicle = value['vehicle'] ?? '';
        });
        if (vehicleId.isEmpty) {
          return showDialog(
            context: context,
            builder: (context) {
              return buildAlertDialog1(
                  'Error',
                  'You do not have a vehicle, this may be due to the fact that you are not a driver!',
                  context);
            },
          );
        }
      } else {
        print('User does not exist');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getRequiredDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              inputRegister(
                text: const Text('Description of repair'),
                textController: descriptionController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description of the damage';
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  elevation: 5.0,
                  color: Colors.lightBlue,
                  child: MaterialButton(
                    minWidth: 320,
                    height: 42,
                    elevation: 5.0,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          String customId =
                              'repairOrder_${_generateRandomString(8)}';

                          DocumentReference repairOrderRef = FirebaseFirestore
                              .instance
                              .collection('repairOrders')
                              .doc(customId);

                          await repairOrderRef.set({
                            'order Type': 'Repair Order',
                            'driver': driver,
                            'vehicle': vehicle,
                            'vehicleId': vehicleId,
                            'description': descriptionController.text,
                            'Status': 'submitted',
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          await updateRepairUnreadCount();
                          await updateSuperUserUnreadCount();
                          await _storeNotification(
                              'Repair Order', driver, customId);

                          Navigator.pop(context);
                        } catch (e) {
                          print(e);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: const Text('Make Order'),
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
