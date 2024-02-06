import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:integrated_vehicle_management_system/Components/cardContents.dart';
import 'package:integrated_vehicle_management_system/Components/reusableCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_vehicle_management_system/Screens/EmployeeRegLogin/login.dart';
import 'package:integrated_vehicle_management_system/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  final _auth = FirebaseAuth.instance;
  String userRole = '';
  String userPosition = '';

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(user.email)
          .get();

      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        String role = userData['role'];
        String position = userData['position'];

        setState(() {
          userRole = role;
          userPosition = position;
          superUserCards = buildSuperUserCards();
          transportManagerCards = buildTransportManagerCards();
          repairManagerCards = buildRepairManagerCards();
          fuelAttendantCards = buildFuelAttendantCards();
          driverCards = buildDriverCards();
        });
      }
    }
  }

  List<Widget> buildSuperUserCards() {
    return [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/departments');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.account_tree_outlined,
            label: 'Departments',
            colour: Colors.blue,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/employees');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.people_alt_outlined,
            label: 'Employees',
            colour: Colors.redAccent,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/vehicles');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.car_rental,
            label: 'Vehicles',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/positions');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.article_outlined,
            colour: Colors.purpleAccent,
            label: 'Positions',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelStations'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter,
            label: 'Fuel Stations',
            colour: Colors.yellow,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter,
            label: 'Fuel Orders',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/repairOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Repair Orders',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelShipments'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Fuel Shipments',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Store',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Fuel Reports',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Repair Reports',
          ),
        ),
      ),
    ];
  }

  List<Widget> buildTransportManagerCards() {
    return [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/departments');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.account_tree_outlined,
            label: 'Departments',
            colour: Colors.blue,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/vehicles');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.car_rental,
            label: 'Vehicles',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelStations'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter,
            label: 'Fuel Stations',
            colour: Colors.yellow,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter,
            label: 'Fuel Orders',
          ),
        ),
      ),
      ReusableCard(
        colour: const Color(0xFF111328),
        cardChild: CardContents(
          icon: Icons.ac_unit,
          label: 'Fuel Shipments',
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Fuel Reports',
          ),
        ),
      ),
    ];
  }

  List<Widget> buildRepairManagerCards() {
    return [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/departments');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.account_tree_outlined,
            label: 'Departments',
            colour: Colors.blue,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/vehicles');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.car_rental,
            label: 'Vehicles',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/repairOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Repair Orders',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Store',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Repair Reports',
          ),
        ),
      ),
    ];
  }

  List<Widget> buildFuelAttendantCards() {
    return [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/departments');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.account_tree_outlined,
            label: 'Departments',
            colour: Colors.blue,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/vehicles');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.car_rental,
            label: 'Vehicles',
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter,
            label: 'Fuel Orders',
          ),
        ),
      ),
    ];
  }

  List<Widget> buildDriverCards() {
    return [
      ReusableCard(
        colour: const Color(0xFF111328),
        cardChild: CardContents(
          icon: Icons.gas_meter,
          label: 'Fuel Orders',
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/repairOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.ac_unit,
            label: 'Repair Orders',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Fuel Reports',
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          null;
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.group_add,
            label: 'Repair Reports',
          ),
        ),
      ),
    ];
  }

  List<Widget> superUserCards = [];
  List<Widget> transportManagerCards = [];
  List<Widget> repairManagerCards = [];
  List<Widget> fuelAttendantCards = [];
  List<Widget> driverCards = [];

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .update({'isOnline': isOnline});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cardsToDisplay = [];

    if (userRole == 'SuperUser') {
      cardsToDisplay = superUserCards;
    } else if (userRole == 'Admin') {
      if (userPosition == 'TransportManager') {
        cardsToDisplay = transportManagerCards;
      } else if (userPosition == 'Repair Manager') {
        cardsToDisplay = repairManagerCards;
      }
    } else if (userRole == 'User') {
      if (userPosition == 'Fuel Attendant') {
        cardsToDisplay = fuelAttendantCards;
      } else if (userPosition == 'Driver') {
        cardsToDisplay = driverCards;
      }
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        title: const Text(
          'Dashboard',
          // textAlign: TextAlign.center,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 13.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: const CircleAvatar(
              radius: 12.0,
              backgroundColor: Colors.black,
              backgroundImage: null,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          const IconButton(
            onPressed: null,
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              navigatorkey.currentState?.pushNamed('/notifications');
            },
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {
              final userId = _auth.currentUser?.uid;
              if (userId != null) {
                const bool isOnline = true;
                updateOnlineStatus(userId, !isOnline);
                _auth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              } else {
                print('UserId is null, here is the error');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: [
        GridView.count(
          crossAxisCount: 2,
          children: cardsToDisplay,
        ),
        Container(
          alignment: Alignment.center,
          child: const Text('Reports'),
        ),
        Container(
          alignment: Alignment.center,
          child: const Text('Settings'),
        ),
      ][currentPageIndex],
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({super.key});

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final currentUser = FirebaseAuth.instance.currentUser!;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0D22),
      width: 257.0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(context),
            buildMenu(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Material(
        color: const Color(0xFF1D1E33),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, bottom: 24.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 52.0,
                  backgroundImage: null,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('employees')
                        .doc(userEmail)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Text(
                          "${userData['firstName'] ?? 'N/A'} ${userData['secondName'] ?? "N/A"} ",
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.white70),
                        );
                      }
                      return const Center(
                        child: Text('Error: Error is here'),
                      );
                    }),
                Text(
                  userEmail!,
                  style: TextStyle(fontSize: 16.0, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
  Widget buildMenu(BuildContext context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Wrap(
          runSpacing: 16.0,
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('Profile'),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Reports'),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('Theme'),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              onTap: null,
            ),
            Divider(
              height: 8.0,
              thickness: 10.0,
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text('Log Out'),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
            )
          ],
        ),
      );
}

// scaffoldcolor = 0xFF0A0D22
//reusablecardcolor = 0xFF1D1E33
