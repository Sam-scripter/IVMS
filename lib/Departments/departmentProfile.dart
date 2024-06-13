import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrated_vehicle_management_system/Departments/positionProfile.dart';
import 'package:integrated_vehicle_management_system/Reports/Departmental%20Reports/pdfDepartmentReport.dart';

class DepartmentProfile extends StatefulWidget {
  final String departmentName;
  final String departmentId;
  const DepartmentProfile(
      {Key? key, required this.departmentName, required this.departmentId})
      : super(key: key);

  @override
  State<DepartmentProfile> createState() => _DepartmentProfileState();
}

class _DepartmentProfileState extends State<DepartmentProfile> {
  late List<Map<String, dynamic>> employees = [];
  late List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> positions = [];
  String userName = '';
  final DepartmentPdfService departmentPdfService = DepartmentPdfService();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchVehicles();
    _fetchPositions();
    _getCurrentUser();
  }

  Future<void> _fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('department', isEqualTo: widget.departmentName)
          .get();

      employees = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addPosition(String positionName) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('departments')
          .doc(widget.departmentId)
          .collection('positions')
          .where('name', isEqualTo: positionName)
          .get();

      final List<DocumentSnapshot> documents = result.docs;

      if (documents.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Position Already Exists'),
              content: Text('The position "$positionName" already exists.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        await FirebaseFirestore.instance
            .collection('departments')
            .doc(widget.departmentId)
            .collection('positions')
            .add({
          'name': positionName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Optionally fetch positions again after adding
        _fetchPositions();
      }
    } catch (e) {
      print(e);
    }
  }

  void _showAddPositionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPositionName = '';

        return AlertDialog(
          title: Text(
            'Add New Position',
            style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            onChanged: (value) {
              newPositionName = value;
            },
            decoration: const InputDecoration(hintText: "Position Name"),
          ),
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor:
                    Colors.blue.withOpacity(0.1), // button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (newPositionName.isNotEmpty) {
                  _addPosition(newPositionName);
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor:
                    Colors.blue.withOpacity(0.1), // button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.lato(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchPositions() async {
    try {
      // Fetch the department document
      QuerySnapshot departmentSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .where('name', isEqualTo: widget.departmentName)
          .get();

      // Ensure the department exists
      if (departmentSnapshot.docs.isNotEmpty) {
        // Get the first document (assuming department names are unique)
        DocumentSnapshot departmentDocument = departmentSnapshot.docs.first;

        // Fetch the positions subcollection
        QuerySnapshot positionsSnapshot =
            await departmentDocument.reference.collection('positions').get();

        // Extract the positions data
        List<Map<String, dynamic>> positions =
            positionsSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();

        // Do something with the positions data, like updating the state
        setState(() {
          // Assuming you have a positions variable in your state
          this.positions = positions;
        });
      } else {
        print('Department not found');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('department', isEqualTo: widget.departmentName)
          .get();

      vehicles = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser?.email;
    if (user != null) {
      DocumentReference document =
          FirebaseFirestore.instance.collection('employees').doc(user);
      DocumentSnapshot snapshot = await document.get();
      if (snapshot.exists) {
        var value = snapshot.data() as Map<String, dynamic>;

        setState(() {
          userName = '${value['firstName']} ${value['secondName']}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated to 3 since you have 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.departmentName),
          centerTitle: false,
          bottom: TabBar(
            indicatorColor: Colors.lightBlue,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 15.0),
            tabs: [
              Tab(
                child: Text(
                  "Positions",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(fontSize: 17.0),
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Employees",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(fontSize: 17.0),
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Vehicles',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(fontSize: 17.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Stack(
              children: [
                positions.isNotEmpty
                    ? ListView.builder(
                        itemCount: positions.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PositionProfile(
                                        positionName:
                                            '${positions[index]['name']}',
                                        departmentName:
                                            widget.departmentName))),
                            child: ListTile(
                              title: Text(
                                '${positions[index]['name']}' ?? '',
                                style: GoogleFonts.lato(
                                    textStyle: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        })
                    : const Center(
                        child: Text('No positions found for this department'),
                      ),
                Positioned(
                  bottom: 76.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: _showAddPositionDialog,
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
            employees.isNotEmpty
                ? ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${employees[index]['firstName']} ${employees[index]['secondName']}' ??
                              '',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      );
                    })
                : const Center(
                    child: Text('No employees found for this department'),
                  ),
            vehicles.isNotEmpty
                ? ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          vehicles[index]['licensePlateNumber'] ?? '',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      );
                    })
                : const Center(
                    child: Text('No vehicles found for this department'),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _getCurrentUser();
            final data = await departmentPdfService.generateDepartmentPdf(
                userName, widget.departmentName);
            departmentPdfService.savePdfFile('IVMS PDF', data);
          },
          label: const Text('Generate Report'),
          icon: const Icon(Icons.file_copy),
          backgroundColor: Colors.lightBlue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
