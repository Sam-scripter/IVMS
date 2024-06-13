import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integrated_vehicle_management_system/Components/inputRegister.dart';

const List<String> roles = <String>['SuperUser', 'Admin', 'User'];
const List<String> genders = ['Male', 'Female', 'Other'];

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Register Employee'),
      ),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterForm> {
  final _registerFormKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _organizationNumberController =
      TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _dateOfHireController = TextEditingController();

  String rolesDropdownValue = roles.first;
  String genderDropdownValue = genders.first;
  String positionsDropdownValue = '0';
  String departmentsDropdownValue = '0';
  String vehicleDropdownValue = '';
  String selectedVehicleId = '';
  bool _isLoading = false;

  Future<void> selectDateOfBirth() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _dateOfBirthController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> selectDateOfHire() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _dateOfHireController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Form(
        key: _registerFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              inputRegister(
                text: const Text('First Name'),
                textController: _firstNameController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the first name';
                  } else if (value.length >= 30 || value.length <= 2) {
                    return 'Please Enter a valid First name';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Second Name'),
                textController: _secondNameController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Second name';
                  } else if (value.length >= 30 || value.length <= 2) {
                    return 'Please Enter a valid second name';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 23.0),
                child: TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    label: Text('Date of Birth'),
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
                    selectDateOfBirth();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please select the Date of birth';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                child: TextFormField(
                  controller: _dateOfHireController,
                  decoration: const InputDecoration(
                    label: Text('Date of Hire'),
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
                    selectDateOfHire();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please select the Date of hire';
                    }
                    return null;
                  },
                ),
              ),
              inputRegister(
                text: const Text('Home Address'),
                textController: _homeAddressController,
                inputType: TextInputType.text,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Home address';
                  } else if (value.length >= 100 || value.length <= 2) {
                    return 'Please Enter a valid home address';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Organization Number'),
                textController: _organizationNumberController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Organization number';
                  } else if (value.length >= 30 || value.length <= 2) {
                    return 'Please Enter a valid organization number';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('ID Number'),
                textController: _idNumberController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ID Number';
                  } else if (value.length >= 105 || value.length <= 2) {
                    return 'Please Enter a valid ID number';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Mobile Number'),
                textController: _mobileNumberController,
                inputType: TextInputType.number,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  } else if (value.length >= 15 || value.length <= 2) {
                    return 'Please Enter a valid mobile number';
                  }
                  return null;
                },
                onchangedValue: (value) {},
              ),
              inputRegister(
                text: const Text('Email Address'),
                textController: _emailAddressController,
                inputType: TextInputType.emailAddress,
                valueValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Email Address';
                  } else if (value.length <= 5) {
                    return 'Please Enter a valid email address';
                  }
                  return null;
                },
                onchangedValue: (emailValue) {},
              ),
              DropdownButton(
                  hint: const Text('Gender of Employee'),
                  isExpanded: true,
                  value: genderDropdownValue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: genders.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      genderDropdownValue = value!;
                    });
                  }),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('departments')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> positions = [];
                  positions.add(
                    const DropdownMenuItem(
                      value: "0",
                      child: Text('Select Department'),
                    ),
                  );

                  if (snapshot.hasData) {
                    for (var value in snapshot.data!.docs.toList()) {
                      String departmentName = value['name'];
                      positions.add(DropdownMenuItem(
                          value: departmentName, child: Text(departmentName)));
                    }
                  }

                  return DropdownButton(
                    focusColor: Colors.lightBlueAccent,
                    dropdownColor: Colors.black87,
                    hint: const Text('Department Of Employee'),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                    items: positions,
                    onChanged: (departmentValue) {
                      setState(() {
                        departmentsDropdownValue = departmentValue!;
                      });
                    },
                    value: departmentsDropdownValue,
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('departments')
                    .where('name', isEqualTo: departmentsDropdownValue)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Return a loading indicator while waiting for data
                    return CircularProgressIndicator();
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Return a message if no department matches the dropdown value
                    return Text('No department found with this name');
                  } else {
                    // Get the reference to the department document
                    DocumentSnapshot departmentDoc = snapshot.data!.docs.first;

                    // Get a reference to the positions subcollection of the department
                    CollectionReference positionsRef =
                        departmentDoc.reference.collection('positions');

                    return StreamBuilder<QuerySnapshot>(
                      stream: positionsRef
                          .orderBy('name', descending: false)
                          .snapshots(),
                      builder: (context, positionsSnapshot) {
                        if (positionsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Return a loading indicator while waiting for position data
                          return CircularProgressIndicator();
                        } else if (!positionsSnapshot.hasData ||
                            positionsSnapshot.data!.docs.isEmpty) {
                          // Return a message if no positions found for the department
                          return const Text(
                              'No positions found for this department');
                        } else {
                          // Extract position data from snapshot
                          List<DropdownMenuItem<String>> positionItems = [];
                          positionItems.add(const DropdownMenuItem(
                            value: "0",
                            child: Text('Select Position'),
                          ));
                          for (var positionDoc
                              in positionsSnapshot.data!.docs) {
                            String positionName = positionDoc['name'];
                            positionItems.add(DropdownMenuItem(
                              value: positionName,
                              child: Text(positionName),
                            ));
                          }

                          // Return the dropdown button with position options
                          return DropdownButton(
                            focusColor: Colors.lightBlueAccent,
                            dropdownColor: Colors.black87,
                            hint: const Text('Position Of Employee'),
                            isExpanded: true,
                            padding: EdgeInsets.symmetric(
                                vertical: 9, horizontal: 23),
                            items: positionItems,
                            onChanged: (positionsValue) {
                              setState(() {
                                positionsDropdownValue = positionsValue!;
                                print(positionsDropdownValue);
                                print(departmentsDropdownValue);
                              });
                            },
                            value: positionsDropdownValue,
                          );
                        }
                      },
                    );
                  }
                },
              ),
              positionsDropdownValue == "Driver"
                  ?
                  // Return a StreamBuilder to fetch vehicles if the selected position is "Driver"
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('vehicles')
                          .where('department',
                              isEqualTo: departmentsDropdownValue)
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem<String>> vehicleItems = [];
                        if (snapshot.hasData) {
                          vehicleItems.add(const DropdownMenuItem(
                            value: "0",
                            child: Text('Select Vehicle'),
                          ));

                          for (var vehicleDoc in snapshot.data!.docs) {
                            var value =
                                vehicleDoc.data() as Map<String, dynamic>;
                            String vehicleName = value['licensePlateNumber'];

                            vehicleItems.add(DropdownMenuItem(
                              value: vehicleName,
                              child: Text(vehicleName),
                            ));
                          }

                          // Ensure the selected value is valid
                          if (vehicleDropdownValue != null &&
                              !vehicleItems.any((item) =>
                                  item.value == vehicleDropdownValue)) {
                            vehicleDropdownValue = "0";
                          }
                        }

                        return DropdownButton<String>(
                          focusColor: Colors.lightBlueAccent,
                          dropdownColor: Colors.black87,
                          hint: const Text('Select Vehicle'),
                          isExpanded: true,
                          padding:
                              EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                          items: vehicleItems,
                          onChanged: (vehicleValue) async {
                            setState(() {
                              vehicleDropdownValue = vehicleValue!;

                              int selectedIndex = vehicleItems.indexWhere(
                                (element) => element.value == vehicleValue,
                              );

                              // Adjust index by 1 due to the initial "Select Vehicle" item
                              selectedVehicleId = selectedIndex > 0
                                  ? snapshot.data!.docs[selectedIndex - 1].id
                                  : '';
                            });

                            // Check if the selected vehicle has a driver
                            if (selectedVehicleId.isNotEmpty) {
                              DocumentSnapshot vehicleDoc =
                                  await FirebaseFirestore.instance
                                      .collection('vehicles')
                                      .doc(selectedVehicleId)
                                      .get();

                              var vehicleData =
                                  vehicleDoc.data() as Map<String, dynamic>;
                              bool hasDriver = vehicleData['driver'] != null;

                              if (hasDriver) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Driver Allocated'),
                                      content: Text(
                                          'A driver is already allocated to this vehicle. Kindly select another'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          value: vehicleDropdownValue,
                        );
                      },
                    )
                  :
                  // Return an empty Container if the selected position is not "Driver"
                  Container(),
              DropdownButton(
                  hint: const Text('Role Of Employee'),
                  isExpanded: true,
                  value: rolesDropdownValue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: roles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      rolesDropdownValue = value!;
                    });
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  color: Colors.lightBlueAccent,
                  child: MaterialButton(
                    onPressed: () async {
                      if (_registerFormKey.currentState!.validate()) {
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          UserCredential userCredential =
                              await _auth.createUserWithEmailAndPassword(
                            email: _emailAddressController.text,
                            password: '12345678',
                          );
                          const bool isOnline = false;

                          Map<String, dynamic> userData = {
                            'firstName': _firstNameController.text,
                            'secondName': _secondNameController.text,
                            'DOB': _dateOfBirthController.text,
                            'DOH': _dateOfHireController.text,
                            'homeAddress': _homeAddressController.text,
                            'organizationNumber':
                                _organizationNumberController.text,
                            'idNumber': _idNumberController.text,
                            'mobileNumber': _mobileNumberController.text,
                            'emailAddress': _emailAddressController.text,
                            'gender': genderDropdownValue,
                            'department': departmentsDropdownValue,
                            'position': positionsDropdownValue,
                            'role': rolesDropdownValue,
                            'isOnline': false,
                            'passwordSet': false, // Add this line
                            'timestamp': FieldValue.serverTimestamp(),
                          };

                          if (positionsDropdownValue == "Driver") {
                            userData['vehicleId'] = selectedVehicleId;
                            userData['vehicle'] = vehicleDropdownValue;

                            _firestore
                                .collection('employees')
                                .doc(userCredential.user!.email)
                                .set(userData);

                            await FirebaseFirestore.instance
                                .collection('vehicles')
                                .doc(selectedVehicleId)
                                .update({
                              'driver':
                                  '${_firstNameController.text} ${_secondNameController.text}',
                            });

                            Navigator.pop(context);
                          } else {
                            _firestore
                                .collection('employees')
                                .doc(userCredential.user!.email)
                                .set(userData);

                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print(e);
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
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
      ),
      if (_isLoading)
        Container(
          color: Colors.black.withOpacity(0.7),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }
}
