import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:reaaia/model/myNetwok/fliter_user_model.dart';
import 'package:reaaia/screens/myNetwork/component/custom_marker_generator.dart';
import 'package:reaaia/utils/ColorsUtils.dart';
import 'package:reaaia/viewModels/locale/appLocalization.dart';
import 'package:reaaia/viewModels/myNetworkProvider/my_network_provider.dart';
import '../customFunctions.dart';
import 'component/widget/custom_marker.dart';
import 'component/widget/icon_widget.dart';

import 'dart:typed_data';

class FliterMapScreen extends StatefulWidget {
  @override
  _FliterMapScreenState createState() => _FliterMapScreenState();
}

class _FliterMapScreenState extends State<FliterMapScreen> {
  GoogleMapController _mapcontroller;
  LatLng latLng;

  BitmapDescriptor customIcon;
  final Set<Marker> markers = new Set();
  List<Marker> listMarkers = [];

  

  @override
  void initState() {
    getNearbyServiceProviders();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
            'assets/icons/ic_pin_location.png')
        .then((d) {
      customIcon = d;
    });
    super.initState();
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.1232333, 30.123123),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtils.greyColor,
      body: Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      markers: listMarkers.toSet(),
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      myLocationEnabled: true,
                      mapToolbarEnabled: false,
                      onTap: (val) {
                        setState(() {
                          latLng = val;
                          print("${latLng.latitude}");
                          print("${latLng.longitude}");
                        });
                      },
                      onMapCreated: onMapCreated,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                 ],
              ),
            ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      _mapcontroller = controller;
    });
  }

  getMyLocation() async {
    var mylocation = await Location().getLocation();
    _mapcontroller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(mylocation.latitude, mylocation.longitude),
          zoom: 14.7),
    ));
  }
// get list of marker from api 
  Set<Marker> getMarkers() {
    setState(() {
      for (int i = 0; i < NetworkProvider.of(context).filterdList.length; i++) {
        markers.add(Marker(
          markerId: MarkerId(LatLng(
                  NetworkProvider.of(context).filterdList[i].latitude,
                  NetworkProvider.of(context).filterdList[i].longitude)
              .toString()),
          position: LatLng(NetworkProvider.of(context).filterdList[i].latitude,
              NetworkProvider.of(context).filterdList[i].longitude),
          infoWindow: InfoWindow(
            title: NetworkProvider.of(context).filterdList[i].name,
            snippet: NetworkProvider.of(context).filterdList[i].mobileNumber,
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
      }
    });
    return markers;
  }
// maeker Generator to generate markers 
  void getNearbyServiceProviders() async {
    await NetworkProvider.of(context).getFlitered(context,
        lat: "30.17957524640885", lng: "31.343290731310844");
    if (NetworkProvider.of(context).filterdList != null) {
      MarkerGenerator(markerWidgets(NetworkProvider.of(context).filterdList),
          (bitmaps) {
        setState(() {
          listMarkers = mapBitmapsToMarkers(
              NetworkProvider.of(context).filterdList, bitmaps);
        });
      }).generate(context);
    }
  }

  List<Widget> markerWidgets(List myDta) {
    return NetworkProvider.of(context)
        .filterdList
        .map(_getMarkerWidget)
        .toList();
  }
///// Your Custom marker Widget 
  Widget _getMarkerWidget(FilterData myData) {
    return CustomMarkerMap(myData);
  }
// when you need widget marker it should convert to put in map so u should use this function
  List<Marker> mapBitmapsToMarkers(List myData, List<Uint8List> bitmaps) {
    final markersList = <Marker>[];
    bitmaps.asMap().forEach((i, bmp) {
      final s = NetworkProvider.of(context).filterdList[i];
      if (s.latitude != null) {
        markersList.add(Marker(
          markerId: MarkerId(
              LatLng(31.117391961501337, 30.117905102670193).toString()),
          position: LatLng(31.117391961501337, 30.117905102670193),
          icon: customIcon,
        ));
        markersList.add(Marker(
            onTap: () {
              _mapcontroller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(
                        NetworkProvider.of(context).filterdList[i].latitude,
                        NetworkProvider.of(context).filterdList[i].longitude),
                    zoom: 14.7),
              ));
            },
            markerId: MarkerId(LatLng(
                    NetworkProvider.of(context).filterdList[i].latitude,
                    NetworkProvider.of(context).filterdList[i].longitude)
                .toString()),
            position: LatLng(
                NetworkProvider.of(context).filterdList[i].latitude,
                NetworkProvider.of(context).filterdList[i].longitude),
            infoWindow: InfoWindow(
              title: NetworkProvider.of(context).filterdList[i].name,
              snippet: NetworkProvider.of(context).filterdList[i].mobileNumber,
            ),
            anchor: const Offset(0.5, 1),
            icon: BitmapDescriptor.fromBytes(bmp)));
      }
    });
    return markersList;
  }
}
