import 'dart:convert';

class CheckIn {
  int projectId;
  String location;
  // File image;
  String image;
  String fbtoken;
  Geolocation geolocation;
  double lat;
  double long;

  CheckIn(
      {this.projectId,
      this.location,
      this.image,
      this.fbtoken,
      this.geolocation});

  factory CheckIn.fromJson(Map<String, dynamic> map) {
    return CheckIn(
        projectId: map["project_id"],
        location: map["location"],
        image: map["image"],
        fbtoken: map["firebase_token"],
        geolocation: Geolocation.fromJson(map["geolocation"]));
  }

  // factory CheckIn.fromJson(dynamic json) {
  //   return Tutorial(json['title'] as String, json['description'] as String, User.fromJson(json['author']));
  // }

  Map<String, dynamic> toJson() {
    return {
      "project_id": projectId,
      "location": location,
      "image": image,
      "firebase_token": fbtoken,
      "geolocation": geolocation
    };
  }

  @override
  String toString() {
    return "{project_id: $projectId, location: $location, image: $image, firebase_token: $fbtoken, geolocation: $geolocation}";
  }
}

class Geolocation {
  double lat;
  double long;

  Geolocation({this.lat, this.long});

  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      lat: json["lat"],
      long: json["long"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "long": long,
    };
  }

  @override
  String toString() {
    return "{lat: $lat, long: $long}";
  }
}

List<CheckIn> checkInFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<CheckIn>.from(data.map((item) => CheckIn.fromJson(item)));
}

String checkInToJson(CheckIn data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
