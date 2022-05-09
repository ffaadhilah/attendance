import 'dart:convert';

class DataHeader {
  String contenttype;
  String token;
  // Digest signature;
  String signature;
  String timestamp;

  DataHeader({this.contenttype, this.token, this.signature, this.timestamp});

  factory DataHeader.fromJson(Map<String, dynamic> map) {
    return DataHeader(
        token: map["token"],
        signature: map["signature"],
        timestamp: map["timestamp"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "signature": signature,
      "timestamp": timestamp,
    };
  }

  @override
  String toString() {
    return "{token: $token, signature: $signature, timestamp: $timestamp}";
  }
}

List<DataHeader> headerFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataHeader>.from(data.map((item) => DataHeader.fromJson(item)));
}

String headerToJson(DataHeader data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
