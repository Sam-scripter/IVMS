import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/providers/driverNameProvider.dart';
import 'package:integrated_vehicle_management_system/providers/orderTypeProvider.dart';
import 'package:provider/provider.dart';

import '../Components/functions.dart';
import '../api/api_service.dart';

const List<String> fuels = ['Petrol', 'Diesel'];

class NewFuelOrder extends StatelessWidget {
  const NewFuelOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a new Fuel Order'),
        centerTitle: false,
      ),
      body: NewFuelOrderForm(),
    );
  }
}

class NewFuelOrderForm extends StatefulWidget {
  const NewFuelOrderForm({super.key});

  @override
  State<NewFuelOrderForm> createState() => _NewFuelOrderFormState();
}

class _NewFuelOrderFormState extends State<NewFuelOrderForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  String distance = "";
  late String selectedDocumentId;

  String fuelType = '';
  String vehicleId = '';
  String vehicle = '';
  String driver = '';

  Future<void> _getEmployeeDetails() async {
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
              return AlertDialog(
                title: Text('Error!'),
                content: Text(
                    'You do not have a vehicle, this may be due to the fact that you are not a driver!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('Ok'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('User does not exist');
      }
    }
  }

  Future<void> _getRequiredDetails() async {
    await _getEmployeeDetails();
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('vehicles').doc(vehicleId);
    DocumentSnapshot snapshot = await documentReference.get();
    if (snapshot.exists) {
      var value = snapshot.data() as Map<String, dynamic>;
      setState(() {
        fuelType = value['fuelType'];
      });
    }
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

  Future<void> _storeNotification(String notificationType, String driverName,
      String thisId, String vehicleId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Add the notification to the notifications collection
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'notificationType': notificationType,
        'employeeName': driverName,
        'orderId': thisId,
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
              // DropdownButton(
              //     hint: const Text('Select the Fuel Type'),
              //     isExpanded: true,
              //     value: fuelTypeDropdownValue,
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 23, vertical: 9),
              //     items: fuels.map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(value),
              //       );
              //     }).toList(),
              //     onChanged: (String? value) {
              //       setState(() {
              //         fuelTypeDropdownValue = value!;
              //       });
              //     }),
              inputRegister(
                  text: const Text('Starting Location'),
                  inputType: TextInputType.text,
                  textController: _startLocationController,
                  valueValidator: (value) {
                    if (value == null) {
                      return 'Please enter the Starting Location';
                    }
                  }),
              inputRegister(
                  text: const Text('Purpose of Transport'),
                  inputType: TextInputType.text,
                  textController: _purposeController,
                  valueValidator: (value) {
                    if (value == null) {
                      return 'Please enter Purpose of your transport';
                    }
                  }),
              inputRegister(
                  text: const Text('Destination'),
                  inputType: TextInputType.text,
                  textController: _destinationController,
                  valueValidator: (value) {
                    if (value == null) {
                      return 'Please enter your destination';
                    }
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  elevation: 5.0,
                  color: Colors.lightBlueAccent,
                  child: MaterialButton(
                    minWidth: 320,
                    height: 42,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          String customId =
                              'fuelOrder_' + _generateRandomString(8);

                          String startLocation = _startLocationController.text;
                          String destination = _destinationController.text;

                          if (startLocation.isNotEmpty &&
                              destination.isNotEmpty) {
                            String result = await ApiService.getDistance(
                                startLocation, destination);

                            setState(() {
                              distance = result;
                            });
                          } else {
                            // Handle empty input fields
                            // return Text('Please enter a valid location');
                          }

                          // Store fuel order with the custom ID
                          DocumentReference fuelOrderRef = FirebaseFirestore
                              .instance
                              .collection('Fuel Orders')
                              .doc(customId);

                          await fuelOrderRef.set({
                            'Order Type': 'Fuel Order',
                            'Fuel Type': fuelType,
                            'Origin': _startLocationController.text,
                            'Destination': _destinationController.text,
                            'distance': distance,
                            'Purpose': _purposeController.text,
                            'Driver': driver,
                            'vehicleId': vehicleId,
                            'Vehicle': vehicle,
                            'Status': 'submitted',
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          //TODO: SELECTED DOCUMENT ID

                          await updateFuelUserUnreadCount();
                          await updateSuperUserUnreadCount();
                          await updateTransportUnreadCount();
                          await _storeNotification(
                              'Fuel Order', driver, customId, vehicleId);

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
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    ]);
  }
}
