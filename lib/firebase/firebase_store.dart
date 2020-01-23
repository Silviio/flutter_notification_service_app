import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutternotificationserviceapp/constants/order_status.dart';
import 'package:flutternotificationserviceapp/entities/order.dart';

class FirebaseStore {
  final Firestore _db = Firestore.instance;

  void saveUser(FirebaseUser firebaseUser) {
    try {
      _db
          .collection("users")
          .document(firebaseUser.uid)
          .setData({"email": firebaseUser.email});
    } catch (e) {
      print(e);
    }
  }

  void saveOrder(Order order) {
    try {
      var orderDocument = _db.collection("orders").document();

      orderDocument.setData({
        'orderId': orderDocument.documentID,
        'status': order.status,
        'userId': order.userId,
        'user': order.user,
        'driverId': order.driverId,
        'driver': order.driver,
        'state': order.address.administrativeArea,
        'city': order.address.subAdministrativeArea,
        'street': order.address.thoroughfare,
        'number': order.address.subThoroughfare
      });
    } catch (e) {}
  }

  getCurrentOpenOrderIdByUserId(userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: OrderStatus.OPEN)
          .getDocuments();

      var idCurrentOrder = snapshot.documents[0]['orderId'].toString();

      return idCurrentOrder;
    } catch (e) {}
  }

  updateCurrentUserOrderWithStatus(userId, status) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: OrderStatus.OPEN)
          .getDocuments();

      snapshot.documents[0].reference.updateData({'status': status});
    } catch (e) {}
  }

  subscribeToOrderById(currentOrderId) {
    return _db
        .collection('orders')
        .reference()
        .document(currentOrderId)
        .snapshots()
        .listen((_) {});
  }
}
