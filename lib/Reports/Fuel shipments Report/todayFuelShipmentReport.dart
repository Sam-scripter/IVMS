import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class TodayFuelShipmentReportService {
  Future<Uint8List> generateTodayFuelShipmentReport() async {
    final pdf = pw.Document();
    final today = DateTime.now();
    final shipment = await _fetchTodayFuelShipment();

    if (shipment == null) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                'No shipments made today',
                style: pw.TextStyle(
                  fontSize: 24,
                  color: PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          },
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Fuel Shipments Report',
                    style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Generated on: ${today.toLocal().toString().split(' ')[0]}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Fuel Shipment Details',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Invoice No.',
                  'Supplier',
                  'Diesel Quantity',
                  'Petrol Quantity',
                  'Unallocated Diesel',
                  'Unallocated Petrol',
                  'Total Fuel Litres',
                  'Total Money',
                  'Stations',
                ],
                data: [
                  [
                    shipment['invoiceNumber'],
                    shipment['supplier'],
                    shipment['dieselQuantity'].toString(),
                    shipment['petrolQuantity'].toString(),
                    shipment['unallocatedDiesel'].toString(),
                    shipment['unallocatedPetrol'].toString(),
                    shipment['totalFuelLitres'].toString(),
                    shipment['totalMoney'].toString(),
                    shipment['stations'].map((station) {
                      return '${station['station']}: Diesel: ${station['addedDiesel']}L, Petrol: ${station['addedPetrol']}L';
                    }).join('\n'),
                  ],
                ],
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                ),
                cellStyle: pw.TextStyle(
                  fontSize: 10,
                ),
                cellHeight: 40,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                  8: pw.Alignment.topLeft,
                },
              ),
            ];
          },
        ),
      );
    }

    return pdf.save();
  }

  Future<Map<String, dynamic>?> _fetchTodayFuelShipment() async {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime endOfDay =
        DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fuel Shipments')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    var document = querySnapshot.docs.first;
    var data = document.data() as Map<String, dynamic>;
    var stationsSnapshot =
        await document.reference.collection('stations').get();
    var stations = stationsSnapshot.docs.map((stationDoc) {
      return stationDoc.data() as Map<String, dynamic>;
    }).toList();

    return {
      'invoiceNumber': data['invoiceNumber'],
      'supplier': data['supplier'],
      'dieselQuantity': data['dieselQuantity'],
      'petrolQuantity': data['petrolQuantity'],
      'unallocatedDiesel': data['unallocatedDiesel'],
      'unallocatedPetrol': data['unallocatedPetrol'],
      'totalFuelLitres': data['totalFuelLitres'],
      'totalMoney': data['totalMoney'],
      'stations': stations,
    };
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
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
