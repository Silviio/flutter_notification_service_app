import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutternotificationserviceapp/constants/component.dart';
import 'package:flutternotificationserviceapp/constants/order_status.dart';
import 'package:flutternotificationserviceapp/constants/string_value.dart';
import 'package:flutternotificationserviceapp/entities/address.dart';
import 'package:flutternotificationserviceapp/entities/order.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_services.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_store.dart';
import 'package:flutternotificationserviceapp/widgets/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const kRoute = '/home';

  @override
  State<StatefulWidget> createState() => _HomeScreenSate();
}

class _HomeScreenSate extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firebaseService = FirebaseService();
  final _firebaseStore = FirebaseStore();

  Map<PermissionGroup, PermissionStatus> permissions;
  bool _hasPermissions = false;

  Future<bool> _futureResult;

  StreamSubscription<DocumentSnapshot> _snap;

  Completer<GoogleMapController> _controller = Completer();

  AnimationController _animationController;
  FirebaseUser _user;

  //Initial Position
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-21.7946, -48.1766), zoom: 19);

  TextEditingController _orderServiceTextEditingController =
      TextEditingController();

  Set<Marker> _markers;
  Set<Circle> _circles;

  List<String> _menuItems = [Strings.logout];
  bool _hasNotYetOrdered = true;

  @override
  void initState() {
    super.initState();
    _markers = Set<Marker>();
    _circles = Set<Circle>();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _futureResult = _checkCurrentUser();
  }

  @override
  void dispose() {
    _orderServiceTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(Strings.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _onMenuItemSelected,
            itemBuilder: (context) {
              return _menuItems.map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList();
            },
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _futureResult,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: _hasPermissions
                  ? Stack(
                      children: <Widget>[
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          markers: _markers,
                          circles: _circles,
                        ),
                        Visibility(
                          visible: _hasNotYetOrdered,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    child: TextField(
                                      readOnly: true,
                                      decoration: kTextFieldDecoration.copyWith(
                                        icon: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(20, 0, 0, 12),
                                          width: 10,
                                          height: 10,
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                          ),
                                        ),
                                        hintText: "Meu local",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 55,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    child: TextField(
                                      controller:
                                          _orderServiceTextEditingController,
                                      decoration: kTextFieldDecoration.copyWith(
                                        icon: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(20, 0, 0, 12),
                                          width: 10,
                                          height: 10,
                                          child: Icon(
                                            Icons.local_taxi,
                                            color: Colors.black,
                                          ),
                                        ),
                                        hintText: "Definir outro local",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          left: 0,
                          bottom: 0,
                          child: Padding(
                              padding: Platform.isIOS
                                  ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                                  : EdgeInsets.all(10),
                              child: _getWidgetAccordingToStatus()),
                        )
                      ],
                    )
                  : _getWidgetPermission(),
            );
          },
        ),
      ),
    );
  }

  _showMarkers(Position position) async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
                devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
            Strings.imageMarker)
        .then((BitmapDescriptor icon) {
      Marker marker = Marker(
          markerId: MarkerId('Meu Id'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: "Meu Local Atual"),
          icon: icon);

      _markers.add(marker);
    });
  }

  _moveCamera(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _onMenuItemSelected(String itemSelected) {
    switch (itemSelected) {
      case Strings.logout:
        _firebaseService.signOut();
        Navigator.pushReplacementNamed(context, LoginScreen.kRoute);
        break;
    }
  }

  _getLastPosition() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if (position != null) {
        _showMarkers(position);
        _showCircles(position);
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);

        _moveCamera(_cameraPosition);
      }
    });
  }

  _showCircles(Position position) {
    Circle circle = Circle(
        circleId: CircleId('userId'),
        center: LatLng(position.latitude, position.longitude),
        radius: 40,
        strokeColor: Color(0xff40739e).withOpacity(0.5),
        fillColor: Color(0xff40739e).withOpacity(0.1),
        strokeWidth: 10);

    _circles.add(circle);
  }

  _subscriberToUserLocation() {
    var geolocator = Geolocator();

    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    setState(() {
      geolocator.getPositionStream(locationOptions).listen((Position position) {
        _showMarkers(position);
        _moveCamera(_cameraPosition);
      });
    });
  }

  _orderService() async {
    String newAddress = _orderServiceTextEditingController.text;

    if (newAddress.isEmpty) {
      _showSnackBar(Strings.warningEmptyField);
      return;
    }

    List<Placemark> addressList =
        await Geolocator().placemarkFromAddress(newAddress);

    if (addressList != null && addressList.length > 0) {
      Placemark closestAddress = addressList[0];

      Address address = Address(
          administrativeArea: closestAddress.administrativeArea,
          subAdministrativeArea: closestAddress.subAdministrativeArea,
          postalCode: closestAddress.postalCode,
          subLocality: closestAddress.subLocality,
          thoroughfare: closestAddress.thoroughfare,
          subThoroughfare: closestAddress.subThoroughfare,
          latitude: closestAddress.position.latitude,
          longitude: closestAddress.position.longitude);

      String confirmationDialog;

      confirmationDialog = "\n Estado ${address.administrativeArea}";
      confirmationDialog += "\n Cidade ${address.subAdministrativeArea}";
      confirmationDialog += "\n ${address.thoroughfare}";
      confirmationDialog += "\n Número ${address.subThoroughfare}";

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Confirmação do endereço"),
              content: Text(confirmationDialog),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              contentPadding: EdgeInsets.all(16),
              actions: <Widget>[
                FlatButton(
                    child:
                        Text("CANCELAR", style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: Text("CONFIRMAR",
                        style: TextStyle(color: Colors.green)),
                    onPressed: () {
                      _saveOrder(address);
                      Navigator.pop(context);
                    }),
              ],
            );
          });
    }
  }

  void _saveOrder(Address orderAddress) {
    Order order = Order(
        id: '',
        userId: _user.uid,
        user: _user.email,
        driverId: '',
        driver: '',
        status: OrderStatus.OPEN,
        address: orderAddress);

    _firebaseStore.saveOrder(order);

    _showSnackBar("Obrigado! O motoboy já foi notificado");

    setState(() {
      _hasNotYetOrdered = false;
    });
  }

  _showSnackBar(String message) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.black45,
      duration: Duration(seconds: 2, milliseconds: 50),
      action: SnackBarAction(
        label: Strings.close,
        textColor: Colors.yellow,
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    ));
  }

  _getCurrentUserOrderStatus() async {
    var currentOrderId =
        await _firebaseStore.getCurrentOpenOrderIdByUserId(_user.uid);

    if (currentOrderId != null) {
      _snap = _firebaseStore.subscribeToOrderById(currentOrderId);

      _snap.onData((order) {
        setState(() {
          if (order.data != null) {
            switch (order.data['status']) {
              case OrderStatus.OPEN:
                _orderOpen();
                break;

              case OrderStatus.CANCELED:
                _orderClosed(_snap);
                break;
            }
          }
        });
      });
    }
  }

  _orderOpen() {
    _hasNotYetOrdered = false;
  }

  _orderClosed(StreamSubscription<DocumentSnapshot> snap) {
    snap.cancel();
    _hasNotYetOrdered = true;
  }

  Widget _getWidgetAccordingToStatus() {
    if (_hasNotYetOrdered) {
      return AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: GestureDetector(
          onTap: _orderService,
          child: AnimatedButton(
              color: Color(0xff487eb0),
              controller: _animationController.view,
              buttonTitle: 'Notificar Motoboy',
              fontSize: 20.0,
              startWidth: MediaQuery.of(context).size.width),
        ),
      );
    } else {
      return AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: GestureDetector(
          onTap: _cancelOrder,
          child: AnimatedButton(
              color: Color(0xff487eb0),
              controller: _animationController.view,
              buttonTitle: 'Cancelar Pedido',
              fontSize: 20.0,
              startWidth: MediaQuery.of(context).size.width),
        ),
      );
    }
  }

  _cancelOrder() {
    setState(() {
      _firebaseStore.updateCurrentUserOrderWithStatus(
        _user.uid,
        OrderStatus.CANCELED,
      );
      _hasNotYetOrdered = true;
    });
  }

  Future<bool> _checkCurrentUser() async {
    _user = await _firebaseService.getCurrentUser();

    if (_user != null) {
      await _getCurrentUserOrderStatus();
      await _checkCurrentPermissionStatus();
      return true;
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.kRoute);
      return false;
    }
  }

  _checkCurrentPermissionStatus() async {
    //CheckingPermission

    PermissionStatus permission = await _getCurrentPermissionStatus();

    if (permission == PermissionStatus.granted) {
      _subscriberToPositionChanges();
    } else {
      //AskForPermission
      permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.locationWhenInUse]);

      permission = await _getCurrentPermissionStatus();

      if (permission == PermissionStatus.granted)
        _subscriberToPositionChanges();
    }
  }

  _subscriberToPositionChanges() {
    setState(() {
      _hasPermissions = true;
      _getLastPosition();
      _subscriberToUserLocation();
    });
  }

  _getCurrentPermissionStatus() async {
    return PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
  }

  Widget _getWidgetPermission() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              Strings.askForPermission,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
            ),
            SizedBox(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () async {
                bool isOpened = await PermissionHandler().openAppSettings();

                if (isOpened) _checkCurrentPermissionStatus();
              },
              child: Material(
                  elevation: 5.0,
                  color: Color(0xff40739e),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 48.0,
                    child: Center(
                        child: Text(Strings.openSettings,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold))),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
