import 'package:flutter/material.dart';

class inputRegister extends StatelessWidget {
  TextEditingController? textController;
  Widget? text;
  TextInputType inputType;
  Function(String)? onchangedValue;
  String? Function(String?)? valueValidator;
  inputRegister(
      {super.key,
      this.textController,
      required this.text,
      this.onchangedValue,
      required this.inputType,
      required this.valueValidator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 23.0),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlueAccent),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlueAccent),
          ),
          label: text,
        ),
        style: const TextStyle(fontSize: 18.0),
        onChanged: onchangedValue,
        keyboardType: inputType,
        validator: valueValidator,
      ),
    );
  }
}
