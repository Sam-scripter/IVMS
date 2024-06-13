import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleReportService {
  Future<Uint8List> generateVehicleReport() async {
    final pdf = pw.Document();

    // Add a cover page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            'Vehicle Report',
            style: pw.TextStyle(
              fontSize: 40,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
        ),
      ),
    );

    final vehicles = await _fetchVehicles();

    for (var vehicle in vehicles) {
      final vehiclePage = _buildVehiclePage(vehicle);
      pdf.addPage(pw.Page(build: (pw.Context context) => vehiclePage));
    }

    return pdf.save();
  }

  pw.Widget _buildVehiclePage(Map<String, dynamic> vehicleData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Vehicle Report - ${vehicleData['licensePlateNumber']}',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Department: ${vehicleData['department']}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Driver: ${vehicleData['driver']}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Fuel Consumption: ${vehicleData['fuelConsumption']}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Number of Repairs: ${vehicleData['numRepairs']}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Amount of Fuel Consumed: ${vehicleData['fuelConsumed']}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
        ],
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.grey200,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchVehicles() async {
    List<Map<String, dynamic>> vehicles = [];

    QuerySnapshot vehicleSnapshot =
        await FirebaseFirestore.instance.collection('vehicles').get();

    for (var document in vehicleSnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      var vehicleInfo = {
        'licensePlateNumber': data['licensePlateNumber'],
        'department': data['department'],
        'driver': data['driver'],
        'fuelConsumption': data['fuelConsumption'],
        'numRepairs': await _getNumberOfRepairs(data['licensePlateNumber']),
        'fuelConsumed': await _getTotalFuelConsumed(data['licensePlateNumber']),
      };

      vehicles.add(vehicleInfo);
    }

    return vehicles;
  }

  Future<int> _getNumberOfRepairs(String licensePlateNumber) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('repairOrders')
        .where('vehicle', isEqualTo: licensePlateNumber)
        .get();
    return querySnapshot.size;
  }

  Future<double> _getTotalFuelConsumed(String licensePlateNumber) async {
    double totalFuelConsumed = 0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fuel Orders')
        .where('Vehicle', isEqualTo: licensePlateNumber)
        .get();

    for (var document in querySnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      totalFuelConsumed += data['Litres Required'];
    }

    return totalFuelConsumed;
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
