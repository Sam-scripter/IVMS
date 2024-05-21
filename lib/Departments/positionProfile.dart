import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PositionProfile extends StatefulWidget {
  final String positionName;
  final String departmentName;

  const PositionProfile({
    Key? key,
    required this.positionName,
    required this.departmentName,
  }) : super(key: key);

  @override
  State<PositionProfile> createState() => _PositionProfileState();
}

class _PositionProfileState extends State<PositionProfile> {
  late List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('department', isEqualTo: widget.departmentName)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.positionName} in ${widget.departmentName}'),
      ),
      body: employees.isNotEmpty
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
                  subtitle: Text(
                    employees[index]['email'] ?? '',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(fontSize: 15.0),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                  'No employees found for this position in this department'),
            ),
    );
  }
}
