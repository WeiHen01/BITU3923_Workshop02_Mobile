import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/OneSignalController.dart';
import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/job_apply.dart';
import '../../models/user.dart';
import 'home_navi.dart';

class JobDescView extends StatefulWidget {
  final Advertisement? advertisement;
  final int user;
  final String username;
  const JobDescView({required this.advertisement, required this.user, required this.username});

  @override
  State<JobDescView> createState() => _JobDescViewState();
}

class _JobDescViewState extends State<JobDescView> {

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
  int companyId = 0;
  String companyName = "";
  String companyState = "";
  String companyCity = "";
  String companyCountry = "";

  Advertisement? adsVer;// Declare userId as a class variable

  @override
  void initState() {
    super.initState();
    print(widget.user);
    // Access the advertisement property and assign the AdsId to userId in initState
    adsId = widget.advertisement?.AdsId ?? 0;
    getAds();
  }

  /**
   * Make job apply request steps:
   * 1. Check whether the quota is exceed (job requests originally more than 3)
   * 2. if job request < 3,
   *    2.1 add job request -> send notification
   *    2.2 update the number of job request and calculate the current list of job request by id
   *    2.3 if the new job request = 3rd request then update job status to unavailable
   *
   *
   */
  late List<JobApply> jobApplyRequests = [];
  Future<void> checkExceedJobRequest(int user, int job, int? company) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/jobapply/applyStatus/$job",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        jobApplyRequests = data.map((json) => JobApply.fromJson(json)).toList();
      });

      if(jobApplyRequests.length <= 3){
        /**
         * add new job apply and also send notifications
         */
        addJobApply(user, job, company);
      }
      else{

        /**
         * update the job availability
         */
        final prefs = await SharedPreferences.getInstance();
        String? server = prefs.getString("localhost");
        WebRequestController req = WebRequestController
          (path: "/inployed/job/updateJobStatus/${job}", server: "http://$server:8080");

        await req.put();

        if(req.status() == 200) {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                title: "REQUEST QUOTA REACHED!",
                text: "Sorry, the request quota is full",
                onConfirm: (){
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) =>
                          HomeNavi(username: widget.username, id: widget.user ?? 0, tabIndexes: 0,)), (route) => false
                  );
                }
            ),
          );
        }


      }
    } else {
      throw Exception('Failed to fetch job');
    }
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
  Future<void> addJobApply(int user, int job, int? company) async{
    print(user);

    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String applyStartDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    // Calculate applyEndDate by adding 7 days to currentDate
    DateTime EndDate = currentDate.add(Duration(days: 7));
    String applyEndDate = "${EndDate.day} ${_getMonthName(EndDate.month)} ${EndDate.year}";

    String applyStartTime = _formatTimeIn12Hour(currentDay);

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/jobapply/addApply", server: "http://$server:8080");

    req.setBody(
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
    );

    await req.post();

    print(req.result());
    print(company);

    if (req.result() != null) {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "SUCCESSFULLY SENT",
            text: "You have sent the job apply to the company!",
          )
      );
      getUserUnderSameCompany(company);

      /**
       * checking again for the new number of job apply requests based on the job
       */
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(path: "/inployed/jobapply/applyStatus/$job",
          server: "http://$server:8080");

      await req.get();

      List<dynamic> data = req.result();
      setState(() {
        jobApplyRequests = data.map((json) => JobApply.fromJson(json)).toList();
      });

      if(jobApplyRequests.length == 3){
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.info,
              title: "LAST REQUEST QUOTA REACHED!",
              text: "You are lucky!",
              onConfirm: ()async{
                /**
                 * update the job availability
                 */
                final prefs = await SharedPreferences.getInstance();
                String? server = prefs.getString("localhost");
                WebRequestController req = WebRequestController
                  (path: "/inployed/job/updateJobStatus/${job}", server: "http://$server:8080");

                await req.put();

                if(req.status() == 200) {

                  Fluttertoast.showToast(
                    msg: 'The job is currently unavailable now!',
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    gravity: ToastGravity.CENTER,
                    toastLength: Toast.LENGTH_SHORT,
                    fontSize: 16.0,
                  );

                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) =>
                          HomeNavi(username: widget.username,
                            id: widget.user ?? 0,
                            tabIndexes: 0,)), (route) => false
                  );
                }
              }
          ),
        );
      }
    }
    else if(jobApplyRequests.length > 3)
    {
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "FAILURE",
            text: "Sorry, the request is failed to sent!",
          )
      );
    }
  }

  /**
   * Notification target user selection
   */
  late List<User> companyUser = [];
  List<int> userIds = [];

  Future<void> getUserUnderSameCompany(int? company) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
          path: "/inployed/user/getUserByCompany/$company",
          server: "http://$server:8080");

      await req.get();

      if (req.status() == 200) {
        setState(() {
          List<dynamic> data = req.result();
          companyUser = data.map((json) => User.fromJson(json)).toList();

          print(companyUser);

          // Extract user IDs and convert them to strings
          List<String> notifyUser = companyUser.map((user) => user.userId.toString()).toList();

          print("UserID: $notifyUser");

          OneSignalController onesignal = OneSignalController();
          onesignal.SendNotification("A new job request", "There is a new job request", notifyUser);
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print('An error occurred: $e');
      // Handle the error as needed, e.g., show an error message to the user.
    }
  }


  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getAds() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/job/$adsId",
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
        companyId = ads.company.companyId;
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
                Row(
                  children: [
                    Image.asset('images/logo.png', width: 160, height: 60,),
                    SizedBox(width: 15,),
                    Expanded(
                      child: Text(companyName, style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ), softWrap: true,
                      ),
                    ),
                  ],
                ),

                Divider(
                  thickness: 2.0,
                  color: Colors.black,
                ),

                SizedBox(height: 10),

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

                    TableRow(
                      children: [
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.settings_remote),
                          ),
                        ),
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(jobRemote,
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
                            child: Icon(Icons.work),
                          ),
                        ),
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(industry,
                                style: GoogleFonts.poppins(
                                    fontSize: 18
                                )
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
                      onTap: () async
                      {
                        /**
                         * Navigate to login() function
                         * for web service request
                         */

                        checkExceedJobRequest(widget.user, AdsId, companyId);

                      },
                      child: Container(
                        width: 150,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [ Color.fromRGBO(249, 151, 119, 1),
                                Color.fromRGBO(98, 58, 162, 1),]
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
                              "Apply",
                              style: GoogleFonts.poppins(
                                  fontSize: 25, color: Colors.white,
                                  fontWeight: FontWeight.w600
                              )),
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

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
