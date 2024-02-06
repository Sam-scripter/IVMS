import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';

List<String> fuels = ['Petrol', 'Diesel'];

class RegisterVehicle extends StatelessWidget {
  RegisterVehicle({super.key});

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a Vehicle',
          style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 20.0)),
        ),
        centerTitle: false,
      ),
      body: const VehicleRegistrationForm(),
    );
  }
}

class VehicleRegistrationForm extends StatefulWidget {
  const VehicleRegistrationForm({super.key});

  @override
  State<VehicleRegistrationForm> createState() =>
      _VehicleRegistrationFormState();
}

class _VehicleRegistrationFormState extends State<VehicleRegistrationForm> {
  final _vehicleFormKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _makeAndModel = TextEditingController();
  final TextEditingController _chassisNumber = TextEditingController();
  final TextEditingController _licensePlateNumber = TextEditingController();
  final TextEditingController _insuranceProvider = TextEditingController();
  final TextEditingController _odometerReading = TextEditingController();
  final TextEditingController _lastServiceDate = TextEditingController();
  final TextEditingController _nextServiceDate = TextEditingController();
  final TextEditingController _litresController = TextEditingController();
  final TextEditingController _kilometresController = TextEditingController();
  // final TextEditingController _maintenanceHistory = TextEditingController();
  final TextEditingController _primaryUse = TextEditingController();

  Future<void> selectLastServiceDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _lastServiceDate.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> selectNextServiceDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _nextServiceDate.text = _picked.toString().split(" ")[0];
      });
    }
  }

  String fuelDropdownValue = fuels.first;
  String departmentsDropdownValue = '0';
  String driversDropdownValue = '0';

  Future<void> addVehicleDetails(
    String makeAndModel,
    String chassisNumber,
    String licensePlateNumber,
    String insuranceProvider,
    String odometerReading,
    String lastServiceDate,
    String nextServiceDate,
    String primaryUse,
    String driver,
    String department,
    double fuelConsumption,
  ) async {
    await _firestore.collection('vehicles').add({
      'makeAndModel': makeAndModel,
      'chassisNumber': chassisNumber,
      'licensePlateNumber': licensePlateNumber,
      'fuelConsumption': fuelConsumption,
      'insuranceProvider': insuranceProvider,
      'odometerReading': odometerReading,
      'lastServiceDate': lastServiceDate,
      'nextServiceDate': nextServiceDate,
      'primaryUse': primaryUse,
      'driver': driver,
      'department': department,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _vehicleFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            inputRegister(
              text: const Text('Make and Model'),
              textController: _makeAndModel,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the make and or model of the vehicle';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid make and or model';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            inputRegister(
              text: const Text('Chassis number'),
              textController: _chassisNumber,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the chassis number';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid chassis number';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            inputRegister(
              text: const Text('License Plate Number'),
              textController: _licensePlateNumber,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the license plate number';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid license plate number number';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _litresController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        label: Text('litres'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the litres';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                const Text('litres per '),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _kilometresController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        label: Text('KM'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the litres';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
            inputRegister(
              text: const Text('Insurance Provider'),
              textController: _insuranceProvider,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the insurance provider';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid insurance provider';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            DropdownButton(
                hint: const Text('FuelType of the Vehicle'),
                isExpanded: true,
                value: fuelDropdownValue,
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                items: fuels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    fuelDropdownValue = value!;
                  });
                }),
            inputRegister(
              text: const Text('Odometer Reading'),
              textController: _odometerReading,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the Odometer Reading';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid Odometer reading';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 9, horizontal: 23.0),
              child: TextFormField(
                controller: _lastServiceDate,
                decoration: InputDecoration(
                  label: Text('Last Service Date'),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {
                  selectLastServiceDate();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please select the last Service Date of the vehicle';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 9, horizontal: 23.0),
              child: TextFormField(
                controller: _nextServiceDate,
                decoration: const InputDecoration(
                  label: Text('Next Service Date'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () {
                  selectNextServiceDate();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please select the next Service Date of the Vehicle';
                  }
                  return null;
                },
              ),
            ),
            inputRegister(
              text: const Text('Primary Use'),
              textController: _primaryUse,
              inputType: TextInputType.text,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the primary use of the vehicle';
                } else if (value.length >= 30 || value.length <= 2) {
                  return 'Please Enter a valid primary use';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employees')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> positions = [];
                positions.add(
                  const DropdownMenuItem(
                    value: "0",
                    child: Text('Select Driver'),
                  ),
                );

                if (snapshot.hasData) {
                  for (var value in snapshot.data!.docs.toList()) {
                    String positionName = value['position'];
                    String driverFirstName = value['firstName'];
                    String driverSecondName = value['secondName'];

                    if (positionName == 'Driver' || positionName == 'driver') {
                      positions.add(DropdownMenuItem(
                          value: "$driverFirstName $driverSecondName",
                          child: Text("$driverFirstName $driverSecondName")));
                    }
                  }
                }

                return DropdownButton(
                  focusColor: Colors.lightBlueAccent,
                  dropdownColor: Colors.black87,
                  hint: const Text('Driver of the Vehicle'),
                  isExpanded: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: positions,
                  onChanged: (driversValue) {
                    setState(() {
                      driversDropdownValue = driversValue!;
                    });
                  },
                  value: driversDropdownValue,
                );
              },
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('departments')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> departments = [];
                  departments.add(
                    const DropdownMenuItem(
                      value: '0',
                      child: Text('Select Department'),
                    ),
                  );

                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs.toList()) {
                      String departmentName = value['name'];
                      departments.add(
                        DropdownMenuItem(
                          value: departmentName,
                          child: Text(departmentName),
                        ),
                      );
                    }
                  }
                  return DropdownButton(
                    hint: const Text('Department Of the Vehicle'),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    items: departments,
                    onChanged: (departmentValue) {
                      setState(() {
                        departmentsDropdownValue = departmentValue!;
                      });
                    },
                    value: departmentsDropdownValue,
                  );
                }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                color: Colors.lightBlueAccent,
                child: MaterialButton(
                  onPressed: () async {
                    if (_vehicleFormKey.currentState!.validate()) {
                      try {
                        double kilometres =
                            double.parse(_kilometresController.text);
                        double litres = double.parse(_litresController.text);
                        double fuelConsumption = kilometres / litres;
                        addVehicleDetails(
                          _makeAndModel.text,
                          _chassisNumber.text,
                          _licensePlateNumber.text,
                          _insuranceProvider.text,
                          _odometerReading.text,
                          _lastServiceDate.text,
                          _nextServiceDate.text,
                          _primaryUse.text,
                          driversDropdownValue,
                          departmentsDropdownValue,
                          fuelConsumption,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  minWidth: 320.0,
                  height: 42.0,
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
