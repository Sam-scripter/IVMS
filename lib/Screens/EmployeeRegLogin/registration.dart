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

  // Future<void> addUserDetails(
  //     String firstName,
  //     String secondName,
  //     String dob,
  //     String doh,
  //     String homeAddress,
  //     String organizationNumber,
  //     String IDnumber,
  //     String mobileNumber,
  //     String emailAddress,
  //     String position,
  //     String role,
  //     String department) async {
  //   await _firestore.collection('employees').add({
  //     'firstName': firstName,
  //     'secondName': secondName,
  //     'dob': dob,
  //     'doh': doh,
  //     'homeAddress': homeAddress,
  //     'organizationNumber': organizationNumber,
  //     'IDnumber': IDnumber,
  //     'mobileNumber': mobileNumber,
  //     'emailAddress': emailAddress,
  //     'position': position,
  //     'role': role,
  //     'department': department,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
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
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
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
                  .collection('positions')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> positions = [];
                positions.add(
                  const DropdownMenuItem(
                    value: "0",
                    child: Text('Select Position'),
                  ),
                );

                if (snapshot.hasData) {
                  for (var value in snapshot.data!.docs.toList()) {
                    String positionName = value['name'];
                    String positionId = value.id;
                    positions.add(DropdownMenuItem(
                        value: positionName, child: Text(positionName)));
                  }
                }

                return DropdownButton(
                  focusColor: Colors.lightBlueAccent,
                  dropdownColor: Colors.black87,
                  hint: const Text('Position Of Employee'),
                  isExpanded: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 23),
                  items: positions,
                  onChanged: (positionsValue) {
                    setState(() {
                      positionsDropdownValue = positionsValue!;
                    });
                  },
                  value: positionsDropdownValue,
                );
              },
            ),
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
                      // String departmentId = value.id;
                      departments.add(
                        DropdownMenuItem(
                          value: departmentName,
                          child: Text(departmentName),
                        ),
                      );
                    }
                  }
                  return DropdownButton(
                    hint: const Text('Department Of Employee'),
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
            inputRegister(
              text: const Text('Password'),
              textController: _passwordController,
              inputType: TextInputType.visiblePassword,
              valueValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the Password';
                } else if (value.length >= 17 || value.length <= 7) {
                  return 'Password characters range from 8 to 16 characters';
                }
                return null;
              },
              onchangedValue: (value) {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                color: Colors.lightBlueAccent,
                child: MaterialButton(
                  onPressed: () async {
                    if (_registerFormKey.currentState!.validate()) {
                      try {
                        UserCredential userCredential =
                            await _auth.createUserWithEmailAndPassword(
                                email: _emailAddressController.text,
                                password: _passwordController.text);
                        final bool isOnline = false;

                        _firestore
                            .collection('employees')
                            .doc(userCredential.user!.email)
                            .set({
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
                          'position': positionsDropdownValue,
                          'role': rolesDropdownValue,
                          'department': departmentsDropdownValue,
                          'isOnline': isOnline,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // addUserDetails(
                        //     _firstNameController.text,
                        //     _secondNameController.text,
                        //     _dateOfBirthController.text,
                        //     _dateOfHireController.text,
                        //     _homeAddressController.text,
                        //     _organizationNumberController.text,
                        //     _idNumberController.text,
                        //     _mobileNumberController.text,
                        //     _emailAddressController.text,
                        //     positionsDropdownValue,
                        //     rolesDropdownValue,
                        //     departmentsDropdownValue);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Processing Data',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black45,
                          ),
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
