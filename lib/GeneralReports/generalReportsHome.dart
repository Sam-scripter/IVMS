import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/GeneralReports/DepartmentsReportService/departmentReports.dart';
import 'package:integrated_vehicle_management_system/GeneralReports/FuelOrdersReportService/fuelOrderReportsHome.dart';
import 'package:integrated_vehicle_management_system/GeneralReports/FuelShipmentReportService/fuelShipmentReportsHome.dart';
import 'package:integrated_vehicle_management_system/GeneralReports/RepairOrdersReportService/repairOrderReportsHome.dart';
import 'package:integrated_vehicle_management_system/GeneralReports/VehiclesReportService/vehiclesReportHome.dart';

class GeneralReportsHome extends StatelessWidget {
  const GeneralReportsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'General Reports',
          style: GoogleFonts.lato(
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReportCard(
              context,
              'Department Reports',
              Icons.account_balance,
              Color(0xFF111328),
              () {
                // Navigate to Department Reports
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Department()));
              },
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              'Fuel Order Reports',
              Icons.local_gas_station,
              Color(0xFF111328),
              () {
                // Navigate to Fuel Order Reports
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FuelOrderReportsHome()));
              },
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              'Repair Order Reports',
              Icons.build,
              Color(0xFF111328),
              () {
                // Navigate to Repair Order Reports
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RepairOrderReportsHome()));
              },
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              'Vehicle Reports',
              Icons.directions_car,
              Color(0xFF111328),
              () {
                // Navigate to Vehicle Reports
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleReportsHome()));
              },
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              'Fuel Shipment Reports',
              Icons.local_shipping,
              Color(0xFF111328),
              () {
                // Navigate to Fuel Shipment Reports
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FuelShipmentReportsHome()));
              },
            ),
          ],
        ),
      ),
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
