import 'package:attendance/src/api/api_service.dart';
import 'package:attendance/src/db/database.dart';
import 'package:attendance/src/model/data_checkin.dart';
import 'package:attendance/src/screens/homepage/homepage.dart';
import 'package:attendance/src/screens/task/task_create.dart';
import 'package:attendance/src/utils/const/constant.dart';
import 'package:attendance/src/utils/services/relogin.dart';
import 'package:attendance/src/utils/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _marginPage = EdgeInsets.all(10.0);
const _textTitle = TextStyle(
  color: Colors.orange,
  fontSize: 25,
  fontWeight: FontWeight.bold,
);

class Checkin extends StatefulWidget {
  final double lat;
  final double long;
  final String address;
  Checkin({this.lat, this.long, this.address});
  @override
  _CheckinState createState() => _CheckinState();
}

class _CheckinState extends State<Checkin> {
  ApiService _apiService = ApiService();
  ReLogin _relogin = ReLogin();
  SharedPreferences logindata;
  String _token;
  String _fbtoken;
  int _character = 2;
  File _image;
  String imageBase64;
  final _listProject = [
    "WFO (Work From Office)",
    "WFH (Work From Home)",
    "WFC (Work From Client)",
  ];
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = logindata.getString('token');
        _fbtoken = logindata.getString('fbtoken');
        logindata.getInt('projectId') == null
            ? _character = 2
            : _character = logindata.getInt('projectId');
      });
      print('prohect id: $_character');
      print('token di absence screen: $_token');
      print('fbtoken di absence screen: $_fbtoken');
    }
  }

  loadFirebase() async {
    _apiService.postTokenFirebase(_token, _fbtoken).then((result) {
      var jsondata = json.decode(result);
      if (jsondata['status'] == 'success') {
      } else {
        print('failed post firebase token');
      }
    });
  }

  checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopDialog(
                title: 'Camera permission disabled',
                content: 'You have to allow the camera access to check in',
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await openAppSettings();
                  Navigator.pop(context);
                });
          });
    }
    return;
  }

  Future getImage() async {
    await checkPermission();
    try {
      File imagee;
      final _picker = ImagePicker();
      PickedFile image1 = await _picker.getImage(
          source: ImageSource.camera,
          maxHeight: 720,
          maxWidth: 720,
          imageQuality: 50);
      imagee = File(image1.path);

      if (!mounted) return;
      if (imagee == null) {
        return;
      }
      final base64Image = base64Encode(imagee.readAsBytesSync());
      setState(() {
        _image = imagee;
        imageBase64 = base64Image;
      });
    } catch (error) {
      print('error taking picture ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new HomePage()),
        );
        return Future.value(false);
      },
      child: SingleChildScrollView(
        child: Container(
          margin: _marginPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(30.0, 15.0, 0.0, 30.0),
                child: Text('Check In', style: _textTitle),
              ),
              Column(
                children: [
                  _image == null
                      ? Container(
                          width: 130,
                          height: 130,
                          child: GestureDetector(
                            onTap: getImage,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_enhance,
                                  size: 40,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    'Click here to take a photo',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          margin: EdgeInsets.only(bottom: 15.0),
                          child: IconButton(
                            icon: Image.file(
                              _image,
                              fit: BoxFit.cover,
                              width: 185,
                              height: double.maxFinite,
                            ),
                            iconSize: 50,
                            onPressed: getImage,
                          ),
                        ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    height: 170.0,
                    child: Column(
                      children: [
                        for (int i = 1; i <= _listProject.length; i++)
                          // i == 1
                          //     ? Container():
                          RadioListTile(
                            title: Text(_listProject[i - 1]),
                            value: i,
                            groupValue: _character,
                            onChanged: (value) {
                              setState(() {
                                _character = value;
                                print(_character);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: checkinButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkinButton() {
    return Builder(
      builder: (context) => RoundedLoadingButton(
        color: kBtnColor,
        successColor: Colors.orange,
        child: Text('SUBMIT', style: TextStyle(color: Colors.white)),
        controller: _btnController,
        onPressed: () async {
          if (_character == null ||
              widget.address == null ||
              widget.lat == null) {
            allNull();
            _btnController.reset();
          } else if (_image == null) {
            nullImage();
            _btnController.reset();
          } else {
            CheckIn checkin = await dataToCheckin();
            // var validatedata = await validateData(checkin);
            // if (validatedata != true) {
            //   return;
            // }
            _apiService.postCheckIn(checkin, _token).then((result) {
              if (result == 'timeout') {
                _btnController.reset();
                onTimeout();
              } else {
                var jsondata = json.decode(result);
                var statusCode = jsondata['status'];
                if (statusCode == 'success') {
                  _btnController.success();
                  loadFirebase();
                  onSuccess();
                } else if (statusCode == 401) {
                  _btnController.reset();
                  onReLogin(jsondata);
                } else if (statusCode == 400) {
                  _btnController.reset();
                  locationFailed();
                } else {
                  _btnController.reset();
                  onFailed(jsondata);
                }
              }
            });
          }
        },
      ),
    );
  }

  onReLogin(jsondata) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
                title: 'Failed to check in',
                content: jsondata['message'],
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await _relogin.onLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/LoginScreen', (Route<dynamic> route) => false);
                }),
          );
        });
  }

  nullImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check in',
            content: 'Please take your selfie before',
            isWarning: false,
            isButton: false,
          );
        });
  }

  allNull() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check in',
            content: 'Please try again and fill the data correctly',
            isWarning: false,
            isButton: false,
          );
        });
  }

  locationFailed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check in',
            content: 'Sorry, your location is not accurate',
            isWarning: false,
            isButton: false,
          );
        });
  }

  // validateData(checkin) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('your data'),
  //           content: Container(
  //             height: 200,
  //             width: 300,
  //             child: SingleChildScrollView(
  //               child: Column(children: [
  //                 Text(
  //                   checkin.toString(),
  //                 ),
  //               ]),
  //             ),
  //           ),
  //         );
  //       });
  //   return true;
  // }

  dataToCheckin() {
    double lat = double.parse(widget.lat.toString());
    double long = double.parse(widget.long.toString());
    Geolocation geolocation = Geolocation(lat: lat, long: long);
    int projectid = int.parse(_character.toString());
    String img = imageBase64;
    String location = widget.address.toString();
    CheckIn checkin = CheckIn(
      projectId: projectid,
      location: location,
      image: 'data:image/png;base64,' + img,
      fbtoken: _fbtoken,
      geolocation: geolocation,
    );
    return checkin;
  }

  saveData() {
    int projectId = int.parse(_character.toString());
    var now = DateTime.now();
    String timeCheckin = DateFormat('yyyy-MM-dd').format(now);
    var timeExpired1 = now.add(new Duration(days: 1));
    String timeToexpired = DateFormat('yyyy-MM-dd').format(timeExpired1);
    logindata.setBool('isCheckin', true);
    logindata.setInt('projectId', projectId);
    logindata.setString('timeCheckin', timeCheckin);
    logindata.setString('timeExpired', timeToexpired);
    logindata.setString('imageCheckin', imageBase64);
  }

  onTimeout() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
                title: 'Connection Failed',
                content:
                    'There is no response on server or please check your connectivity',
                isWarning: false,
                isButton: true,
                onpressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }),
          );
        });
  }

  onSuccess() async {
    await saveData();
    print('Successfully Checkin!');
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 150.0),
              child: PopDialog(
                title: 'Absence recorded successfully',
                content: 'Happy working',
                isWarning: false,
                isButton: true,
                onpressed: () {
                  logindata.setBool('isCheckin', true);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CreateTask()),
                      ModalRoute.withName('/HomePage'));
                },
              ),
            ),
          );
        });
  }

  onFailed(jsondata) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check in',
            content: jsondata['message'],
            // content: jsondata.toString(),
            // content: 'Please try again',
            // warningText: jsondata.toString(),
            isWarning: false,
            isButton: false,
          );
        });
  }
}
