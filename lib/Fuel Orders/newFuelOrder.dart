import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';
import 'package:integrated_vehicle_management_system/providers/driverNameProvider.dart';
import 'package:integrated_vehicle_management_system/providers/orderTypeProvider.dart';
import 'package:provider/provider.dart';

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

  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  String distance = "";
  late String selectedDocumentId;

  String fuelTypeDropdownValue = fuels.first;
  String driversDropdownValue = '0';
  String vehiclesDropdownValue = '0';

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
      await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': user.email,
        'notificationType': notificationType,
        'driverName': driverName,
        'receivedNotificationId': thisId,
        'vehicleId': vehicleId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton(
                hint: const Text('Select the Fuel Type'),
                isExpanded: true,
                value: fuelTypeDropdownValue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 23, vertical: 9),
                items: fuels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    fuelTypeDropdownValue = value!;
                  });
                }),
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employees')
                  .where('position', isEqualTo: 'Driver')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> drivers = [];
                drivers.add(
                  const DropdownMenuItem(
                    value: '0',
                    child: Text('Select Driver'),
                  ),
                );

                if (snapshot.hasData) {
                  for (var driver in snapshot.data!.docs.toList()) {
                    String driverName =
                        '${driver['firstName']} ${driver['secondName']}';
                    drivers.add(
                      DropdownMenuItem(
                        value: driverName,
                        child: Text(driverName),
                      ),
                    );
                  }
                }
                return DropdownButton<String>(
                  focusColor: Colors.lightBlueAccent,
                  dropdownColor: Colors.black87,
                  hint: const Text('Select Driver'),
                  isExpanded: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: drivers,
                  onChanged: (value) {
                    setState(() {
                      driversDropdownValue = value!;
                    });
                  },
                  value: driversDropdownValue,
                );
              },
            ),
            // StreamBuilder<QuerySnapshot>(
            //     stream: FirebaseFirestore.instance
            //         .collection('vehicles')
            //         .orderBy('timestamp', descending: false)
            //         .snapshots(),
            //     builder: (context, snapshot) {
            //       List<DropdownMenuItem<String>> vehicles = [];
            //       vehicles.add(
            //         const DropdownMenuItem(
            //           value: '0',
            //           child: Text('Select Vehicle'),
            //         ),
            //       );
            //       if (snapshot.hasData) {
            //         for (var vehicle in snapshot.data!.docs.toList()) {
            //           String vehiclePlate = vehicle['licensePlateNumber'];
            //           vehicles.add(
            //             DropdownMenuItem(
            //               value: vehiclePlate,
            //               child: Text(vehiclePlate),
            //             ),
            //           );
            //         }
            //       }
            //       return DropdownButton(
            //           focusColor: Colors.lightBlueAccent,
            //           dropdownColor: Colors.black87,
            //           hint: const Text('Fuel Type'),
            //           isExpanded: true,
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 9, horizontal: 23),
            //           items: vehicles,
            //           value: vehiclesDropdownValue,
            //           onChanged: (value) {
            //             setState(() {
            //               vehiclesDropdownValue = value!;
            //             });
            //           });
            //     }),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vehicles')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> vehicles = [];
                vehicles.add(
                  const DropdownMenuItem(
                    value: '0',
                    child: Text('Select Vehicle'),
                  ),
                );
                if (snapshot.hasData) {
                  for (var vehicle in snapshot.data!.docs) {
                    String vehiclePlate = vehicle['licensePlateNumber'];
                    String documentId = vehicle.id;

                    vehicles.add(
                      DropdownMenuItem(
                        value: vehiclePlate,
                        child: Text(vehiclePlate),
                      ),
                    );
                  }
                }
                return DropdownButton(
                  focusColor: Colors.lightBlueAccent,
                  dropdownColor: Colors.black87,
                  hint: const Text('Fuel Type'),
                  isExpanded: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: vehicles,
                  value: vehiclesDropdownValue,
                  onChanged: (value) {
                    setState(() {
                      vehiclesDropdownValue = value!;
                    });
                    // Access the document ID from the selected item
                    int selectedIndex = vehicles.indexWhere(
                      (item) => item.value == value,
                    );
                    selectedDocumentId = selectedIndex > 0
                        ? (snapshot.data!.docs[selectedIndex - 1].id)
                        : '';
                    print('Selected Vehicle Document ID: $selectedDocumentId');
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Material(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                child: MaterialButton(
                  minWidth: 320,
                  height: 42,
                  elevation: 5.0,
                  color: Colors.lightBlueAccent,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
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
                          'Fuel Type': fuelTypeDropdownValue,
                          'Origin': _startLocationController.text,
                          'Destination': _destinationController.text,
                          'distance': distance,
                          'Purpose': _purposeController.text,
                          'Driver': driversDropdownValue,
                          'Vehicle': vehiclesDropdownValue,
                          'Status': 'submitted',
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        //TODO: SELECTED DOCUMENT ID

                        await _storeNotification('Fuel Order Notification',
                            driversDropdownValue, customId, selectedDocumentId);

                        String orderType = 'Fuel Order';
                        Provider.of<OrderTypeProvider>(context, listen: false)
                            .setOrderType(orderType);
                        String driverName = driversDropdownValue;
                        Provider.of<DriverNameProvider>(context, listen: false)
                            .setDriverName(driverName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                'Processing data',
                                style: GoogleFonts.lato(color: Colors.white),
                              ),
                              backgroundColor: Colors.black45),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
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
    );
  }
}
