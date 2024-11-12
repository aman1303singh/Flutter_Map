// To parse this JSON data, do
//
//     final myLocationModel = myLocationModelFromJson(jsonString);

import 'dart:convert';

List<MyLocationModel> myLocationModelFromJson(String str) => List<MyLocationModel>.from(json.decode(str).map((x) => MyLocationModel.fromJson(x)));

String myLocationModelToJson(List<MyLocationModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyLocationModel {
    double latitude;
    double longitude;
    Type type;
    double distance;
    String name;
    String? number;
    String? postalCode;
    String? street;
    double confidence;
    Locality region;
    RegionCode regionCode;
    County county;
    Locality locality;
    dynamic administrativeArea;
    Neighbourhood neighbourhood;
    Country country;
    CountryCode countryCode;
    Continent continent;
    String label;

    MyLocationModel({
        required this.latitude,
        required this.longitude,
        required this.type,
        required this.distance,
        required this.name,
        required this.number,
        required this.postalCode,
        required this.street,
        required this.confidence,
        required this.region,
        required this.regionCode,
        required this.county,
        required this.locality,
        required this.administrativeArea,
        required this.neighbourhood,
        required this.country,
        required this.countryCode,
        required this.continent,
        required this.label,
    });

    factory MyLocationModel.fromJson(Map<String, dynamic> json) => MyLocationModel(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        type: typeValues.map[json["type"]]!,
        distance: json["distance"]?.toDouble(),
        name: json["name"],
        number: json["number"],
        postalCode: json["postal_code"],
        street: json["street"],
        confidence: json["confidence"]?.toDouble(),
        region: localityValues.map[json["region"]]!,
        regionCode: regionCodeValues.map[json["region_code"]]!,
        county: countyValues.map[json["county"]]!,
        locality: localityValues.map[json["locality"]]!,
        administrativeArea: json["administrative_area"],
        neighbourhood: neighbourhoodValues.map[json["neighbourhood"]]!,
        country: countryValues.map[json["country"]]!,
        countryCode: countryCodeValues.map[json["country_code"]]!,
        continent: continentValues.map[json["continent"]]!,
        label: json["label"],
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "type": typeValues.reverse[type],
        "distance": distance,
        "name": name,
        "number": number,
        "postal_code": postalCode,
        "street": street,
        "confidence": confidence,
        "region": localityValues.reverse[region],
        "region_code": regionCodeValues.reverse[regionCode],
        "county": countyValues.reverse[county],
        "locality": localityValues.reverse[locality],
        "administrative_area": administrativeArea,
        "neighbourhood": neighbourhoodValues.reverse[neighbourhood],
        "country": countryValues.reverse[country],
        "country_code": countryCodeValues.reverse[countryCode],
        "continent": continentValues.reverse[continent],
        "label": label,
    };
}

enum Continent {
    NORTH_AMERICA
}

final continentValues = EnumValues({
    "North America": Continent.NORTH_AMERICA
});

enum Country {
    UNITED_STATES
}

final countryValues = EnumValues({
    "United States": Country.UNITED_STATES
});

enum CountryCode {
    USA
}

final countryCodeValues = EnumValues({
    "USA": CountryCode.USA
});

enum County {
    NEW_YORK_COUNTY
}

final countyValues = EnumValues({
    "New York County": County.NEW_YORK_COUNTY
});

enum Locality {
    NEW_YORK
}

final localityValues = EnumValues({
    "New York": Locality.NEW_YORK
});

enum Neighbourhood {
    MIDTOWN_EAST,
    MIDTOWN_WEST,
    UPPER_EAST_SIDE
}

final neighbourhoodValues = EnumValues({
    "Midtown East": Neighbourhood.MIDTOWN_EAST,
    "Midtown West": Neighbourhood.MIDTOWN_WEST,
    "Upper East Side": Neighbourhood.UPPER_EAST_SIDE
});

enum RegionCode {
    NY
}

final regionCodeValues = EnumValues({
    "NY": RegionCode.NY
});

enum Type {
    ADDRESS,
    VENUE
}

final typeValues = EnumValues({
    "address": Type.ADDRESS,
    "venue": Type.VENUE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
