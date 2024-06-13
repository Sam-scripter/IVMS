import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Reports/Fuel%20Order%20Reports/fuelOrderReportService.dart';
import 'package:integrated_vehicle_management_system/Reports/Fuel%20Order%20Reports/todayFuelOrderReport.dart';

class FuelOrderReportsHome extends StatelessWidget {
  FuelOrderReportsHome({super.key});

  final FuelOrderReportService fuelOrderReportService =
      FuelOrderReportService();
  final TodayFuelOrderReportService todayFuelOrderReportService =
      TodayFuelOrderReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FuelOrderReports'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _buildReportCard(
          context,
          'Overall fuel orders Report',
          Icons.book,
          Color(0xFF111328),
          () async {
            final data =
                await fuelOrderReportService.generateFuelOrdersReport();
            fuelOrderReportService.savePdfFile('IVMS Fuel orders report', data);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final data =
              await todayFuelOrderReportService.generateTodayFuelOrdersReport();
          fuelOrderReportService.savePdfFile(
              'IVMS Today Fuel order report', data);
        },
        label: const Text('Generate Report'),
        icon: const Icon(Icons.file_copy),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildReportCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
