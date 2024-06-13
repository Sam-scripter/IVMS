import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Components/functions.dart';

import '../Components/profileTextBox.dart';

class FuelOrderNotification extends StatefulWidget {
  final String orderId;
  final String vehicleId;

  const FuelOrderNotification({
    super.key,
    required this.orderId,
    required this.vehicleId,
  });

  @override
  State<FuelOrderNotification> createState() => _FuelOrderNotificationState();
}

class _FuelOrderNotificationState extends State<FuelOrderNotification> {
  final fuelOrdersCollection =
      FirebaseFirestore.instance.collection('Fuel Orders');
  String orderType = '';
  String fuelType = '';
  String origin = '';
  String destination = '';
  String distance = '';
  String purpose = '';
  String driver = '';
  String vehicle = '';
  String status = '';
  double fuelConsumption = 0;
  String stationDropdownValue = '';
  String currentPetrolAmount = '';
  String currentDieselAmount = '';
  double dieselAmount = 0;
  double litresRequired = 0;
  String currentEmployeeName = '';
  String positionOfEmployee = '';

  Future<void> notificationDetails() async {
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('Fuel Orders')
        .doc(widget.orderId);

    DocumentSnapshot documentSnapshot = await documentRef.get();

    if (documentSnapshot.exists) {
      orderType = documentSnapshot['Order Type'];
      fuelType = documentSnapshot['Fuel Type'];
      origin = documentSnapshot['Origin'];
      destination = documentSnapshot['Destination'];
      distance = documentSnapshot['distance'];
      purpose = documentSnapshot['Purpose'];
      driver = documentSnapshot['Driver'];
      vehicle = documentSnapshot['Vehicle'];
      status = documentSnapshot['Status'];
      litresRequired = documentSnapshot['Litres Required'] ?? 0;
    }
  }

  Future<void> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser?.email;
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('employees').doc(user);
    DocumentSnapshot snapshot = await documentRef.get();

    if (snapshot.exists) {
      currentEmployeeName =
          '${snapshot['firstName']} ${snapshot['secondName']}';
      positionOfEmployee = snapshot['position'];
      setState(() {});
    }
  }

  Future<void> getFuelConsumption() async {
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleId);
    DocumentSnapshot snapshot = await documentRef.get();

    if (snapshot.exists) {
      fuelConsumption = snapshot['fuelConsumption'];
      print("fuel consumption: $fuelConsumption");
    }
  }

  void updateFuelAmounts(QuerySnapshot snapshot, String selectedStation) {
    // Find the selected station in the snapshot data
    var selectedStationData = snapshot.docs
        .firstWhere((station) => station['stationName'] == selectedStation);

    // Update the current diesel and petrol amounts
    setState(() {
      currentDieselAmount = selectedStationData['currentDieselAmount'];
      currentPetrolAmount = selectedStationData['currentPetrolAmount'];
    });
  }

  Future<void> editField(String field) async {
    String newValue = ''; // Declare newValue outside showDialog

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Edit $field',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new $field',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              newValue = value; // Update newValue with user input
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (newValue.trim().isNotEmpty) {
      await fuelOrdersCollection.doc(widget.orderId).update({field: newValue});

      setState(() {
        litresRequired = double.parse(newValue);
        distance = '$newValue km';
      });
    }
  }

  Future<void> editFieldDistance(String field) async {
    String newValue = ''; // Declare newValue outside showDialog

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Edit $field',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new $field',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              newValue = value; // Update newValue with user input
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (newValue.trim().isNotEmpty) {
      newValue = '$newValue km';
      await fuelOrdersCollection.doc(widget.orderId).update({field: newValue});

      setState(() {
        distance = newValue;
        litresRequired = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.orderId),
          centerTitle: false,
        ),
        body: FutureBuilder(
          future: notificationDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileTextBox1(
                          title: 'Order Type', titleValue: orderType),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(title: 'Fuel Type', titleValue: fuelType),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(
                          title: 'Starting Location', titleValue: origin),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(
                          title: 'Destination', titleValue: destination),
                      SizedBox(height: 15.0),
                      status == 'submitted'
                          ? ProfileTextBox(
                              title: 'Distance',
                              titleValue: distance,
                              function: () => editFieldDistance('distance'),
                            )
                          : ProfileTextBox1(
                              title: 'Distance', titleValue: distance),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(
                          title: 'Purpose of Travel', titleValue: purpose),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(title: 'Driver', titleValue: driver),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(title: 'Vehicle', titleValue: vehicle),
                      SizedBox(height: 15.0),
                      litresRequired != 0
                          ? ProfileTextBox1(
                              title: 'Litres Required',
                              titleValue: litresRequired.toStringAsFixed(1))
                          : FutureBuilder(
                              future: getFuelConsumption(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (fuelConsumption != 0) {
                                    litresRequired = double.parse((double.parse(
                                                distance.replaceAll(
                                                    RegExp(r'[^0-9.]'), '')) *
                                            fuelConsumption)
                                        .ceil()
                                        .toString());
                                  }
                                  return ProfileTextBox(
                                    title: 'Litres Required',
                                    titleValue:
                                        litresRequired.toStringAsFixed(1),
                                    function: () =>
                                        editField('Litres Required'),
                                  );
                                } else {
                                  return ProfileTextBox(
                                    title: 'Litres Required',
                                    titleValue: 'Loading....',
                                  );
                                }
                              }),
                      SizedBox(height: 15.0),
                      ProfileTextBox1(
                          title: 'Order Status', titleValue: status),
                      SizedBox(height: 15.0),
                      if (status == 'submitted')
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('fuelStations')
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<DropdownMenuItem<String>> fuelStations = [];
                              // Ensure the default item has a unique value
                              fuelStations.add(const DropdownMenuItem(
                                child: Text('Select Fuel Station'),
                                value:
                                    '', // Change value to an empty string or another unique value
                              ));
                              if (snapshot.hasData) {
                                for (var value in snapshot.data!.docs) {
                                  String stationName = value['stationName'];
                                  fuelStations.add(
                                    DropdownMenuItem(
                                      child: Text(stationName),
                                      value: stationName,
                                    ),
                                  );
                                }
                              }
                              return DropdownButton(
                                dropdownColor: Colors.black87,
                                focusColor: Colors.lightBlueAccent,
                                hint: const Text('Allocate Station'),
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9, horizontal: 7),
                                items: fuelStations,
                                onChanged: (stationValue) {
                                  setState(() {
                                    stationDropdownValue = stationValue!;
                                    updateFuelAmounts(
                                        snapshot.data!, stationValue);
                                  });
                                },
                                value: stationDropdownValue,
                              );
                            }
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 13.0),
                        child: status == 'submitted' &&
                                positionOfEmployee == 'Transport Manager'
                            ? Column(
                                children: [
                                  Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    elevation: 6.0,
                                    color: Colors.lightBlue[700],
                                    child: MaterialButton(
                                      onPressed: () async {
                                        try {
                                          print(currentPetrolAmount);
                                          double petrolAmount = double.parse(
                                              currentPetrolAmount.trim());
                                          dieselAmount =
                                              double.parse(currentDieselAmount);
                                          if (fuelType == 'Petrol') {
                                            if (litresRequired < petrolAmount) {
                                              await fuelOrdersCollection
                                                  .doc(widget.orderId)
                                                  .update({
                                                'Status': 'Approved',
                                                'Litres Required':
                                                    litresRequired,
                                              });
                                              await getCurrentUser();
                                              await storeApprovedNotification(
                                                  'Approved Fuel Order',
                                                  driver,
                                                  widget.orderId,
                                                  widget.vehicleId,
                                                  currentEmployeeName);
                                              updateFuelUserUnreadCount();
                                              updateSuperUserUnreadCount();
                                              updateTransportUnreadCount();
                                              Navigator.pop(context);
                                            } else {
                                              print(
                                                  'Not enough fuel, select another station or recharge the station');
                                            }
                                          } else if (fuelType == 'Diesel') {
                                            if (litresRequired < dieselAmount) {
                                              await fuelOrdersCollection
                                                  .doc(widget.orderId)
                                                  .update({
                                                'Status': 'Approved',
                                                'Litres Required':
                                                    litresRequired,
                                              });
                                              await getCurrentUser();
                                              await storeApprovedNotification(
                                                  'Approved Fuel Order',
                                                  driver,
                                                  widget.orderId,
                                                  widget.vehicleId,
                                                  currentEmployeeName);
                                              await updateFuelUserUnreadCount();
                                              await updateSuperUserUnreadCount();
                                              await updateTransportUnreadCount();
                                              Navigator.pop(context);
                                            } else {
                                              print(
                                                  'Not enough fuel, select another station or recharge the station');
                                            }
                                          }
                                        } catch (e) {
                                          print(
                                              'currentPetrolAmount is equal to: $currentPetrolAmount');
                                        }
                                      },
                                      minWidth: 400,
                                      height: 40,
                                      child: Text('Approve Order',
                                          style: TextStyle(fontSize: 20.0)),
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    elevation: 6.0,
                                    color: Colors.lightBlue[700],
                                    child: MaterialButton(
                                      onPressed: () async {
                                        await fuelOrdersCollection
                                            .doc(widget.orderId)
                                            .update({
                                          'Status': 'Declined',
                                          'Litres Required': litresRequired,
                                        });
                                        await getCurrentUser();
                                        await storeDeclinedNotification(
                                            'Declined Fuel Order',
                                            driver,
                                            widget.orderId,
                                            widget.vehicleId,
                                            currentEmployeeName);
                                        await updateFuelUserUnreadCount();
                                        await updateSuperUserUnreadCount();
                                        await updateTransportUnreadCount();
                                        Navigator.pop(context);
                                      },
                                      minWidth: 400,
                                      height: 40,
                                      child: const Text('Decline Order',
                                          style: TextStyle(fontSize: 20.0)),
                                    ),
                                  ),
                                ],
                              )
                            : (status == 'Approved' &&
                                    positionOfEmployee == 'Fuel Attendant')
                                ? Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    elevation: 6.0,
                                    color: Colors.lightBlue,
                                    child: MaterialButton(
                                      onPressed: () async {
                                        try {
                                          double newDistance = double.parse(
                                              distance.replaceAll(
                                                  RegExp(r'[^0-9.]'), ''));

                                          await fuelOrdersCollection
                                              .doc(widget.orderId)
                                              .update({'Status': 'Completed'});
                                          await getCurrentUser();
                                          await storeCompletedNotification(
                                              'Completed Fuel Order',
                                              driver,
                                              widget.orderId,
                                              widget.vehicleId,
                                              currentEmployeeName);
                                          await updateFuelUserUnreadCount();
                                          await updateSuperUserUnreadCount();
                                          await updateTransportUnreadCount();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          // print(
                                          //     'odometer Reading: $odometerReading');
                                        }
                                      },
                                      minWidth: 300,
                                      height: 42,
                                      child: Text('Complete Order',
                                          style: TextStyle(fontSize: 20.0)),
                                    ),
                                  )
                                : null, // Placeholder for other status
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(child: Text('Loading....'));
          },
        ));
  }
}
