import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';

class NewRepairOorder extends StatefulWidget {
  const NewRepairOorder({super.key});

  @override
  State<NewRepairOorder> createState() => _NewRepairOorderState();
}

class _NewRepairOorderState extends State<NewRepairOorder> {
  String plateDropdownValue = '';
  String makeAndModelValue = '';
  String driverDropDownValue = '';
  String sparepartsDropdownValue = '';
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New repair order',
          style: GoogleFonts.lato(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> plates = [];
                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs) {
                      var vehicle = value.data() as Map<String, dynamic>;
                      String vehiclePlate = vehicle['licensePLateNumber'];

                      plates.add(DropdownMenuItem(
                        child: Text(vehiclePlate),
                        value: vehiclePlate,
                      ));
                    }
                  }
                  return DropdownButton(
                    focusColor: Colors.lightBlueAccent,
                    dropdownColor: Colors.black87,
                    hint: const Text('vehicle plate'),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    items: plates,
                    value: plateDropdownValue,
                    onChanged: (value) {
                      setState(() {
                        plateDropdownValue = value!;
                      });
                    },
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> plates = [];
                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs) {
                      var vehicle = value.data() as Map<String, dynamic>;
                      String vehicleModel = vehicle['makeAndModel'];

                      plates.add(DropdownMenuItem(
                        child: Text(vehicleModel),
                        value: vehicleModel,
                      ));
                    }
                  }
                  return DropdownButton(
                    focusColor: Colors.lightBlueAccent,
                    dropdownColor: Colors.black87,
                    hint: const Text('Make and Model'),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    items: plates,
                    value: makeAndModelValue,
                    onChanged: (value) {
                      setState(() {
                        makeAndModelValue = value!;
                      });
                    },
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> plates = [];
                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs) {
                      var vehicle = value.data() as Map<String, dynamic>;
                      String vehicleDriver = vehicle['driver'];

                      plates.add(DropdownMenuItem(
                        child: Text(vehicleDriver),
                        value: vehicleDriver,
                      ));
                    }
                  }
                  return DropdownButton(
                    focusColor: Colors.lightBlueAccent,
                    dropdownColor: Colors.black87,
                    hint: const Text('Driver'),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    items: plates,
                    value: driverDropDownValue,
                    onChanged: (value) {
                      setState(() {
                        driverDropDownValue = value!;
                      });
                    },
                  );
                }),
            inputRegister(
                text: const Text('Description'),
                textController: descriptionController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                }),
            //TODO: Handle Spare parts such that make and model goes with the spare part,
            Material(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: MaterialButton(
                height: 42,
                minWidth: 320,
                elevation: 5.0,
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('repairOrders')
                      .add({
                    'licensePlateNumber': plateDropdownValue,
                    'makeAndModel': makeAndModelValue,
                    'driver': driverDropDownValue,
                    'description': descriptionController.text,
                    'status': 'Submitted',
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
