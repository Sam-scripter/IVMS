import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateFuelUserUnreadCount() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('role', isEqualTo: 'User')
      .where('position', whereIn: ['Driver', 'Fuel Attendant']).get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('unreadCount')) {
      // Get the current unread count
      int currentCount = data['unreadCount'];

      // Increment the 'unreadCount' field by 1
      int newCount = currentCount + 1;

      // Update the document with the new 'unreadCount' value
      await doc.reference.update({'unreadCount': newCount});
    } else {
      // If the 'unreadCount' field doesn't exist, add it to the document
      await doc.reference.set({'unreadCount': 1}, SetOptions(merge: true));
    }
  }
}

Future<void> updateRepairUserUnreadCount() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('role', isEqualTo: 'User')
      .where('position', whereIn: ['Driver', 'Mechanic']).get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('unreadCount')) {
      // Get the current unread count
      int currentCount = data['unreadCount'];

      // Increment the 'unreadCount' field by 1
      int newCount = currentCount + 1;

      // Update the document with the new 'unreadCount' value
      await doc.reference.update({'unreadCount': newCount});
    } else {
      // If the 'unreadCount' field doesn't exist, add it to the document
      await doc.reference.set({'unreadCount': 1}, SetOptions(merge: true));
    }
  }
}

Future<void> updateSuperUserUnreadCount() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('role', isEqualTo: 'SuperUser')
      .get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('unreadCount')) {
      // Get the current unread count
      int currentCount = data['unreadCount'];

      // Increment the 'unreadCount' field by 1
      int newCount = currentCount + 1;

      // Update the document with the new 'unreadCount' value
      await doc.reference.update({'unreadCount': newCount});
    } else {
      // If the 'unreadCount' field doesn't exist, add it to the document
      await doc.reference.set({'unreadCount': 1}, SetOptions(merge: true));
    }
  }
}

Future<void> updateTransportUnreadCount() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('role', isNotEqualTo: 'SuperUser')
      .where('position', isEqualTo: 'Transport Manager')
      .get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('unreadCount')) {
      // Get the current unread count
      int currentCount = data['unreadCount'];

      // Increment the 'unreadCount' field by 1
      int newCount = currentCount + 1;

      // Update the document with the new 'unreadCount' value
      await doc.reference.update({'unreadCount': newCount});
    } else {
      // If the 'unreadCount' field doesn't exist, add it to the document
      await doc.reference.set({'unreadCount': 1}, SetOptions(merge: true));
    }
  }
}

Future<void> updateRepairUnreadCount() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('role', isNotEqualTo: 'SuperUser')
      .where('position', isEqualTo: 'Repair Manager')
      .get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('unreadCount')) {
      // Get the current unread count
      int currentCount = data['unreadCount'];

      // Increment the 'unreadCount' field by 1
      int newCount = currentCount + 1;

      // Update the document with the new 'unreadCount' value
      await doc.reference.update({'unreadCount': newCount});
    } else {
      // If the 'unreadCount' field doesn't exist, add it to the document
      await doc.reference.set({'unreadCount': 1}, SetOptions(merge: true));
    }
  }
}

Future<void> resetUnreadCount() async {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  if (currentUserEmail != null) {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('employees')
        .doc(currentUserEmail);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      int currentCount = documentSnapshot.get('unreadCount') ?? 0;
      int newCount = currentCount - 1;
      await documentReference.update({'unreadCount': newCount});
    }
  }
}

Future<void> storeApprovedNotification(String notificationType, String userName,
    String orderId, String vehicleId, String approvedBy) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentReference notificationRef =
        await FirebaseFirestore.instance.collection('notifications').add({
      'userEmail': user.email,
      'employeeName': userName,
      'notificationType': notificationType,
      'orderId': orderId,
      'vehicleId': vehicleId,
      'approvedBy': approvedBy,
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

Future<void> storeCompletedNotification(
    String notificationType,
    String userName,
    String orderId,
    String vehicleId,
    String completedBy) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentReference notificationRef =
        await FirebaseFirestore.instance.collection('notifications').add({
      'userEmail': user.email,
      'employeeName': userName,
      'notificationType': notificationType,
      'orderId': orderId,
      'vehicleId': vehicleId,
      'completedBy': completedBy,
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

Future<void> storeDeclinedNotification(String notificationType, String userName,
    String orderId, String vehicleId, String declinedBy) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentReference notificationRef =
        await FirebaseFirestore.instance.collection('notifications').add({
      'userEmail': user.email,
      'employeeName': userName,
      'notificationType': notificationType,
      'orderId': orderId,
      'vehicleId': vehicleId,
      'declinedBy': declinedBy,
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
