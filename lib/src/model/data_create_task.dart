import 'dart:convert';
import 'package:attendance/src/model/data_checkin.dart';

class DataTask {
  String title;
  String startTime;
  String endTime;
  String type;
  String note;
  Geolocation geolocation;
  String location;

  DataTask({this.title, this.startTime, this.endTime, this.type, this.note, this.geolocation, this.location});

  factory DataTask.fromJson(Map<String, dynamic> map) {
    return DataTask(
      title: map["title"],
      startTime: map["start_time"],
      endTime: map["end_time"],
      type: map["type"],
      note: map["note"],
      location: map["location"],
      geolocation: Geolocation.fromJson(map["geolocation"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "start_time": startTime,
      "end_time": endTime,
      "type": type,
      "note": note,
      "location": location,
      "geolocation": geolocation
    };
  }

  @override
  String toString() {
    return "{title: $title, start_time: $startTime, end_time: $endTime, type: $type, note: $note, location: $location, geolocation: $geolocation}";
  }
}

List<DataTask> taskFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataTask>.from(data.map((item) => DataTask.fromJson(item)));
}

String taskToJson(DataTask data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
