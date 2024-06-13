import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:integrated_vehicle_management_system/Components/functions.dart';
import 'package:integrated_vehicle_management_system/Notifications/conversation_Screen.dart';
import 'package:integrated_vehicle_management_system/Notifications/fuelAllocationNotification.dart';
import 'package:integrated_vehicle_management_system/Notifications/fuelOrderNotification.dart';
import 'package:integrated_vehicle_management_system/Notifications/fuelShipmentNotification.dart';
import 'package:integrated_vehicle_management_system/Notifications/repairOrderNotification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<Map<String, dynamic>> _employees = [];
  String userRole = '';
  String userPosition = '';
  String collectionName = '';
  late Future<List<Notification>> notificationsFuture;
  Color unreadNotificationColor = Colors.lightGreenAccent;
  late List<Widget> superUserWidgets = [];
  late List<Widget> transportWidgets = [];
  late List<Widget> repairWidgets = [];
  late List<Widget> driverWidgets = [];
  late List<Widget> fuelAttendant = [];
  late List<Widget> notificationsToDisplay = [];
  final user = FirebaseAuth.instance.currentUser?.email;
  int currentUnreadCount = 0;
  // Define a set to store tapped notifications
  Set<String> tappedNotifications = {};
  final currentUser = FirebaseAuth.instance.currentUser!;
  Uint8List? _image;
  String? imageUrl;
  Map<String, Uint8List?> _employeeImages = {};

  Future<void> _fetchLatestMessages() async {
    for (var employee in _employees) {
      var lastMessage = await _fetchLastMessage(employee['emailAddress']);
      employee['lastMessage'] = lastMessage;
    }
    _employees.sort((a, b) {
      var aTimestamp = a['lastMessage']?['timestamp'] ?? Timestamp.now();
      var bTimestamp = b['lastMessage']?['timestamp'] ?? Timestamp.now();
      return bTimestamp.compareTo(aTimestamp);
    });
  }

  Future<void> _fetchImagesForEmployees() async {
    for (var employee in _employees) {
      String imageUrl = employee['imageUrl'] ?? '';
      if (imageUrl.isNotEmpty) {
        Uint8List? imageData = await fetchImageFromFirestore(imageUrl);
        _employeeImages[employee['emailAddress']] = imageData;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    getUserRole();
    getUnreadCount();
  }

  Future<Uint8List?> fetchImageFromFirestore(String imageUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
    return null;
  }

  Future<void> getUnreadCount() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUserEmail);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('unreadCount')) {
          setState(() {
            currentUnreadCount = data['unreadCount'];
          });
        } else {
          setState(() {
            currentUnreadCount = 0;
          });
        }
      }
    }
  }

  Future<void> markNotificationRead(
      String notificationId, String userId) async {
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .collection('users')
        .doc(userId);

    await userDoc.update({'read': true});
  }

  //Get the role and position of the currently logged in user
  Future<void> getUserRole() async {
    //get current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //if the user is available, fetch the position and role of the currently logged in user
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(user.email)
          .get();

      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        String role = userData['role'];
        String position = userData['position'];

        setState(() {
          userRole = role;
          userPosition = position;
        });
      }
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('emailAddress', isNotEqualTo: currentUser?.email)
          .orderBy('emailAddress', descending: false)
          .get();

      _employees = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      await _fetchLatestMessages();
      await _fetchImagesForEmployees();
      setState(() {});

      print('Employees are fetched');
    } catch (e) {
      print(e);
      print('Did not fetch Employees');
    }
  }

  //get the conversation id
  String _generateConversationId(String userEmail1, String userEmail2) {
    List<String> emails = [userEmail1, userEmail2];
    emails.sort(); // Sort emails to ensure consistency
    return emails.join("_");
  }

  Future<Map<String, dynamic>> _fetchLastMessage(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_generateConversationId(currentUser!.email!, userId))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;
      data['messageId'] = doc.id;
      return data;
    }

    return {}; // Return an empty map if no messages are found
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return ''; // Handle null case appropriately
    }

    if (timestamp is Timestamp) {
      // If it's a Firestore Timestamp, convert it to DateTime
      timestamp = timestamp.toDate();
    }

    String hour = timestamp.hour?.toString().padLeft(2, '0') ?? '00';
    String minute = timestamp.minute?.toString().padLeft(2, '0') ?? '00';

    return '$hour:$minute';
  }

  Future<String?> determineNotification(String documentId) async {
    if (documentId.startsWith('fuelOrder_')) {
      collectionName = 'Fuel Orders';
    } else if (documentId.startsWith('repairOrder_')) {
      collectionName = 'Repair Orders';
    } else if (documentId.startsWith('fuelShipment_')) {
      collectionName = 'Fuel Shipments';
    } else if (documentId.startsWith('fuelAllocation_')) {
      collectionName = 'Fuel Allocations';
    }

    return collectionName;
  }

  // Map to store read state of each notification
  Map<String, bool> notificationReadState = {};
  void updateReadState(String notificationId, bool read) {
    setState(() {
      notificationReadState[notificationId] = read;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.lato(),
          ),
          bottom: TabBar(
            indicatorColor: Colors.lightBlue,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 15),
            tabs: [
              Tab(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        'Notifications',
                        style: GoogleFonts.lato(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                    if (currentUnreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                          ),
                          child: Text(
                            currentUnreadCount > 9
                                ? '9+'
                                : '$currentUnreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Text(
                  'Chats',
                  style: GoogleFonts.lato(fontSize: 17.0),
                ),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> notificationWidgets = [];
                      for (var notification in snapshot.data!.docs) {
                        var value = notification.data() as Map<String, dynamic>;
                        String notificationId = notification.id;
                        String orderId = value['orderId'];
                        String employeeName = value['employeeName'];
                        String notificationType = value['notificationType'];
                        String userEmail = value['userEmail'];
                        String vehicleId = value['vehicleId'] ?? '';
                        String approvedBy = value['approvedBy'] ?? '';
                        String declinedBy = value['declinedBy'] ?? '';
                        String completedBy = value['completedBy'] ?? '';

                        // Fetch the read status for the current user
                        bool read = true;
                        var userDocSnapshot = notification.reference
                            .collection('users')
                            .doc(user)
                            .get();
                        userDocSnapshot.then((doc) {
                          if (doc.exists) {
                            var userDocValue =
                                doc.data() as Map<String, dynamic>;
                            read = userDocValue['read'] ?? false;
                          }
                        });

                        if (userRole == 'SuperUser') {
                          notificationWidgets.add(GestureDetector(
                              child: Container(
                            decoration: BoxDecoration(
                              color: read
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                                title: Text(
                                  notificationType,
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    color: read
                                        ? Colors.white
                                        : Colors.blue.shade100,
                                    fontWeight: read
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: notificationType == 'Fuel Order' ||
                                        notificationType == 'Repair Order' ||
                                        notificationType == 'Fuel Shipment' ||
                                        notificationType == 'Fuel Allocation'
                                    ? Text(
                                        'made by: $employeeName',
                                        style: GoogleFonts.lato(fontSize: 15),
                                      )
                                    : (notificationType ==
                                                'Approved Fuel Order' ||
                                            notificationType ==
                                                'Approved Repair Order')
                                        ? Text(
                                            'approved by: $approvedBy',
                                            style:
                                                GoogleFonts.lato(fontSize: 15),
                                          )
                                        : (notificationType ==
                                                    'Completed Fuel Order' ||
                                                notificationType ==
                                                    'Completed Repair Order')
                                            ? Text(
                                                'completed by: $completedBy',
                                                style: GoogleFonts.lato(
                                                    fontSize: 15),
                                              )
                                            : Text(
                                                'declined by: $declinedBy',
                                                style: GoogleFonts.lato(
                                                    fontSize: 15),
                                              ),
                                onTap: () async {
                                  // await markNotificationRead(
                                  //     notificationId, user!);
                                  updateReadState(notificationId, true);
                                  setState(() {});

                                  await getUnreadCount();
                                  // Check if the order ID has been tapped before
                                  if (!tappedNotifications
                                      .contains(notificationId)) {
                                    // Add the order ID to the set
                                    tappedNotifications.add(orderId);

                                    // Reset unread count if it's not already 0
                                    if (currentUnreadCount != 0) {
                                      await resetUnreadCount();
                                      setState(() {});
                                    }
                                  }

                                  if (orderId.startsWith('fuelOrder_')) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FuelOrderNotification(
                                        orderId: orderId,
                                        vehicleId: vehicleId,
                                      );
                                    }));
                                  } else if (orderId
                                      .startsWith('repairOrder_')) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return RepairOrderNotification(
                                        orderId: orderId,
                                        vehicleId: vehicleId,
                                      );
                                    }));
                                  } else if (orderId
                                      .startsWith('fuelShipment_')) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FuelShipmentNotification(
                                        orderId: orderId,
                                      );
                                    }));
                                  } else if (orderId
                                      .startsWith('fuelAllocation_')) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FuelAllocationNotification(
                                                    notificationId:
                                                        notificationId)));
                                  }
                                }),
                          )));
                        } else if (userRole == 'Admin' &&
                            userPosition == 'Transport Manager') {
                          if (orderId.startsWith('fuelOrder_') ||
                              orderId.startsWith('fuelAllocation_') ||
                              orderId.startsWith('fuel_shipment')) {
                            notificationWidgets.add(GestureDetector(
                                child: Container(
                              decoration: BoxDecoration(
                                color:
                                    read ? Colors.white : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: read
                                        ? Colors.grey.withOpacity(0.5)
                                        : Colors.blue.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text(
                                  notificationType,
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    color: read
                                        ? Colors.white
                                        : Colors.blue.shade100,
                                    fontWeight: read
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: notificationType == 'Fuel Order' ||
                                        notificationType == 'Fuel Shipment' ||
                                        notificationType == 'Fuel Allocation'
                                    ? Text(
                                        'made by: $employeeName',
                                        style: GoogleFonts.lato(fontSize: 15),
                                      )
                                    : (notificationType ==
                                            'Approved Fuel Order')
                                        ? Text(
                                            'approved by: $approvedBy',
                                            style:
                                                GoogleFonts.lato(fontSize: 15),
                                          )
                                        : (notificationType ==
                                                'Completed Fuel Order')
                                            ? Text(
                                                'completed by: $completedBy',
                                                style: GoogleFonts.lato(
                                                    fontSize: 15),
                                              )
                                            : Text(
                                                'declined by: $declinedBy',
                                                style: GoogleFonts.lato(
                                                    fontSize: 15),
                                              ),
                                onTap: () async {
                                  // await markNotificationRead(
                                  //     notificationId, user!);
                                  updateReadState(notificationId, true);
                                  setState(() {});

                                  await getUnreadCount();
                                  // Check if the order ID has been tapped before
                                  if (!tappedNotifications
                                      .contains(notificationId)) {
                                    // Add the order ID to the set
                                    tappedNotifications.add(orderId);

                                    // Reset unread count if it's not already 0
                                    if (currentUnreadCount != 0) {
                                      await resetUnreadCount();
                                    }
                                  }

                                  if (orderId.startsWith('fuelOrder_')) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FuelOrderNotification(
                                          orderId: orderId,
                                          vehicleId: vehicleId);
                                    }));
                                  } else if (orderId
                                      .startsWith('fuelAllocation_')) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FuelAllocationNotification(
                                          notificationId: notificationId);
                                    }));
                                  } else if (orderId
                                      .startsWith('fuelShipment_')) {
                                    return;
                                  }
                                },
                              ),
                            )));
                          }
                        } else if (userRole == 'Admin' &&
                            userPosition == 'Repair Manager') {
                          if (orderId.startsWith('repairOrder_')) {
                            notificationWidgets.add(GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: read
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(
                                    notificationType,
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      color: read
                                          ? Colors.white
                                          : Colors.blue.shade100,
                                      fontWeight: read
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: notificationType == 'Repair Order'
                                      ? Text(
                                          'made by: $employeeName',
                                          style: GoogleFonts.lato(fontSize: 15),
                                        )
                                      : (notificationType ==
                                              'Approved Repair Order')
                                          ? Text(
                                              'approved by: $approvedBy',
                                              style: GoogleFonts.lato(
                                                  fontSize: 15),
                                            )
                                          : (notificationType ==
                                                  'Completed Repair Order')
                                              ? Text(
                                                  'completed by: $completedBy',
                                                  style: GoogleFonts.lato(
                                                      fontSize: 15),
                                                )
                                              : Text(
                                                  'declined by: $declinedBy',
                                                  style: GoogleFonts.lato(
                                                      fontSize: 15),
                                                ),
                                ),
                              ),
                              onTap: () async {
                                // await markNotificationRead(
                                //     notificationId, user!);
                                updateReadState(notificationId, true);
                                setState(() {});

                                await getUnreadCount();
                                // Check if the order ID has been tapped before
                                if (!tappedNotifications
                                    .contains(notificationId)) {
                                  // Add the order ID to the set
                                  tappedNotifications.add(orderId);

                                  // Reset unread count if it's not already 0
                                  if (currentUnreadCount != 0) {
                                    await resetUnreadCount();
                                  }
                                }

                                if (orderId.startsWith('repairOrder_')) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RepairOrderNotification(
                                        orderId: orderId, vehicleId: vehicleId);
                                  }));
                                }
                              },
                            ));
                          }
                        } else if (userRole == 'User' &&
                            userPosition == 'Fuel Attendant') {
                          if (orderId.startsWith('fuelOrder_') &&
                                  notificationType == 'Approved Fuel Order' ||
                              orderId.startsWith('fuelAllocation_')) {
                            notificationWidgets.add(GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: read
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(
                                    notificationType,
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      color: read
                                          ? Colors.white
                                          : Colors.blue.shade100,
                                      fontWeight: read
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: notificationType ==
                                          'Approved Fuel Order'
                                      ? Text(
                                          'made by: $employeeName',
                                          style: GoogleFonts.lato(fontSize: 15),
                                        )
                                      : (notificationType == 'Fuel allocation')
                                          ? Text(
                                              'new Fuel Allocation',
                                              style: GoogleFonts.lato(
                                                  fontSize: 15),
                                            )
                                          : null,
                                ),
                              ),
                              onTap: () async {
                                // await markNotificationRead(
                                //     notificationId, user!);
                                updateReadState(notificationId, true);
                                setState(() {});

                                await getUnreadCount();
                                // Check if the order ID has been tapped before
                                if (!tappedNotifications
                                    .contains(notificationId)) {
                                  // Add the order ID to the set
                                  tappedNotifications.add(orderId);

                                  // Reset unread count if it's not already 0
                                  if (currentUnreadCount != 0) {
                                    await resetUnreadCount();
                                  }
                                }

                                if (orderId.startsWith('fuelOrder_')) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return FuelOrderNotification(
                                        orderId: orderId, vehicleId: vehicleId);
                                  }));
                                } else if (orderId
                                    .startsWith('fuelAllocation_')) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FuelAllocationNotification(
                                                  notificationId:
                                                      notificationId)));
                                }
                              },
                            ));
                          }
                        } else if (userRole == 'User' &&
                            userPosition == 'Driver') {
                          if (orderId.startsWith('fuelOrder_') &&
                                  notificationType != 'Fuel Order' &&
                                  userEmail == user ||
                              orderId.startsWith('repairOrder_') &&
                                  notificationType != 'Repair Order') {
                            notificationWidgets.add(GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: read
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(
                                    notificationType,
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      color: read
                                          ? Colors.white
                                          : Colors.blue.shade100,
                                      fontWeight: read
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: notificationType ==
                                              'Approved Fuel Order' ||
                                          notificationType ==
                                              'Approved Repair Order'
                                      ? Text(
                                          'approved by: $approvedBy',
                                          style: GoogleFonts.lato(fontSize: 15),
                                        )
                                      : (notificationType ==
                                                  'Completed Fuel Order' ||
                                              notificationType ==
                                                  'Completed Repair Order')
                                          ? Text(
                                              'completed by: $completedBy',
                                              style: GoogleFonts.lato(
                                                  fontSize: 15),
                                            )
                                          : (notificationType ==
                                                      'Declined Fuel Order') ||
                                                  notificationType ==
                                                      'Declined Repair Order'
                                              ? Text(
                                                  'declined by: $declinedBy',
                                                  style: GoogleFonts.lato(
                                                      fontSize: 15),
                                                )
                                              : null,
                                ),
                              ),
                              onTap: () async {
                                // await markNotificationRead(
                                //     notificationId, user!);
                                updateReadState(notificationId, true);
                                setState(() {});

                                await getUnreadCount();
                                // Check if the order ID has been tapped before
                                if (!tappedNotifications
                                    .contains(notificationId)) {
                                  // Add the order ID to the set
                                  tappedNotifications.add(orderId);

                                  // Reset unread count if it's not already 0
                                  if (currentUnreadCount != 0) {
                                    await resetUnreadCount();
                                  }
                                }

                                if (orderId.startsWith('fuelOrder_')) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return FuelOrderNotification(
                                        orderId: orderId, vehicleId: vehicleId);
                                  }));
                                } else if (orderId.startsWith('repairOrder_')) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RepairOrderNotification(
                                        orderId: orderId, vehicleId: vehicleId);
                                  }));
                                }
                              },
                            ));
                          }
                        }
                      }
                      return Column(
                        children: notificationWidgets,
                      );
                    }
                    return const Center(
                      child: Text('No notifications Found'),
                    );
                  }),
            ),
            _employees.isNotEmpty
                ? ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: _fetchLastMessage(
                            _employees[index]['emailAddress']),
                        builder: (context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Text('Loading...')); // Loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final lastMessage = snapshot.data?['text'] ??
                                'Start a conversation!';
                            final time =
                                _formatTimestamp(snapshot.data?['timestamp']);
                            final isRead = snapshot.data?['read'] ?? true;
                            Uint8List? image = _employeeImages[_employees[index]
                                ['emailAddress']];

                            return ConversationTile(
                              name:
                                  '${_employees[index]['firstName']} ${_employees[index]['secondName']}',
                              lastMessage: lastMessage,
                              time: time,
                              userId: _employees[index]['emailAddress'],
                              userEmail: _employees[index]['emailAddress'],
                              isRead: isRead,
                              image: image,
                            );
                          }
                        },
                      );
                    })
                : const Center(
                    child: Text('No conversations found'),
                  ),
          ],
        ),
      ),
    );
  }
}

class ConversationTile extends StatefulWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String userId;
  final String userEmail;
  final bool isRead;
  final Uint8List? image;

  const ConversationTile({
    Key? key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.userId,
    required this.userEmail,
    required this.isRead,
    this.image,
  }) : super(key: key);

  StreamSubscription<DocumentSnapshot> listenForOnlineStatus(
      String userId, Function(bool) callback) {
    return FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final bool isOnline = snapshot['isOnline'] ?? false;
        callback(isOnline);
      }
    });
  }

  @override
  _ConversationTileState createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  bool isOnline = false;
  late StreamSubscription<DocumentSnapshot> onlineStatusSubscription;

  @override
  void initState() {
    super.initState();
    onlineStatusSubscription =
        widget.listenForOnlineStatus(widget.userId, (bool online) {
      if (mounted) {
        setState(() {
          isOnline = online;
        });
      }
    });
  }

  @override
  void dispose() {
    onlineStatusSubscription.cancel();
    super.dispose();
  }

  void showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.image != null
                  ? Image.memory(widget.image!)
                  : const Text('No image available'),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          if (widget.image != null) {
            showImageDialog(context);
          }
        },
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage:
                  widget.image != null ? MemoryImage(widget.image!) : null,
              child: widget.image == null
                  ? Text(
                      widget.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.green : Colors.red,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        widget.name,
        style: GoogleFonts.lato(
            fontWeight: widget.isRead ? FontWeight.normal : FontWeight.bold),
      ),
      subtitle: Text(
        widget.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: widget.isRead ? Colors.grey : Colors.black,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.time,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              child: isOnline
                  ? Text('online', style: GoogleFonts.lato(color: Colors.green))
                  : Text(
                      'offline',
                      style: GoogleFonts.lato(color: Colors.grey),
                    ),
            ),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(
                      username: widget.name,
                      email: widget.userEmail,
                    )));
      },
    );
  }
}
