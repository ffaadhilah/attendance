import 'dart:async';
import 'dart:convert';
import 'package:attendance/src/utils/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:attendance/src/utils/services/permission_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show Client;
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
 
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String baseUrl = "https://attendance.msg.co.id/api/v1/app_version";
  // final String baseUrl = "http://116.213.55.119/api/v1/app_version";
  // final String baseUrl = "https://attendance.zarkasih.my.id/api/v1/app_version";
  bool _isLoading = false;
  SharedPreferences logindata;
  bool isLogin;
  Client client = Client();
  int _dataversion;
  String _link;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      setState(() {
        _isLoading = true;
      });
      _loadPermission();
    });
  }

  _loadPermission() async {
    PermissionChecker permissionCheck = PermissionChecker();
    try {
      bool result = await permissionCheck.getPermission();
      if (result != true) {
        if (Platform.isIOS) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return PopDialog(
                    title:
                        'Your camera access is needed',
                        content: 'this access needed for absence validation, you can enabled this access later',
                    isWarning: false,
                    isButton: true,
                    onpressed: () {
                      // openAppSettings();
                      Navigator.pop(context);
                      getVersion();
                    });
              });
        } else {
          await permissionCheck.getPermission();
        }
      }
    } catch (e) {
      print(e);
    }
    getVersion();
  }

  Future getVersion() async {
    try {
      final response =
          await client.get("$baseUrl").timeout(const Duration(seconds: 15));
      print('test1');

      if (response.statusCode == 200) {
        var jsonn = json.decode(response.body);
        print(jsonn);
        String appversion = jsonn['app_version'];
        var listversion = appversion.split('.');
        var intversion = int.parse(listversion[0]+listversion[1]+listversion[2]);
        if (mounted) {
          setState(() {
            _dataversion = intversion;
            if (Platform.isAndroid) {
              _link = jsonn['android_link'];
            } else if (Platform.isIOS) {
              _link = jsonn['ios_link'];
            }
          });
        }
        _initPackageInfo();
      } else {
        throw Exception('Failed to fetch data');
      }
    } on TimeoutException catch (_) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopDialog(
              title: 'Connection Failed',
              content:
                  'There is no responce from server, or please check your connectivity',
              isWarning: false,
              isButton: false,
            );
          });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
    var applistversion = _packageInfo.version.split('.');
    var appversion = int.parse(applistversion[0]+applistversion[1]+applistversion[2]);
    if (appversion < _dataversion) {
      Navigator.pushReplacementNamed(context, '/WarningVersion',
          arguments: {'directtoLink': _link});
    } else {
      _loadUserInfo();
    }
  }

  void _loadUserInfo() async {
    logindata = await SharedPreferences.getInstance();
    // logindata.clear();
    // await _delete();
    // await _read();
    isLogin = logindata.getBool('isLogin');
    print('sudah login? $isLogin');
    if (isLogin == true) {
      Navigator.pushReplacementNamed(context, '/HomePage');
    } else {
      Navigator.pushReplacementNamed(context, '/LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logodepan.png',
              height: 150.0,
              width: 150.0,
            ),
            _isLoading == false ? Container() : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // manually delete user data
  // _delete() async {
  //   DatabaseHelper helper = DatabaseHelper.instance;
  //   int rowId = 1;
  //   final rowsDeleted = await helper.delete(rowId);
  //   print('deleted $rowsDeleted row(s): row $rowId');
  // }
  // manually read user data
  // _read() async {
  //   DatabaseHelper helper = DatabaseHelper.instance;
  //   int rowId = 1;
  //   Datauser word = await helper.queryDatauser(rowId);
  //   if (word == null) {
  //     print('read row $rowId: empty');
  //   } else {
  //     print('read row $rowId: ${word.name} ${word.email} ${word.token}');
  //   }
  // }
}
