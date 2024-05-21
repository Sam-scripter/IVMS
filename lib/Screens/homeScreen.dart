import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:integrated_vehicle_management_system/Components/cardContents.dart';
import 'package:integrated_vehicle_management_system/Components/reusableCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integrated_vehicle_management_system/Screens/EmployeeRegLogin/login.dart';
import 'package:integrated_vehicle_management_system/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> updateOnlineStatus(String userId, bool isOnline) async {
  await FirebaseFirestore.instance
      .collection('employees')
      .doc(userId)
      .update({'isOnline': isOnline});
}

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

  Stream<int> _unreadCountStream() async* {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final documentReference = FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUserEmail);

      yield* documentReference.snapshots().map<int>((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          return data['unreadCount'] ?? 0;
        } else {
          return 0;
        }
      });
    } else {
      yield 0;
    }
  }

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
            icon: FontAwesomeIcons.car,
            label: 'Vehicles',
            colour: Colors.cyan,
          ),
        ),
      ),
      // GestureDetector(
      //   onTap: () {
      //     Navigator.pushNamed(context, '/positions');
      //   },
      //   child: ReusableCard(
      //     colour: const Color(0xFF111328),
      //     cardChild: CardContents(
      //       icon: Icons.article_outlined,
      //       colour: Colors.purpleAccent,
      //       label: 'Positions',
      //     ),
      //   ),
      // ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelStations'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: FontAwesomeIcons.gasPump,
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
            colour: Colors.deepOrangeAccent,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/repairOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: FontAwesomeIcons.toolbox,
            label: 'Repair Orders',
            colour: Colors.indigo,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelShipments'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter_sharp,
            label: 'Fuel Shipments',
            colour: Colors.red,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/store');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.store,
            label: 'Store',
            colour: Colors.brown,
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
            icon: Icons.report,
            label: 'Fuel Reports',
            colour: Colors.blueGrey,
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
            icon: FontAwesomeIcons.bookBookmark,
            label: 'Repair Reports',
            colour: Colors.deepPurple,
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
            icon: Icons.book,
            label: 'General Reports',
            colour: Colors.teal,
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
            icon: FontAwesomeIcons.car,
            label: 'Vehicles',
            colour: Colors.cyan,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/fuelStations'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: FontAwesomeIcons.gasPump,
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
        onTap: () => Navigator.pushNamed(context, '/fuelShipments'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.gas_meter_sharp,
            label: 'Fuel Shipments',
            colour: Colors.red,
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
            icon: Icons.report,
            label: 'Fuel Reports',
            colour: Colors.blueGrey,
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
            icon: FontAwesomeIcons.car,
            label: 'Vehicles',
            colour: Colors.cyan,
          ),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/repairOrders'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: FontAwesomeIcons.toolbox,
            label: 'Repair Orders',
            colour: Colors.indigo,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/store');
        },
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: Icons.store,
            label: 'Store',
            colour: Colors.brown,
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
            icon: FontAwesomeIcons.bookBookmark,
            label: 'Repair Reports',
            colour: Colors.deepPurple,
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
            icon: FontAwesomeIcons.car,
            label: 'Vehicles',
            colour: Colors.cyan,
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
        onTap: () => Navigator.pushNamed(context, '/fuelStations'),
        child: ReusableCard(
          colour: const Color(0xFF111328),
          cardChild: CardContents(
            icon: FontAwesomeIcons.gasPump,
            label: 'Fuel Stations',
            colour: Colors.yellow,
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
            icon: FontAwesomeIcons.toolbox,
            label: 'Repair Orders',
            colour: Colors.indigo,
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
            icon: Icons.report,
            label: 'Fuel Reports',
            colour: Colors.blueGrey,
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
            icon: FontAwesomeIcons.bookBookmark,
            label: 'Repair Reports',
            colour: Colors.deepPurple,
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
          StreamBuilder<int>(
            stream: _unreadCountStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return NotificationIconButton(
                  unreadCount: snapshot.data ?? 0,
                  onPressed: () {
                    navigatorkey.currentState?.pushNamed('/notifications');
                  },
                );
              }
            },
          ),
          IconButton(
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.email;
              if (userId != null) {
                updateOnlineStatus(userId, false);
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
                onTap: () async {
                  final userId = FirebaseAuth.instance.currentUser?.email;
                  if (userId != null) {
                    updateOnlineStatus(userId, false);
                    _auth.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }
                })
          ],
        ),
      );
}

class NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onPressed;

  const NotificationIconButton({
    Key? key,
    required this.unreadCount,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// scaffoldcolor = 0xFF0A0D22
//reusablecardcolor = 0xFF1D1E33
