import 'dart:collection';
import 'package:attendance/src/utils/widget/dialog/dialog.dart';
import 'package:attendance/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'dart:io' show Platform;


const kGoogleApiKeyAndro = "AIzaSyAIatYtSea_CIDxO6GmPydUtS5HcDTLaF0";
const kGoogleApiKeyIos = "AIzaSyBmxTFFzKdfzTUORj36o4e3V50WXKpvMOE";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);

class MapsScreen extends StatefulWidget {
  final String toUpdate;
  MapsScreen({this.toUpdate});
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController mapController;
  // Set<Marker> _markers = HashSet<Marker>();
  bool isMarker = false;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 0;
  String addresspositon;
  double addlat;
  double addlong;
  SharedPreferences logindata;
  geo.Position _currentPosition;
  loc.Location locationGps = loc.Location();
  // final LatLng _center = const LatLng(-6.177104698517575, 106.81901272521043);

  List<PlacesSearchResult> places = [];
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  Future _checkGps() async {
    logindata = await SharedPreferences.getInstance();
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return PopDialog(
                  title: 'Location permission disabled',
                  content: 'You have to allow the location to access the map',
                  isWarning: false,
                  isButton: true,
                  onpressed: () async {
                    permission = await geo.Geolocator.requestPermission();
                    Navigator.pop(context);
                  });
            });
      }
    }
    await _getCurrentLocation();
  }

  _getCurrentLocation() {
    geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.best)
        .then((geo.Position position) async {
      await onstartadd(position);
      if (mounted) {
        setState(() {
          _currentPosition = position;
          addlat = position.latitude;
          addlong = position.longitude;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  onstartadd(geo.Position position) async {
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstt = addresses.first;
    if (mounted) {
      setState(() {
        addresspositon = firstt.addressLine;
      });
    }
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  void _setMarkers(LatLng point) async {
    final coordinates = new Coordinates(point.latitude, point.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstt = addresses.first;
    if (mounted) {
      MarkerId markerId = MarkerId(_markerIdVal());
      Marker marker = Marker(
        markerId: markerId,
        position: point,
        draggable: false,
        infoWindow: InfoWindow(title: addresspositon),
        visible: true,
      );
      setState(() {
        addresspositon = firstt.addressLine;
        addlat = point.latitude;
        addlong = point.longitude;
        _markers[markerId] = marker;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (mounted) {
      MarkerId markerId = MarkerId(_markerIdVal());
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        draggable: false,
      );
      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      LatLng pointlatlong = LatLng(lat, lng);
      final coordinates = new Coordinates(lat, lng);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var firstt = addresses.first;
      setState(() {
        addresspositon = firstt.addressLine;
        addlat = lat;
        addlong = lng;
        _markers.clear();
        _setMarkers(pointlatlong);
        mapController.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      });
    }
  }

  getLoc(lat, long) async {
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var firstt = addresses.first;
    setState(() {
      addlat = lat;
      addlong = long;
      addresspositon = firstt.addressLine;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Text('Set ${widget.toUpdate} address location',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: _currentPosition == null
          ? Loader()
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        _currentPosition.latitude, _currentPosition.longitude),
                    zoom: 18,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: Set<Marker>.of(_markers.values),
                  myLocationEnabled: true,
                  onTap: (point) {
                    setState(() {
                      _markers.clear();
                      _setMarkers(point);
                    });
                  },
                  onCameraMove: (CameraPosition position) {
                    if (_markers.length > 0) {
                      MarkerId markerId = MarkerId(_markerIdVal());
                      Marker marker = _markers[markerId];
                      Marker updatedMarker = marker.copyWith(
                        positionParam: position.target,
                      );
                      getLoc(position.target.latitude, position.target.longitude);
                      setState(() {
                        _markers[markerId] = updatedMarker;
                      });
                    }
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      Prediction p = await PlacesAutocomplete.show(
                          context: context, apiKey: Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);
                      displayPrediction(p, homeScaffoldKey.currentState);
                    },
                    child: Container(
                      width: 340.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.green)
                      ),
                      margin: EdgeInsets.only(top: 10.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 17.0, horizontal: 10.0),
                      child: Text(
                        addresspositon == null ? '' : addresspositon,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Align(
                //     // alignment: Alignment.center,
                //     child: Container(
                //         alignment: Alignment.centerRight,
                //         child: RaisedButton(
                //           onPressed: () async {
                //             Prediction p = await PlacesAutocomplete.show(
                //                 context: context, apiKey: kGoogleApiKey);
                //             displayPrediction(p, homeScaffoldKey.currentState);
                //           },
                //           child: Text('Find address'),
                //         ))),
              ],
            ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 85.0),
        child: FloatingActionButton(
          onPressed: () async {
            if (widget.toUpdate == 'home') {
              logindata.setString('homeUpdate', addresspositon);
              logindata.setDouble('homeLat', addlat);
              logindata.setDouble('homeLong', addlong);
            } else {
              logindata.setString('officeUpdate', addresspositon);
              logindata.setDouble('officeLat', addlat);
              logindata.setDouble('officeLong', addlong);
            }
            // 
            // condition for temporary address
            // 
            Navigator.pop(context, addresspositon);
          },
          backgroundColor: Colors.orange,
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
