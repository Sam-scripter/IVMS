import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Components/profileTextBox.dart';

class FuelOrderNotification extends StatefulWidget {
  final String orderId;
  final String driverEmail;
  final String notificationType;
  final String driver;
  final String? vehicleID;

  const FuelOrderNotification(
      {super.key,
      required this.orderId,
      required this.driver,
      required this.driverEmail,
      required this.notificationType,
      this.vehicleID});

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
  double petrolAmount = 0;
  double dieselAmount = 0;
  double litresRequired = 0;

  @override
  void initState() {
    super.initState();
    getNotificationProfile();
  }

  Future<String?> _determineCollectionFromId(String documentId) async {
    if (documentId.startsWith('fuelOrder_')) {
      return 'Fuel Orders';
    } else if (documentId.startsWith('repairOrder_')) {
      return 'Repair Orders';
    }

    // If the ID doesn't match known prefixes, return null or handle it accordingly
    return null;
  }

  Future<void> getFuelConsumption() async {
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleID);
    DocumentSnapshot snapshot = await documentRef.get();

    if (snapshot.exists) {
      fuelConsumption = snapshot['fuelConsumption'];
      print("fuel consumption: $fuelConsumption");
    }
  }

  Future<void> getNotificationProfile() async {
    String? collectionName = await _determineCollectionFromId(widget.orderId);
    if (collectionName != null) {
      print('The document belongs to the collection: $collectionName');
      if (collectionName == 'Fuel Orders') {
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
        } else {
          print('Document not found');
        }
      }
    } else {
      print('Unable to determine the collection for the given ID');
    }
  }

  Future<void> _storeNotification(
      String notificationType, String driverName, String thisId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'ApprovedUser': user.email,
        'notificationType': notificationType,
        'orderStatus': 'Approved',
        'driverName': driverName,
        'receivedNotificationId': thisId,
        'timestamp': FieldValue.serverTimestamp(),
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId),
        centerTitle: false,
      ),
      body: FutureBuilder<void>(
        future: getNotificationProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileTextBox(title: 'Order Type', titleValue: orderType),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(title: 'Fuel Type', titleValue: fuelType),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(
                        title: 'Starting Location', titleValue: origin),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(
                        title: 'Destination', titleValue: destination),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(title: 'Distance', titleValue: distance),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(
                        title: 'Purpose of Travel', titleValue: purpose),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(title: 'Driver', titleValue: driver),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(title: 'Vehicle', titleValue: vehicle),
                    const SizedBox(
                      height: 15.0,
                    ),
                    FutureBuilder<void>(
                        future: getFuelConsumption(),
                        builder: (context, fuelConsumptionSnapshot) {
                          if (fuelConsumptionSnapshot.connectionState ==
                              ConnectionState.done) {
                            print(double.parse(
                                distance.replaceAll(RegExp(r'[^0-9.]'), '')));

                            litresRequired = double.parse(distance.replaceAll(
                                    RegExp(r'[^0-9.]'), '')) /
                                fuelConsumption;
                            return ProfileTextBox(
                                title: 'Litres Required',
                                titleValue: litresRequired.toStringAsFixed(2));
                          } else {
                            return const ProfileTextBox(
                                title: 'Litres Required',
                                titleValue: 'loading....');
                          }
                        }),
                    const SizedBox(
                      height: 15.0,
                    ),
                    ProfileTextBox(title: 'Order Status', titleValue: status),
                    const SizedBox(
                      height: 15.0,
                    ),
                    if (status == 'submitted')
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('fuelStations')
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<DropdownMenuItem<String>> fuelStations = [];
                          fuelStations.add(
                            const DropdownMenuItem(
                              value: '0',
                              child: Text('Select a fuel station'),
                            ),
                          );

                          if (snapshot.hasData) {
                            for (var value in snapshot.data!.docs.toList()) {
                              String stationName = '${value['stationName']}';
                              currentDieselAmount =
                                  value['currentDieselAmount'];
                              currentPetrolAmount =
                                  value['currentPetrolAmount'];
                              fuelStations.add(
                                DropdownMenuItem(
                                  value: stationName,
                                  child: Text(stationName),
                                ),
                              );
                            }
                          }

                          return DropdownButton(
                            dropdownColor: Colors.black87,
                            focusColor: Colors.lightBlueAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 9, horizontal: 23),
                            hint: const Text('select fuel attendant'),
                            isExpanded: true,
                            items: fuelStations,
                            onChanged: (value) {
                              setState(() {
                                stationDropdownValue = value!;
                                updateFuelAmounts(snapshot.data!, value);
                              });
                            },
                            value: stationDropdownValue,
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 13.0),
                      child: status == 'submitted'
                          ? Column(
                              children: [
                                Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                  elevation: 6.0,
                                  color: Colors.lightBlue,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      petrolAmount =
                                          double.parse(currentPetrolAmount);
                                      dieselAmount =
                                          double.parse(currentDieselAmount);
                                      if (fuelType == 'Petrol') {
                                        if (litresRequired < petrolAmount) {
                                          await fuelOrdersCollection
                                              .doc(widget.orderId)
                                              .update({'Status': 'Approved'});
                                          await _storeNotification(
                                              'Approved Fuel Order Notification',
                                              driver,
                                              widget.orderId);

                                          Navigator.pop(context);
                                        } else {
                                          print(
                                              'Not enough Fuel, select another station or recharge the station');
                                        }
                                      } else if (fuelType == 'Diesel') {
                                        if (litresRequired < dieselAmount) {
                                          await fuelOrdersCollection
                                              .doc(widget.orderId)
                                              .update({'Status': 'Approved'});
                                          await _storeNotification(
                                              'Approved Fuel Order Notification',
                                              driver,
                                              widget.orderId);

                                          Navigator.pop(context);
                                        } else {
                                          print(
                                              'Not enough Fuel, select another station or recharge the station');
                                        }
                                      }
                                    },
                                    minWidth: 300,
                                    height: 42,
                                    child: const Text(
                                      'Approve Order',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                ),
                                Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                  elevation: 6.0,
                                  color: Colors.lightBlue,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      await fuelOrdersCollection
                                          .doc(widget.orderId)
                                          .update({'Status': 'Declined'});
                                      await _storeNotification(
                                          'Declined Fuel Order Notification',
                                          driver,
                                          widget.orderId);

                                      Navigator.pop(context);
                                    },
                                    minWidth: 300,
                                    height: 42,
                                    child: const Text(
                                      'Decline Order',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : (status == 'Approved')
                              ? Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                  elevation: 6.0,
                                  color: Colors.lightBlue,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      await fuelOrdersCollection
                                          .doc(widget.orderId)
                                          .update({'Status': 'Completed'});
                                      await _storeNotification(
                                          'Completed Fuel Order Notification',
                                          driver,
                                          widget.orderId);

                                      Navigator.pop(context);
                                    },
                                    minWidth: 300,
                                    height: 42,
                                    child: const Text(
                                      'Complete Order',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                )
                              : null,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
