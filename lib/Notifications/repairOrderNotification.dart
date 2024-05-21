import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Components/functions.dart';

import '../Components/profileTextBox.dart';

class RepairOrderNotification extends StatefulWidget {
  final String orderId;
  final String vehicleId;

  const RepairOrderNotification({
    super.key,
    required this.orderId,
    required this.vehicleId,
  });

  @override
  State<RepairOrderNotification> createState() =>
      _RepairOrderNotificationState();
}

class _RepairOrderNotificationState extends State<RepairOrderNotification> {
  final repairOrdersCollection =
      FirebaseFirestore.instance.collection('repairOrders');
  String orderType = '';
  String vehicle = '';
  String vehicleId = '';
  String driver = '';
  String description = '';
  String status = '';
  String productCategory = '';
  String categoryProduct = '';
  String selectedCategory = '';
  String selectedItem = '';
  // List<String> categories = [];
  List<String> items = [];
  String currentEmployeeName = '';
  TextEditingController quantityController = TextEditingController();
  String productQuantity = '';
  int fetchedProductNumber = 0;
  String selectedCategoryId = '';
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser?.email;
    DocumentReference documentRef =
        FirebaseFirestore.instance.collection('employees').doc(user);
    DocumentSnapshot snapshot = await documentRef.get();

    if (snapshot.exists) {
      currentEmployeeName =
          '${snapshot['firstName']} ${snapshot['secondName']}';
      setState(() {});
    }
  }

  Future<void> repairOrderDetails() async {
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('repairOrders')
        .doc(widget.orderId);

    DocumentSnapshot documentSnapshot = await documentRef.get();

    if (documentSnapshot.exists) {
      orderType = documentSnapshot['order Type'];
      vehicle = documentSnapshot['vehicle'];
      vehicleId = documentSnapshot['vehicleId'];
      description = documentSnapshot['description'];
      driver = documentSnapshot['driver'];
      status = documentSnapshot['Status'];
      productCategory = documentSnapshot['Category'] ?? '';
      categoryProduct = documentSnapshot['Product'] ?? '';
    }
  }

  Future<void> updateRepairOrder(
      String orderId, String category, String product) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('repairOrders').doc(orderId);

    try {
      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        await documentReference.update({
          'Category': category,
          'Product': product,
        });
      } else {
        print('repairOrder does not exist');
      }
    } catch (e) {
      print('An error occurred while updating the repair order category: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    List<String> categories = []; // Declare categories here
    QuerySnapshot categorySnapshot =
        await FirebaseFirestore.instance.collection('Store').get();
    categories = categorySnapshot.docs.map((doc) => doc.id).toList();
    return categories;
  }

  Future<List<String>> fetchItemsForCategory(String category) async {
    QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
        .collection('Store')
        .doc(category)
        .collection('Products')
        .get();

    items = itemSnapshot.docs.map((doc) => doc.id).toList();
    return items;
  }

  Future<void> fetchProductQuantity(String category, String product) async {
    DocumentReference productDoc = FirebaseFirestore.instance
        .collection('Store')
        .doc(category)
        .collection('Products')
        .doc(product);
    DocumentSnapshot documentSnapshot = await productDoc.get();
    if (documentSnapshot.exists) {
      var value = documentSnapshot.data() as Map<String, dynamic>;
      fetchedProductNumber = value['Number'];
      print('the available product number is: $fetchedProductNumber');
    } else {
      print('error on the function');
    }
  }

  Future<void> updateProductQuantity(
      String category, String product, int number) async {
    await FirebaseFirestore.instance
        .collection('Store')
        .doc(category)
        .collection('Products')
        .doc(product)
        .update({'Number': FieldValue.increment(-number)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.orderId),
          centerTitle: false,
        ),
        body: FutureBuilder(
            future: repairOrderDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text('Loading....'),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileTextBox1(
                            title: 'Order Type', titleValue: orderType),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ProfileTextBox1(title: 'Vehicle', titleValue: vehicle),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ProfileTextBox1(
                            title: 'Vehicle Id', titleValue: vehicleId),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ProfileTextBox(
                            title: 'Description', titleValue: description),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ProfileTextBox(title: 'Driver', titleValue: driver),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ProfileTextBox(title: 'Status', titleValue: status),
                        const SizedBox(
                          height: 15.0,
                        ),
                        status == 'submitted'
                            ? Column(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Store')
                                        .orderBy('timestamp', descending: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      List<DropdownMenuItem<String>>
                                          categories = [];

                                      if (snapshot.hasData) {
                                        // Add a default dropdown menu item
                                        categories.add(
                                          const DropdownMenuItem<String>(
                                            value:
                                                '', // Set the value to null for the default item
                                            child: Text('Select Category'),
                                          ),
                                        );

                                        // Add other categories
                                        for (var doc in snapshot.data!.docs) {
                                          var value = doc.data()
                                              as Map<String, dynamic>;
                                          String categoryName = value['name'];

                                          categories.add(
                                            DropdownMenuItem<String>(
                                              value: categoryName,
                                              child: Text(categoryName),
                                            ),
                                          );
                                        }
                                      }

                                      // Return the DropdownButton with the categories
                                      return DropdownButton(
                                        focusColor: Colors.lightBlueAccent,
                                        dropdownColor: Colors.black87,
                                        hint: const Text('Select a category'),
                                        isExpanded: true,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 7),
                                        items: categories,
                                        value: selectedCategory,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCategory = value!;
                                            int selectedIndex =
                                                categories.indexWhere(
                                              (element) =>
                                                  element.value == value,
                                            );
                                            selectedCategoryId =
                                                selectedIndex >= 0
                                                    ? snapshot
                                                        .data!
                                                        .docs[selectedIndex - 1]
                                                        .id
                                                    : '';
                                            print(
                                                'selectedCategoryId is: $selectedCategoryId');
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  selectedCategoryId.isNotEmpty
                                      ? StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Store')
                                              .doc(selectedCategoryId)
                                              .collection('Products')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            List<DropdownMenuItem<String>>
                                                items = [];
                                            if (snapshot.hasData) {
                                              items.add(
                                                const DropdownMenuItem(
                                                  value: '',
                                                  child:
                                                      Text('Select a product'),
                                                ),
                                              );
                                              for (var item
                                                  in snapshot.data!.docs) {
                                                var value = item.data()
                                                    as Map<String, dynamic>;
                                                String productName =
                                                    value['Product Name'];

                                                items.add(
                                                  DropdownMenuItem(
                                                    value: productName,
                                                    child: Text(productName),
                                                  ),
                                                );
                                              }
                                            }
                                            return DropdownButton<String>(
                                              focusColor:
                                                  Colors.lightBlueAccent,
                                              dropdownColor: Colors.black87,
                                              isExpanded: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 7),
                                              hint:
                                                  const Text('Select Product'),
                                              value:
                                                  selectedValue, // Set the initially selected value
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedValue = newValue!;

                                                  int selectedIndex =
                                                      items.indexWhere(
                                                    (element) =>
                                                        element.value ==
                                                        newValue,
                                                  );
                                                  selectedItem = selectedIndex >=
                                                          0
                                                      ? snapshot
                                                          .data!
                                                          .docs[
                                                              selectedIndex - 1]
                                                          .id
                                                      : '';
                                                  print(
                                                      'selected Product Id is: $selectedItem');
                                                });
                                              },
                                              items: items,
                                            );
                                          },
                                        )
                                      : const Text('Loading....'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 7),
                                    child: TextFormField(
                                      controller: quantityController,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlueAccent),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlueAccent),
                                        ),
                                        labelText: 'Quantity',
                                      ),
                                      onChanged: (quantity) {
                                        setState(() {
                                          productQuantity = quantity;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter the product quantity';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Material(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    elevation: 6.0,
                                    color: Colors.lightBlue,
                                    child: MaterialButton(
                                      onPressed: () async {
                                        await fetchProductQuantity(
                                            selectedCategoryId, selectedItem);
                                        int productNumber =
                                            int.parse(productQuantity);
                                        if (productNumber <=
                                            fetchedProductNumber) {
                                          await updateProductQuantity(
                                              selectedCategoryId,
                                              selectedItem,
                                              productNumber);
                                          await updateRepairOrder(
                                              widget.orderId,
                                              selectedCategory,
                                              selectedValue);
                                          await FirebaseFirestore.instance
                                              .collection('repairOrders')
                                              .doc(widget.orderId)
                                              .update({'Status': 'Approved'});
                                          await getCurrentUser();
                                          await storeApprovedNotification(
                                              'Approved Repair Order',
                                              driver,
                                              widget.orderId,
                                              widget.vehicleId,
                                              currentEmployeeName);
                                          await updateRepairUserUnreadCount();
                                          await updateSuperUserUnreadCount();
                                          await updateRepairUnreadCount();

                                          Navigator.pop(context);
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Error!'),
                                                  content: Text(
                                                      'the quantity assigned exceeds the available quantity'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text('OK'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      minWidth: 310,
                                      height: 42,
                                      child: const Text(
                                        'Approve Order',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Material(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    elevation: 6.0,
                                    color: Colors.lightBlue,
                                    child: MaterialButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('repairOrders')
                                            .doc(widget.orderId)
                                            .update({'Status': 'Declined'});
                                        await getCurrentUser();
                                        await storeDeclinedNotification(
                                            'Declined Repair Order',
                                            driver,
                                            widget.orderId,
                                            widget.vehicleId,
                                            currentEmployeeName);
                                        await updateRepairUserUnreadCount();
                                        await updateSuperUserUnreadCount();
                                        await updateRepairUnreadCount();

                                        Navigator.pop(context);
                                      },
                                      minWidth: 310,
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
                                ? Column(
                                    children: [
                                      ProfileTextBox1(
                                          title: 'Category',
                                          titleValue: productCategory),
                                      const SizedBox(height: 20),
                                      ProfileTextBox(
                                          title: 'Product',
                                          titleValue: categoryProduct),
                                      const SizedBox(height: 20),
                                      Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(30.0),
                                        ),
                                        elevation: 6.0,
                                        color: Colors.lightBlue,
                                        child: MaterialButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('repairOrders')
                                                .doc(widget.orderId)
                                                .update(
                                                    {'Status': 'Completed'});
                                            await getCurrentUser();
                                            await storeCompletedNotification(
                                                'Completed Repair Order',
                                                driver,
                                                widget.orderId,
                                                widget.vehicleId,
                                                currentEmployeeName);
                                            await updateRepairUserUnreadCount();
                                            await updateSuperUserUnreadCount();
                                            await updateRepairUnreadCount();

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
                                    ],
                                  )
                                : Column(
                                    children: [
                                      ProfileTextBox1(
                                          title: 'Category',
                                          titleValue: productCategory),
                                      const SizedBox(height: 20),
                                      ProfileTextBox1(
                                          title: 'Product',
                                          titleValue: categoryProduct),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                      ],
                    ),
                  ),
                );
              }
              return const Center(
                child: Text('Loading....'),
              );
            }));
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}
