import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'positionProfile.dart';

class Positions extends StatefulWidget {
  const Positions({super.key});

  @override
  State<Positions> createState() => _PositionsState();
}

class _PositionsState extends State<Positions> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> deletePosition(String positionId) async {
    await _firestore.collection('positions').doc(positionId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('positions').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int numberOfPositions = snapshot.data!.docs.length;
              return Text('Positions ($numberOfPositions)');
            } else {
              return const Text('Positions ');
            }
          },
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddPosition(),
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: _firestore
                  .collection('positions')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> positionsWidget = [];
                  for (var position in snapshot.data!.docs) {
                    var value = position.data();
                    String positionName = value['name'].toString();
                    String positionId = position.id;

                    positionsWidget.add(
                      ListTile(
                        title: Text(
                          positionName,
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(fontSize: 20.0)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deletePosition(positionId);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PositionProfile(
                                      positionName: positionName)));
                        },
                      ),
                    );
                  }
                  return Column(
                    children: positionsWidget,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      ),
    );
  }
}

class AddPosition extends StatelessWidget {
  const AddPosition({super.key});

  @override
  Widget build(BuildContext context) {
    String newPosition = "";
    return Container(
      color: Color(0xFF0A0D22),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30.0),
          ),
          color: Color(0xFF1D1E33),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  'Add Position',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(fontSize: 20.0),
                  ),
                )),
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    newPosition = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newPosition.isNotEmpty) {
                      FirebaseFirestore.instance.collection('positions').add({
                        'name': newPosition,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text('Please enter a valid Position'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'))
                              ],
                            );
                          });
                    }
                  },
                  child: Text(
                    'Add Position',
                    style:
                        GoogleFonts.lato(textStyle: TextStyle(fontSize: 18.0)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
