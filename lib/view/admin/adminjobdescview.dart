import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';

class AdminJobDescView extends StatefulWidget {
  final Advertisement? advertisement;
  final int user;
  const AdminJobDescView({required this.advertisement, required this.user});

  @override
  State<AdminJobDescView> createState() => _AdminJobDescViewState();
}

class _AdminJobDescViewState extends State<AdminJobDescView> {

  late int adsId;
  int AdsId = 0;
  String jobPosition = "";
  String jobDescription = "";
  String jobRemote = "";
  String jobDate = "";
  String jobTime = "";
  String AdsDate = "";
  String AdsTime = "";
  String jobCommit = "";
  String salary = "";
  String industry = "";
  String companyName = "";
  String companyState = "";
  String companyCity = "";
  String companyCountry = "";

  Advertisement? adsVer;// Declare userId as a class variable

  @override
  void initState() {
    super.initState();
    // Access the advertisement property and assign the AdsId to userId in initState
    adsId = widget.advertisement?.AdsId ?? 0;
    getAds();
  }

  String _getMonthName(int month) {
    // Convert the numeric month to its corresponding name
    List<String> monthNames = [
      "", // Month names start from index 1
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return monthNames[month];
  }

  String _formatTimeIn12Hour(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour format
    hour = (hour > 12) ? hour - 12 : hour;
    hour = (hour == 0) ? 12 : hour;

    // Format the time as a string
    String formattedTime = "$hour:${minute.toString().padLeft(2, '0')} $period";
    return formattedTime;
  }

  /**
   * add job apply request
   */
  Future<void> addJobApply(int user, int job) async{
    print(user);

    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String applyStartDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    // Calculate applyEndDate by adding 7 days to currentDate
    DateTime EndDate = currentDate.add(Duration(days: 7));
    String applyEndDate = "${EndDate.day} ${_getMonthName(EndDate.month)} ${EndDate.year}";


    String applyStartTime = _formatTimeIn12Hour(currentDay);


    String url = 'http://10.0.2.2:8080/inployed/jobapply/addApply';

    var res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {
              'userID': {
                "userId": user
              },
              "adsId": {
                "adsId": job
              },
              "applyStartDate": applyStartDate,
              "applyEndDate": applyEndDate,
              "applyStartTime": applyStartTime,
              "applyEndTime": applyStartTime,
              "applyStatus": "Not approved yet",
            }
        )
    );

    print(res.body);
  }


  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getAds() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/job/$adsId",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final ads = Advertisement.fromJson(req.result());

      setState(() {
        adsVer = ads;
        AdsId = ads.AdsId;
        jobPosition = ads.jobPosition;
        jobDescription = ads.jobDescription;
        jobRemote = ads.jobRemote;
        jobDate = ads.jobDate;
        jobTime = ads.jobTime;
        AdsDate = ads.AdsDate;
        AdsTime = ads.AdsTime;
        jobCommit = ads.jobCommit;
        salary = ads.salary;
        industry = ads.industry;
        companyName = ads.company.companyName;
        companyCity = ads.company.companyCity;
        companyState = ads.company.companyState;
        companyCountry = ads.company.companyCountry;

      });
    } else {
      throw Exception('Failed to fetch user');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBC2EB), // #fbc2eb
                  Color(0xFFA6C1EE), // #a6c1ee
                ],
              )
          ),
        ),
        title: Text("Job Description", style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 25
        ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Container(
          margin: EdgeInsets.only(
              bottom: 15
          ),
          padding: EdgeInsets.all(15),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBC2EB), // #fbc2eb
                  Color(0xFFA6C1EE), // #a6c1ee
                ],
              ),
              borderRadius: BorderRadius.circular(15)
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(companyName, style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ), softWrap: true,
                  ),
                ),

                Divider(
                  color: Colors.black,
                  thickness: 2
                ),

                SizedBox(height: 20),

                Text(jobPosition, style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 35
                ),),

                SizedBox(height: 20),

                Text(jobDescription, style: GoogleFonts.poppins(
                    fontSize: 18
                ),
                  textAlign: TextAlign.justify,
                ),

                SizedBox(height: 20),

                Text("Job Details", style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold
                ),
                ),

                SizedBox(height: 5),

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
                            child: Icon(Icons.monetization_on),
                          ),
                        ),
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(salary,
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
                            child: Text(jobTime,
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
                            child: Text(jobDate,
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
                            child: Text("${companyCity}, "
                                "${companyState},"
                                "${companyCountry}",
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
                              child: Icon(Icons.history)
                          ),
                        ),
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(jobCommit,
                              style: GoogleFonts.poppins(
                                  fontSize: 18
                              ), textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: ()
                      {
                        /**
                         * Navigate to login() function
                         * for web service request
                         */
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 150,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE5D2F8), Color(0xFF908E8E)],
                          ),
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
                          child: Text(
                              "Back",
                              style: GoogleFonts.poppins(
                                  fontSize: 25, color: Colors.black,
                                  fontWeight: FontWeight.w600
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
