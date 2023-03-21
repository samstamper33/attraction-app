// To parse this JSON data, do
//
import 'dart:convert';

// final pointOfInterest = pointOfInterestFromJson(json);

PointOfInterest pointOfInterestFromJson(String str) => PointOfInterest.fromJson(json.decode(str));

String pointOfInterestToJson(PointOfInterest data) => json.encode(data.toJson());

class PointOfInterest {
    PointOfInterest({
        required this.response,
    });

    Response response;

    factory PointOfInterest.fromJson(Map<String, dynamic> json) => PointOfInterest(
        response: Response.fromJson(json["response"]),
    );

    Map<String, dynamic> toJson() => {
        "response": response.toJson(),
    };
}

class Response {
    Response({
        this.cursor,
        this.results,
        this.count,
        this.remaining,
    });

    int? cursor;
    List<Result>? results;
    int? count;
    int? remaining;

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        cursor: json["cursor"],
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        count: json["count"],
        remaining: json["remaining"],
    );

    Map<String, dynamic> toJson() => {
        "cursor": cursor,
        "results": List<dynamic>.from(results!.map((x) => x.toJson())),
        "count": count,
        "remaining": remaining,
    };
}

class Result {
    Result({
        this.description,
        this.name,
        this.mainImage,
        this.createdDate,
        this.createdBy,
        this.modifiedDate,
        this.poiType,
        required this.longitude,
        required this.latitude,
        this.markerImage,
        this.id,
        this.attraction,
        this.animalType,
        this.imageGallery,
        this.rideType,
    });

    String? description;
    String? name;
    String? mainImage;
    DateTime? createdDate;
    String? createdBy;
    DateTime? modifiedDate;
    String? poiType;
    double longitude;
    double latitude;
    String? markerImage;
    String? id;
    String? attraction;
    String? animalType;
    List<String>? imageGallery;
    String? rideType;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        description: json["Description"] == null ? null : json["Description"],
        name: json["Name"] == null ? null : json["Name"],
        mainImage: json["Main Image"] == null ? null : json["Main Image"],
        createdDate: DateTime.parse(json["Created Date"]),
        createdBy: json["Created By"],
        modifiedDate: DateTime.parse(json["Modified Date"]),
        poiType: json["POI Type"] == null ? null : json["POI Type"],
        longitude: json["Longitude"] == null ? null : json["Longitude"].toDouble(),
        latitude: json["Latitude"] == null ? null : json["Latitude"].toDouble(),
        markerImage: json["Marker Image"] == null ? null : json["Marker Image"],
        id: json["_id"],
        attraction: json["Attraction"] == null ? null : json["Attraction"],
        animalType: json["Animal Type"] == null ? null : json["Animal Type"],
        imageGallery: json["Image Gallery"] == null ? null : List<String>.from(json["Image Gallery"].map((x) => x)),
        rideType: json["Ride Type"] == null ? null : json["Ride Type"],
    );

    Map<String, dynamic> toJson() => {
        "Description": description == null ? null : description,
        "Name": name == null ? null : name,
        "Main Image": mainImage == null ? null : mainImage,
        "Created By": createdBy,
        "POI Type": poiType == null ? null : poiType,
        "Longitude": longitude == null ? null : longitude,
        "Latitude": latitude == null ? null : latitude,
        "Marker Image": markerImage == null ? null : markerImage,
        "_id": id,
        "Attraction": attraction == null ? null : attraction,
        "Animal Type": animalType == null ? null : animalType,
        "Image Gallery": imageGallery == null ? List<dynamic>.from(imageGallery!.map((x) => x)) : [],
        "Ride Type": rideType == null ? null : rideType,
    };
}
