import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:integrated_vehicle_management_system/Fuel%20Orders/fuelOrders.dart';
import 'package:integrated_vehicle_management_system/Fuel%20shipments/fuelShipments.dart';
import 'package:integrated_vehicle_management_system/Notifications/notifications_page.dart';
import 'package:integrated_vehicle_management_system/Repair%20Orders/repairOrders.dart';
import 'package:integrated_vehicle_management_system/Store/storeHome.dart';
import 'package:integrated_vehicle_management_system/api/firebase_api.dart';
import 'package:integrated_vehicle_management_system/providers/driverNameProvider.dart';
import 'package:integrated_vehicle_management_system/providers/orderTypeProvider.dart';
import 'package:provider/provider.dart';
import 'Screens/homeScreen.dart';
import 'Screens/splashScreen.dart';
import 'Screens/EmployeeRegLogin/registration.dart';
import 'Screens/EmployeeRegLogin/login.dart';
import 'Screens/EmployeeRegLogin/passwordReset.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/Profiles/userProfile.dart';
import 'Departments/departments.dart';
import 'Employees/employee_list.dart';
import 'Positions/positions.dart';
import 'Vehicles/addVehicle.dart';
import 'Vehicles/vehicles.dart';
import 'Fuel Stations/fuelStations.dart';

final navigatorkey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => OrderTypeProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => DriverNameProvider(),
    ),
  ], child: const System()));
}

class System extends StatelessWidget {
  const System({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Color(0xFF0A0D22),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0D22),
      ),
      home: const SplashScreen(),
      navigatorKey: navigatorkey,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/notifications': (context) => NotificationsPage(),
        '/home': (context) => const HomeScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/passwordReset': (context) => PasswordReset(),
        '/profile': (context) => UserProfile(),
        '/departments': (context) => const Departments(),
        '/employees': (context) => const Employees(),
        '/positions': (context) => const Positions(),
        '/addVehicle': (context) => RegisterVehicle(),
        '/vehicles': (context) => Vehicles(),
        '/fuelStations': (context) => const FuelStations(),
        '/fuelOrders': (context) => const FuelOrders(),
        '/repairOrders': (context) => const RepairOrders(),
        '/fuelShipments': (context) => const FuelShipments(),
        '/store': (context) => const StoreHome(),
      },
    );
  }
}
