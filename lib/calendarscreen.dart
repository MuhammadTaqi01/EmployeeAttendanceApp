import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emplyee_attendance_system/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenWidth = 0;
  double screenHeight = 0;

  Color primary = const Color(0xff2196f3);

  String _month = DateFormat('MMMM').format(DateTime.now());

  get child => null;

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
              child: Text("My Attendance Status",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 32),
                  child: Text(_month,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth / 18,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 32),
                  child: GestureDetector(
                    onTap: () async{
                      final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                        //builder: (context, index){
                            // return Theme(
                            //     data: Theme.of(context).copyWith(
                            //       colorScheme: ColorScheme.light(
                            //         primary: primary,
                            //         secondary: primary,
                            //         onSecondary: Colors.white,
                            //       ),
                            //       textButtonTheme: TextButtonThemeData(
                            //         style: TextButton.styleFrom(
                            //           primary: primary,
                            //         )
                            //       ),
                            //     ),
                            // child: child!,
                            // );
                        //}
                      );

                      if(month != null){
                        setState(() {
                          _month = DateFormat('MMMM').format(month);
                        });
                      }

                    },
                    child: Text("Pick a Month",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: screenWidth / 18,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.45,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Employee").doc(User.id).collection("Record").snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasData){
                    final snap =  snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: snap.length,
                        itemBuilder: (context, index){
                        return DateFormat('MMMM').format(snap[index]['date'].toDate()) == _month ? Container(
                          margin: EdgeInsets.only(top: index > 0 ? 12 : 0, left: 6, right: 6),
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
                                  child: Container(
                                    margin: EdgeInsets.only(),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(DateFormat('EE\ndd').format(snap[index]['date'].toDate()),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth / 18,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),
                                  ),
                              ),
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
                                    Text(snap[index]['checkIn'],
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
                                    Text(snap[index]['checkOut'],
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
                        ) : SizedBox();
                    });
                  }
                  else{
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
