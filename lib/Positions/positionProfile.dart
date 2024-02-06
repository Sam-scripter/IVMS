import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PositionProfile extends StatefulWidget {
  final String positionName;
  const PositionProfile({super.key, required this.positionName});

  @override
  State<PositionProfile> createState() => _PositionProfileState();
}

class _PositionProfileState extends State<PositionProfile> {
  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('position', isEqualTo: widget.positionName)
          .get();

      employees = querySnapshot.docs.map((DocumentSnapshot document) {
        return document.data() as Map<String, dynamic>;
      }).toList();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  late List<Map<String, dynamic>> employees = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.positionName,
          style: GoogleFonts.lato(),
        ),
        centerTitle: false,
      ),
      body: employees.isNotEmpty
          ? ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    '${employees[index]['firstName']} ${employees[index]['secondName']}',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                );
              })
          : const Center(
              child: Text('No Employees Found for this position'),
            ),
    );
  }
}
