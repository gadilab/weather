import 'dart:convert';

ModelCuaca modelCuacaFromJson(String str) =>
    ModelCuaca.fromJson(json.decode(str));

class ModelCuaca {
  List<Result> results;

  ModelCuaca({required this.results});

  factory ModelCuaca.fromJson(Map<String, dynamic> json) => ModelCuaca(
    results: json["results"] == null
        ? []
        : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
  );
}

class Result {
  int id;
  String name;
  double latitude;
  double longitude;
  String country;
  String admin1;

  Result({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.admin1,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
    longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    country: json["country"] ?? '-',
    admin1: json["admin1"] ?? '-',
  );
}
