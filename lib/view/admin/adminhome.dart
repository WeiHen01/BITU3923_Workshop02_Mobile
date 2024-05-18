import 'package:animations/animations.dart';
import 'package:bitu3923_group05/models/company.dart';
import 'package:bitu3923_group05/models/user.dart';
import 'package:bitu3923_group05/view/user/JobApplicationView.dart';
import 'package:bitu3923_group05/view/admin/adminjobdescview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/job_apply.dart';


/**
 * Here is the home page
 * after user login successfully
 */


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  User? _user;
  int userid = 0;
  Future<void> getUser() async {

    final response = await http.get(Uri.parse('http://10.0.2.2:8080/inployed/user/account/${widget.username}'));

    if (response.statusCode == 200) {

      // Parse the JSON response into a `User` object.
      final user = User.fromJson(jsonDecode(response.body));

      setState(() {
        _user = user;
        userid = user.userId;
        // getJobApply(userid);
      });
    } else {
      throw Exception('Failed to fetch user');
    }
  }


  late List<Advertisement> advertisements = [];

  Future<void> getAdvertisement() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        advertisements = data.map((json) => Advertisement.fromJson(json)).toList();
      });
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
    } else {
      throw Exception('Failed to fetch job');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getAdvertisement();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: AppBar(
              //disable leading on appBar
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(249, 151, 119, 1),
                        Color.fromRGBO(98, 58, 162, 1),// #a6c1ee
                      ],
                    )
                ),
              ),

              title: Image.asset('images/logo_admin.png',
                width: 140, height: 50,
              ),
            ),
            body: advertisements != null
                ? Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                  color: Color(0xFFA6C1EE),
                ),
                  child: RefreshIndicator(
                    onRefresh: () async{
                      await Future.delayed(Duration(seconds: 2));
                      getAdvertisement();
                      _scrollController.animateTo(
                        -100.0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Dashboard",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                )
                            ),
                          ],
                        ),

                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: advertisements.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final ad = advertisements[index];
                              return OpenContainer(
                                closedColor: Color(0xFFA6C1EE),
                                transitionType: ContainerTransitionType.fade,
                                transitionDuration: Duration(seconds: 1),
                                closedBuilder: (context, _) => Card(
                                  elevation: 4,
                                  margin: EdgeInsets.only(
                                      left: 10, top: 10, bottom: 90, right: 10
                                  ),
                                  child: Container(
                                      height: 500,
                                      padding: EdgeInsets.all(15),
                                      width: 290,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white54,
                                        ),
                                        child: Column(
                                          children: [

                                            Text(advertisements.isNotEmpty ? ad.company.companyName : '',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                )
                                            ),

                                            Row(
                                              children: [
                                                SizedBox(height: 10),
                                              ],
                                            ),

                                            Table(
                                              children: [
                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Text(ad.jobPosition,
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20, color: Color(0xFF0F5DE6),
                                                          )
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                        child: Container(
                                                            height: 20
                                                        )
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Text(ad.jobDescription,
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15
                                                        ),
                                                        textAlign: TextAlign.justify,
                                                        maxLines: 5, // Set the maximum number of lines
                                                        overflow: TextOverflow.ellipsis,
                                                      ),

                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            Spacer(),

                                            Table(
                                              columnWidths: {
                                                0: FixedColumnWidth(30), // Adjust the width as needed
                                                1: FlexColumnWidth(), // Flexible width// Width based on content
                                              },
                                              children: [
                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Icon(Icons.monetization_on)
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(ad.salary,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 18
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Icon(Icons.timelapse),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(ad.jobTime,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 18
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Icon(Icons.calendar_view_day),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(ad.jobDate,
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 18
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Icon(Icons.location_on),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text("${ad.company.companyCity}, "
                                                            "${ad.company.companyState},"
                                                            "${ad.company.companyCountry}",
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 18
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Icon(Icons.history),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Expanded(
                                                            child: Text(ad.jobCommit,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 18
                                                              ), textAlign: TextAlign.justify,
                                                              // Set the maximum number of lines
                                                              maxLines: 3,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          )
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            Spacer(),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [

                                                SizedBox(width: 10),
                                                InkWell(
                                                  onTap: ()
                                                  {
                                                    /**
                                                     * Navigate to login() function
                                                     * for web service request
                                                     */
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context)=>AdminJobDescView(advertisement: ad, user: userid)
                                                        )
                                                    );


                                                  },
                                                  child: Container(
                                                    width: 155,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(0xFF1f1f1f), // Shadow color
                                                          offset: Offset(0, 2), // Offset of the shadow
                                                          blurRadius: 4, // Spread of the shadow
                                                          spreadRadius: 0, // Spread radius of the shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.description, color: Colors.black,),
                                                          SizedBox(width: 5,),
                                                          Text(
                                                              "Description",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black,
                                                                  fontWeight: FontWeight.w600
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ),
                                openBuilder: (context, _) => AdminJobDescView(advertisement: ad, user: userid),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                            )
                : Center(child: CircularProgressIndicator(),)
        )
    );
  }
}
