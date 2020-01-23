import 'package:flutternotificationserviceapp/entities/address.dart';

class Order {
  String id;
  String status;
  String userId;
  String user;
  String driverId;
  String driver;
  Address address;

  Order(
      {this.id,
      this.status,
      this.userId,
      this.user,
      this.driverId,
      this.driver,
      this.address});
}
