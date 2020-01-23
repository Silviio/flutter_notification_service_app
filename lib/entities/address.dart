class Address {
  String thoroughfare;
  String subThoroughfare;
  String administrativeArea;
  String subAdministrativeArea;
  String subLocality;
  String postalCode;
  double latitude;
  double longitude;

  Address(
      {this.thoroughfare,
      this.subThoroughfare,
      this.administrativeArea,
      this.subAdministrativeArea,
      this.subLocality,
      this.postalCode,
      this.latitude,
      this.longitude});
}
