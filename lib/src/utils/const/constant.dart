import 'package:flutter/material.dart';

const kBgLoginScreen = Color(0xFFFF9800);

const kBgWarningColor = Color(0xFFFFE0B2);

const kBottomBarColor = Color(0xFFFF8C00);

const kBottomBarIconSize = 30.0;

const kLogoMSG = 'assets/logodepan.png';

const kAppBarColor = Color(0xFFFF9800);

const kIconColor = Color(0xFFFFFFFF);

const kBtnColor = Color(0xFFff7f00);

const kBackButton =
    Icon(Icons.arrow_back, color: kIconColor, size: kBottomBarIconSize);

const kTextFieldEditDecor = InputDecoration(
  contentPadding: EdgeInsets.all(20),
  hintText: '',
  hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.bold),
  labelText: '',
  labelStyle: TextStyle(
      height: 0.5,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
      color: Colors.black),
);



// child: TextFormField(
//   maxLines: 2,
//   enabled: true,
//   controller: _controllerHome,
//   onChanged: (value) {
//     print(value);
//     setState(() {
//       homeUser = value;
//     });
//   },
//   style: TextStyle(color: Colors.grey),
//   decoration: kTextFieldEditDecor.copyWith(labelText: 'Home Address'),
// ),
// 
// 
// // InputDecoration(
  //   contentPadding: EdgeInsets.all(20),
  //   labelText: 'Email',
  //   labelStyle: TextStyle(
  //       height: 1,
  //       fontWeight: FontWeight.bold,
  //       fontSize: 20.0,
  //       color: Colors.black),
  //   hintText: '',
  //   hintStyle: TextStyle(
  //       height: 2, fontWeight: FontWeight.bold),
  // ),