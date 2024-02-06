import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Notifications/conversation_Screen.dart';
import 'package:integrated_vehicle_management_system/Notifications/fuelOrderNotification.dart';
import 'package:integrated_vehicle_management_system/providers/driverNameProvider.dart';
import 'package:integrated_vehicle_management_system/providers/orderTypeProvider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  final String? orderId;
  final String? senderId;

  const NotificationsPage({super.key, this.orderId, this.senderId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<Map<String, dynamic>> _employees = [];
  late List<Map<String, dynamic>> _notifications = [];
  Map<String, int> unreadMessageCounts = {};
  String userRole = '';
  String userPosition = '';
  String collection = '';
  Color unreadNotificationColor = Colors.white;
  late List<Widget> superUserWidgets = [];
  late List<Widget> transportWidgets = [];
  late List<Widget> repairWidgets = [];
  late List<Widget> driverWidgets = [];
  late List<Widget> fuelAttendant = [];
  late List<Widget> notificationsToDisplay = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchNotifications();
    getUserRole();
  }

  Future<void> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
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

  void updateUnreadCount(String userEmail) {
    // Increment unread count for the user
    setState(() {
      unreadMessageCounts.update(userEmail, (count) => count + 1,
          ifAbsent: () => 1);
    });
  }

  Future<void> _fetchEmployees() async {
    try {
      // Get the current user
      final currentUser = FirebaseAuth.instance.currentUser;

      //get all the users apart from the currently logged in user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('emailAddress', isNotEqualTo: currentUser?.email)
          .orderBy('emailAddress', descending: false)
          .get();

      _employees = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});

      print('Employees are fetched');
    } catch (e) {
      print(e);
      print('Did not fetch Employees');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      // Get the current user
      final currentUser = FirebaseAuth.instance.currentUser;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      _notifications = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});

      print('notifications are fetched');
    } catch (e) {
      print(e);
      print('Did not fetch notifications');
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
      return doc.data() as Map<String, dynamic>;
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

  @override
  Widget build(BuildContext context) {
    // Filter notifications based on type and user role
    List<Map<String, dynamic>> filteredNotifications =
        _notifications.where((notification) {
      if (userRole == 'SuperUser') {
        return true;
      } else if (notification['notificationType'] ==
              'Fuel Order Notification' &&
          userRole == 'Admin' &&
          userPosition == 'Transport Manager') {
        return true;
      } else if (notification['notificationType'] ==
              'Repair Order Notification' &&
          userRole == 'Admin' &&
          userPosition == 'Repair Manager') {
        return true;
      }
      return false;
    }).toList();

    // Display notifications based on type and user role
    notificationsToDisplay = filteredNotifications.map((notification) {
      String receivedNotificationId = notification['receivedNotificationId'];
      String driverName = notification['driverName'];
      String driverEmail = notification['userEmail'] ?? 'no driverEmail';
      String notificationType = notification['notificationType'];
      String vehicleId = notification['vehicleId'] ?? 'No vehicle Id';
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FuelOrderNotification(
                        orderId: receivedNotificationId,
                        driver: driverName,
                        driverEmail: driverEmail,
                        notificationType: notificationType,
                        vehicleID: vehicleId,
                      )));
        },
        child: ListTile(
          title: Text(
            notification['notificationType'],
            style: GoogleFonts.lato(color: unreadNotificationColor),
          ),
          subtitle: Text(
            'Driver: ${notification['driverName']}',
            style: GoogleFonts.lato(color: Colors.grey),
          ),
        ),
      );
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.lato(),
          ),
          centerTitle: false,
          bottom: TabBar(
            indicatorColor: Colors.lightBlue,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 15),
            tabs: [
              Tab(
                child: Text(
                  'Notifications',
                  style: GoogleFonts.lato(fontSize: 17.0),
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
            notificationsToDisplay.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: notificationsToDisplay,
                    ),
                  )
                : const Center(
                    child: Text('No notifications to display'),
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
                            final unreadCount = unreadMessageCounts[
                                    _employees[index]['emailAddress']] ??
                                0;

                            return ConversationTile(
                              name:
                                  '${_employees[index]['firstName']} ${_employees[index]['secondName']}',
                              lastMessage: lastMessage,
                              time: time,
                              userId: _employees[index]['emailAddress'],
                              userEmail: _employees[index]['emailAddress'],
                              unreadCount: unreadCount,
                              unreadMessageCounts:
                                  unreadMessageCounts, // Pass the unread count
                              updateUnreadCount: updateUnreadCount,
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
  final int unreadCount;
  final Map<String, int> unreadMessageCounts;
  final Function(String) updateUnreadCount;

  const ConversationTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.userId,
    required this.userEmail,
    this.unreadCount = 0,
    required this.unreadMessageCounts,
    required this.updateUnreadCount,
  });

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .update({'isOnline': isOnline});
  }

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
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  bool isOnline = false;
  late StreamSubscription<DocumentSnapshot> onlineStatusSubscription;

  @override
  void initState() {
    super.initState();
    onlineStatusSubscription =
        widget.listenForOnlineStatus(widget.userId, (bool online) {
      setState(() {
        isOnline = online;
      });
    });
  }

  @override
  void dispose() {
    onlineStatusSubscription.cancel();

    // Reset unread count when the conversation is viewed
    widget.unreadCount > 0
        ? handleViewConversation(widget.userId, widget.unreadMessageCounts)
        : null;

    super.dispose();
  }

  void handleViewConversation(
      String userId, Map<String, int> unreadMessageCounts) {
    // Reset unread count for the user
    if (widget.unreadCount > 0) {
      setState(() {
        unreadMessageCounts.update(userId, (count) => 0);
      });

      widget.updateUnreadCount(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Stack(
              children: [
                Center(
                  child: Text(widget.name[0].toUpperCase(),
                      style: TextStyle(color: Colors.white)),
                ),
                if (widget.unreadCount > 0)
                  Positioned(
                    top: -3,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Text(
                        widget.unreadCount.toString(),
                        style:
                            GoogleFonts.lato(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
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
      title: Text(
        widget.name,
        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              widget.time,
              style: TextStyle(color: Colors.grey),
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
          // You can add additional status indicators here
        ],
      ),
      onTap: () {
        // Handle tapping on a conversation
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(
                      username: widget.name,
                      email: widget.userEmail,
                      updateUnreadCount: widget.updateUnreadCount,
                    )));
      },
    );
  }
}
