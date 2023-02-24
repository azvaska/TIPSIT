import 'package:geocoding/geocoding.dart';

String address_serializer(Placemark placeMark) {
  String name = placeMark.street!;
  String ncivico = placeMark.subThoroughfare!;
  String locality = placeMark.locality!;
  String administrativeArea = placeMark.administrativeArea!;
  String postalCode = placeMark.postalCode!;
  String country = placeMark.country!;
  String addressStr =
      "$name $ncivico, $locality, $administrativeArea $postalCode, $country";
  return addressStr;
}
