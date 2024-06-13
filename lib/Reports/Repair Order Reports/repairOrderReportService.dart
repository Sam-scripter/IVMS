import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class RepairOrderReportService {
  Future<Uint8List> generateRepairOrdersReport() async {
    final pdf = pw.Document();
    final today = DateTime.now();
    final repairOrders = await _fetchRepairOrders();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Repair Orders Report',
                  style: pw.TextStyle(
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on: ${today.toLocal().toString().split(' ')[0]}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),
                if (repairOrders.isEmpty)
                  pw.Text(
                    'No repair orders found',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  )
                else
                  for (var order in repairOrders) _buildRepairOrder(order),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildRepairOrder(Map<String, dynamic> orderData) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueAccent, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.grey200,
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
          pw.Text('Category: ${orderData['category']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Product: ${orderData['product']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Description: ${orderData['description']}',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 5),
          pw.Text('Status: ${orderData['status']}',
              style: pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRepairOrders() async {
    List<Map<String, dynamic>> repairOrders = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('repairOrders').get();

    for (var document in querySnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      var orderInfo = {
        'timestamp': (data['timestamp'] as Timestamp).toDate().toString(),
        'driver': data['driver'],
        'vehicle': data['vehicle'],
        'category': data['category'],
        'product': data['product'],
        'description': data['description'],
        'status': data['status'],
      };

      repairOrders.add(orderInfo);
    }

    return repairOrders;
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
