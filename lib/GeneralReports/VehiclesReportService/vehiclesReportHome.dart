import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Reports/Vehicle%20Reports/vehiclesReportService.dart';

class VehicleReportsHome extends StatefulWidget {
  VehicleReportsHome({super.key});

  @override
  _VehicleReportsHomeState createState() => _VehicleReportsHomeState();
}

class _VehicleReportsHomeState extends State<VehicleReportsHome> {
  final VehicleReportService vehicleReportService = VehicleReportService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Reports Home'),
      ),
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildReportCard(
            context,
            'Overall fuel orders Report',
            Icons.local_shipping,
            Color(0xFF111328),
            () async {
              setState(() {
                _isLoading = true;
              });
              try {
                final data = await vehicleReportService.generateVehicleReport();
                await vehicleReportService.savePdfFile(
                    'IVMS vehicles report', data);
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ]),
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
