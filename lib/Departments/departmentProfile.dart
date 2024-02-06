import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentProfile extends StatefulWidget {
  final String departmentName;
  const DepartmentProfile({super.key, required this.departmentName});

  @override
  State<DepartmentProfile> createState() => _DepartmentProfileState();
}

class _DepartmentProfileState extends State<DepartmentProfile> {
  late List<Map<String, dynamic>> employees = [];
  late List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchVehicles();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
      ),
    );
  }
}
