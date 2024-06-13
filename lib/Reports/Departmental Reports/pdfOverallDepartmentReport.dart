import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class OverallDepartmentReportService {
  Future<Uint8List> generateOverallDepartmentsReport() async {
    final pdf = pw.Document();

    final departments = await _fetchDepartments();

    for (var department in departments) {
      final departmentPage = _buildDepartmentPage(department);
      pdf.addPage(pw.Page(build: (pw.Context context) => departmentPage));
    }

    return pdf.save();
  }

  pw.Widget _buildDepartmentPage(Map<String, dynamic> departmentData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${departmentData['name']} Department Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Number of Employees: ${departmentData['numEmployees']}',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Number of Vehicles: ${departmentData['numVehicles']}',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Number of Positions: ${departmentData['numPositions']}',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Amount of Fuel Consumed: ${departmentData['fuelConsumed']}',
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Number of Repairs: ${departmentData['numRepairs']}',
            style: pw.TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDepartments() async {
    List<Map<String, dynamic>> departments = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('departments').get();

    for (var document in querySnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      var departmentInfo = {
        'name': data['name'],
        'numEmployees': await _getNumberOfEmployees(data['name']),
        'numVehicles': await _getNumberOfVehicles(data['name']),
        'numPositions': await _getNumberOfPositions(data['name']),
        'fuelConsumed': await _getFuelConsumed(data['name']),
        'numRepairs': await _getNumberOfRepairs(data['name']),
      };

      departments.add(departmentInfo);
    }

    return departments;
  }

  Future<int> _getNumberOfEmployees(String department) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('department', isEqualTo: department)
        .get();
    return querySnapshot.size;
  }

  Future<int> _getNumberOfVehicles(String department) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('department', isEqualTo: department)
        .get();
    return querySnapshot.size;
  }

  Future<int> _getNumberOfPositions(String department) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('positions')
        .where('department', isEqualTo: department)
        .get();
    return querySnapshot.size;
  }

  Future<String> _getFuelConsumed(String department) async {
    // Replace with your logic to calculate fuel consumed
    return '12345 gallons';
  }

  Future<int> _getNumberOfRepairs(String department) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('repairs')
        .where('department', isEqualTo: department)
        .get();
    return querySnapshot.size;
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    // Open the PDF file on completion
    await OpenFile.open(filePath);

    // Get a reference to Firebase Storage
    final storageRef =
        FirebaseStorage.instance.ref().child('reports/$fileName.pdf');

    // Upload the PDF file
    final uploadTask = storageRef.putData(byteList);

    // Wait for the upload to complete
    final snapshot = await uploadTask.whenComplete(() => null);

    // Get the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Save the download URL to Firestore
    await FirebaseFirestore.instance.collection('reports').add({
      'fileName': fileName,
      'url': downloadUrl,
      'createdAt': Timestamp.now(),
    });
  }
}
