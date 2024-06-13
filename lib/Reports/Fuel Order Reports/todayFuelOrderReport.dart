import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class TodayFuelOrderReportService {
  Future<Uint8List> generateTodayFuelOrdersReport() async {
    final pdf = pw.Document();
    final today = DateTime.now();
    final fuelOrders = await _fetchFuelOrders(today);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fuel Orders Report - ${today.toLocal().toString().split(' ')[0]}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 20),
                if (fuelOrders.isEmpty)
                  pw.Text(
                    'No orders made today',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  )
                else
                  for (var order in fuelOrders) _buildFuelOrder(order),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildFuelOrder(Map<String, dynamic> orderData) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueAccent, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.grey300,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Timestamp: ${orderData['timestamp']}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Driver: ${orderData['driver']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Vehicle: ${orderData['vehicle']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Source: ${orderData['source']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Purpose: ${orderData['purpose']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Destination: ${orderData['destination']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Fuel Type: ${orderData['fuelType']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Kilometers: ${orderData['kilometers']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Fuel Allocated: ${orderData['fuelAllocated']} liters',
              style: pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFuelOrders(DateTime date) async {
    List<Map<String, dynamic>> fuelOrders = [];
    Timestamp startOfDay =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    Timestamp endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fuel Orders')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .get();

    for (var document in querySnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      var orderInfo = {
        'timestamp': (data['timestamp'] as Timestamp).toDate().toString(),
        'driver': data['Driver'],
        'vehicle': data['Vehicle'],
        'source': data['Origin'],
        'destination': data['Destination'],
        'kilometers': data['distance'],
        'fuelAllocated': data['Litres Required'],
        'purpose': data['Purpose'],
        'fuelType': data['Fuel Type'],
      };

      fuelOrders.add(orderInfo);
    }

    return fuelOrders;
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
