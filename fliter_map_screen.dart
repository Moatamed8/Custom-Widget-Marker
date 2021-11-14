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
  bool isSelecting = false;
  var location;
  BitmapDescriptor customIcon;
  final Set<Marker> markers = new Set();
  List<Marker> listMarkers = [];

  @override
  void didChangeDependencies() async {
    location = await Location().getLocation();
    super.didChangeDependencies();
  }

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
      body: NetworkProvider.of(context, listen: true).isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                  ),
                  Positioned(
                    bottom: 25,
                    right: 0,
                    left: 20,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(""),
                              CustomIcon(
                                icon: "assets/icons/ic_current_location.svg",
                                color: Colors.white,
                                function: getMyLocation,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 150,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: NetworkProvider.of(context)
                                  .filterdList
                                  .length,
                              itemBuilder: (context, index) => Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _mapcontroller.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                    NetworkProvider.of(context)
                                                        .filterdList[index]
                                                        .latitude,
                                                    NetworkProvider.of(context)
                                                        .filterdList[index]
                                                        .longitude),
                                                zoom: 14.7),
                                          ));
                                        },
                                        child: Container(
                                          height: 121.h,
                                          padding: EdgeInsets.only(
                                              top: 20,
                                              bottom: 20,
                                              right: 16,
                                              left: 16),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 64, 128, 0.04),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5)),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 64.w,
                                                    width: 64.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              17.5),
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJZG-8Pk5VYr_MOP4Ks3uEeZdArTUAizNRwg&usqp=CAU',
                                                          ),
                                                          fit: BoxFit.fill),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Container(
                                                      height: 10.w,
                                                      width: 10.w,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: ColorsUtils
                                                              .greenBorder,
                                                          border: Border.all(
                                                              width: 0.8,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 24.w,
                                                      height: 24.w,
                                                      decoration: BoxDecoration(
                                                        color: ColorsUtils
                                                            .starColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7.5),
                                                      ),
                                                      child: Icon(
                                                        Icons.people,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                  width: ScreenUtil()
                                                      .setWidth(17)),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${NetworkProvider.of(context).filterdList[index].name}",
                                                    style: TextStyle(
                                                        color: ColorsUtils
                                                            .blueColor,
                                                        fontSize: ScreenUtil()
                                                            .setSp(15),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'Bahij'),
                                                  ),
                                                  Container(
                                                    width: 190,
                                                    child: Text(
                                                      "${NetworkProvider.of(context).filterdList[index].jobTitle}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: ColorsUtils
                                                              .textGrey,
                                                          fontSize: ScreenUtil()
                                                              .setSp(13),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'Bahij'),
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      // STAR
                                                      Container(
                                                        width: 12.w,
                                                        height: 12.w,
                                                        child: Icon(
                                                          Icons.star,
                                                          color: ColorsUtils
                                                              .starColor,
                                                          size: 12,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(5)),

                                                      Text(
                                                        "${NetworkProvider.of(context).filterdList[index].rating}",
                                                        style: TextStyle(
                                                            color: ColorsUtils
                                                                .textGrey,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(12),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Bahij'),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(5)),

                                                      Text(
                                                        '(${NetworkProvider.of(context).filterdList[index].rating} ' +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "reviews") +
                                                            ')',
                                                        style: TextStyle(
                                                            color: ColorsUtils
                                                                .textGrey,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(12),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontFamily:
                                                                'Bahij'),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    width: 190,
                                                    child: Text(
                                                      "${NetworkProvider.of(context).filterdList[index].address}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: ColorsUtils
                                                              .textGrey,
                                                          fontSize: ScreenUtil()
                                                              .setSp(13),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'Bahij'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                    ],
                                  )),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    left: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            CustomFunctions.popScreen(context);
                          },
                          child: Container(
                              //margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: ColorsUtils.lightColorBorder,
                                      width: 1.sp),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: ColorsUtils.darkBlue,
                                size: 25.sp,
                              )),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                              //margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: ColorsUtils.starColor,
                                  border: Border.all(
                                      color: ColorsUtils.lightColorBorder,
                                      width: 1.sp),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Transform.scale(
                                scale: .75,
                                child: SvgPicture.asset(
                                  "assets/icons/ic_filter.svg",
                                  color: Colors.white,
                                  width: 15.sp,
                                  height: 15.sp,
                                ),
                              )),
                        )
                      ],
                    ),
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

  Widget _getMarkerWidget(FilterData myData) {
    return CustomMarkerMap(myData);
  }

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
