import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';

class RegisterFuelStation extends StatelessWidget {
  const RegisterFuelStation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register Fuel Station',
          style: GoogleFonts.lato(),
        ),
        centerTitle: false,
      ),
      body: const RegisterFuelStationForm(),
    );
  }
}

class RegisterFuelStationForm extends StatefulWidget {
  const RegisterFuelStationForm({super.key});

  @override
  State<RegisterFuelStationForm> createState() =>
      _RegisterFuelStationFormState();
}

class _RegisterFuelStationFormState extends State<RegisterFuelStationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _stationLocationController =
      TextEditingController();
  final TextEditingController _currentDieselAmountController =
      TextEditingController();
  final TextEditingController _currentPetrolAmountController =
      TextEditingController();
  final TextEditingController _petrolTankCapacityController =
      TextEditingController();
  final TextEditingController _dieselTankCapacityController =
      TextEditingController();

  String fuelAttendantsDropdownValue = '0';

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              inputRegister(
                text: const Text('Enter the Station Name'),
                textController: _stationNameController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Enter the Location of the station'),
                textController: _stationLocationController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null) {
                    return 'Please enter the location of the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('employees')
                    .where('position', isEqualTo: 'Fuel Attendant')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> fuelAttendants = [];
                  fuelAttendants.add(
                    const DropdownMenuItem(
                      value: '0',
                      child: Text('Select the fuel Attendant'),
                    ),
                  );

                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs.toList()) {
                      String attendantName =
                          '${value['firstName']} ${value['secondName']}';
                      fuelAttendants.add(
                        DropdownMenuItem(
                          value: attendantName,
                          child: Text(attendantName),
                        ),
                      );
                    }
                  }

                  return DropdownButton(
                    dropdownColor: Colors.black87,
                    focusColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    hint: const Text('select fuel attendant'),
                    isExpanded: true,
                    items: fuelAttendants,
                    onChanged: (value) {
                      setState(() {
                        fuelAttendantsDropdownValue = value!;
                      });
                    },
                    value: fuelAttendantsDropdownValue,
                  );
                },
              ),
              inputRegister(
                text: const Text('Enter the current diesel amount in litres'),
                textController: _currentDieselAmountController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount of diesel remaining at the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Enter the current petrol amount in litres'),
                textController: _currentPetrolAmountController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount of petrol at the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Enter the Diesel tank capacity'),
                textController: _dieselTankCapacityController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the diesel tank capacity of the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Enter the Petrol tank capacity'),
                textController: _petrolTankCapacityController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the petrol tank capacity of the station';
                  }
                },
                onchangedValue: (value) {},
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  elevation: 5.0,
                  color: Colors.lightBlue,
                  child: MaterialButton(
                    child: const Text('Register'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          FirebaseFirestore.instance
                              .collection('fuelStations')
                              .doc(_stationNameController.text)
                              .set({
                            'stationName': _stationNameController.text,
                            'stationLocation': _stationLocationController.text,
                            'stationAttendant': fuelAttendantsDropdownValue,
                            'currentDieselAmount':
                                _currentDieselAmountController.text,
                            'currentPetrolAmount':
                                _currentPetrolAmountController.text,
                            'dieselTankCapacity':
                                _dieselTankCapacityController.text,
                            'petrolTankCapacity':
                                _petrolTankCapacityController.text,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Processing Data',
                              style: GoogleFonts.lato(color: Colors.white),
                            ),
                            backgroundColor: Colors.black45,
                          ));
                          Navigator.pop(context);
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    minWidth: 320,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
