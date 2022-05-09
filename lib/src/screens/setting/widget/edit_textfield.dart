import 'package:attendance/src/utils/const/constant.dart';
import 'package:flutter/material.dart';

class EditTextField extends StatelessWidget {
  final TextEditingController controllerText;
  final Function onChange;
  EditTextField({this.controllerText, this.onChange});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 2,
      enabled: true,
      controller: controllerText,
      onChanged: onChange,
      style: TextStyle(color: Colors.grey),
      decoration: kTextFieldEditDecor.copyWith(labelText: 'Home Address'),
    );
  }
}