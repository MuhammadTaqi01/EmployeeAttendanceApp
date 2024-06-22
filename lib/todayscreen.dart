import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emplyee_attendance_system/model/user.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenWidth = 0;
  double screenHeight = 0;

  String checkIn = "__/__";
  String checkOut = "__/__";
  String location = " ";

  Color primary = const Color(0xff2196f3);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRecord();
  }

  void _getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location = "${placemark[0].street},${placemark[0].administrativeArea},${placemark[0].postalCode},${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try{
      QuerySnapshot snap =  await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    }
    catch(e){
      setState(() {
        checkIn = "__/__";
        checkOut = "__/__";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text("Welcome",
              style: TextStyle(
                color: Colors.black54,
                fontSize: screenWidth / 20,
                fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(User.employeeId,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text("Today's Status",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 32),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2,2)
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Check In",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth / 20,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(checkIn,
                          style: TextStyle(
                              fontSize: screenWidth / 18,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Check Out",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(checkOut,
                          style: TextStyle(
                              fontSize: screenWidth / 18,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: DateTime.now().day.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth / 18
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth / 18
                      )
                    )
                  ]
                ),
              )
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm:ss a').format(DateTime.now()),
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth / 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                );
              }
            ),
            checkOut == "__/__" ?  Container(
              margin: EdgeInsets.only(top: 24, bottom: 12),
              child: Builder(builder: (context){
                final GlobalKey<SlideActionState> key = GlobalKey();
                return SlideAction(
                  text: checkIn == "__/__" ? "Slide to Check In" : "Slide to Check Out",
                  textStyle: TextStyle(
                    fontSize: screenWidth / 18,
                    color: Colors.black
                  ),
                  outerColor: Colors.white,
                  innerColor: primary,
                  key: key,
                  onSubmit: () async{
                    if(User.lat != 0){
                      _getLocation();

                      QuerySnapshot snap =  await FirebaseFirestore.instance
                          .collection("Employee")
                          .where('id', isEqualTo: User.employeeId)
                          .get();

                      DocumentSnapshot snap2 = await FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(snap.docs[0].id)
                          .collection("Record")
                          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                          .get();

                      try{
                        String checkIn = snap2['checkIn'];

                        setState(() {
                          checkOut = DateFormat('hh:mm').format(DateTime.now());
                        });

                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                            .update({
                          'date' : Timestamp.now(),
                          'checkIn' : checkIn,
                          'checkOut' : DateFormat('hh:mm').format(DateTime.now()),
                          'checkInLocation' : location,
                        });
                      }
                      catch(e){
                        setState(() {
                          checkIn = DateFormat('hh:mm').format(DateTime.now());
                        });
                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                            .set({
                          'date' : Timestamp.now(),
                          'checkIn' : DateFormat('hh:mm').format(DateTime.now()),
                          'checkOut' : "__/__",
                          'checkOutLocation' : location,
                        });
                      }
                      key.currentState!.reset();
                    }
                    else{
                      Timer(Duration(seconds: 3), () async {
                        _getLocation();

                        QuerySnapshot snap =  await FirebaseFirestore.instance
                            .collection("Employee")
                            .where('id', isEqualTo: User.employeeId)
                            .get();

                        DocumentSnapshot snap2 = await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                            .get();

                        try{
                          String checkIn = snap2['checkIn'];

                          setState(() {
                            checkOut = DateFormat('hh:mm').format(DateTime.now());
                          });

                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .update({
                            'date' : Timestamp.now(),
                            'checkIn' : checkIn,
                            'checkOut' : DateFormat('hh:mm').format(DateTime.now()),
                            'checkInLocation' : location,
                          });
                        }
                        catch(e){
                          setState(() {
                            checkIn = DateFormat('hh:mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .set({
                            'date' : Timestamp.now(),
                            'checkIn' : DateFormat('hh:mm').format(DateTime.now()),
                            'checkOut' : "__/__",
                            'checkOutLocation' : location,
                          });
                        }
                        key.currentState!.reset();
                      });
                    }
                  },
                );
              },
              ),
            ) : Container(
              margin: EdgeInsets.only(top: 32, bottom: 32),
              child: Text('You have completed this day!',
              style: TextStyle(
                fontSize: screenWidth / 20,
                fontWeight: FontWeight.w500,
                color: Colors.black54
              ),),
            ),
            location != " " ? Text(
              "Location: " + location
            ) : const SizedBox(),
          ],
        ),
      )
    );
  }
}
