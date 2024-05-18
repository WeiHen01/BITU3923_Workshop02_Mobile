import 'package:animations/animations.dart';
import 'package:bitu3923_group05/models/company.dart';
import 'package:bitu3923_group05/models/user.dart';
import 'package:bitu3923_group05/view/user/JobApplicationView.dart';
import 'package:bitu3923_group05/view/user/JobDescriptionView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../controller/OneSignalController.dart';
import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/job_apply.dart';
import 'home_navi.dart';


/**
 * Here is the home page
 * after user login successfully
 */


class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.username, required this.user}) : super(key: key);
  final String username;
  final int user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User? _user;
  int userid = 0;
  int? companyId = 0;

  /**
   * get user information
   */
  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/${widget.username}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final user = User.fromJson(req.result());

      setState(() {
        _user = user;
        userid = user.userId;
        print(userid);

      });
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  /**
   * This is to retrieve all available advertisements posted
   */
  late List<Advertisement> advertisements = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> getAdvertisement() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/available",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        advertisements = data.map((json) => Advertisement.fromJson(json)).toList();
        // Extract company IDs and convert them to strings
        List<String> companyIdsAsString = advertisements.map((ad) => ad.company.companyId.toString()).toList();
        print(companyIdsAsString);
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

  /**
   * This is to retrieve all job apply made by the user
   */
  ScrollController _scroll02Controller = ScrollController();
  late List<JobApply> jobRequests = [];
  Future<void> getJobApply(int? id) async {
    print(id);
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/jobapply/$id",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        jobRequests = data.map((json) => JobApply.fromJson(json)).toList();
      });

      _scroll02Controller.animateTo(
          _scroll02Controller.position.minScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn
      );
    } else {
      throw Exception('Failed to fetch job');
    }
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
   * Auto update approval status after the due date
   */
  Future<void>autoUpdateApprovalStatus(int id, String status) async
  {
    print("id: $id");
    try{
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
          path: "/inployed/jobapply/update/$id/$status",
          server: "http://$server:8080");

      await req.put();

      print(req.result());

    } catch (e) {
      // Handle any exceptions that may occur
      print('Error: $e');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getAdvertisement();
    getJobApply(widget.user);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
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
          bottom:  TabBar(
            dividerColor: Colors.transparent,

            tabs: <Widget>[
              Tab(
                text: "Dashboard",
              ),
              Tab(
                  text: "Application"
              ),
            ],
            labelStyle: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600
            ),
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.black,
            indicator: BoxDecoration(
                color: Color(0xFFA6C1EE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                )
            ),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          title: Image.asset('images/logo.png',
            width: 140, height: 50,
          ),
        ),
        body: TabBarView(
          children: [
            /**
             * Tab 1 - Dashboard
             */
            advertisements != null
                ? Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFA6C1EE),
                  ),
                  child: RefreshIndicator(
                    onRefresh: ()async{
                      Future.delayed(Duration(seconds: 3));
                    },
                    child: Builder(
                      builder: (context) {
                        SchedulerBinding.instance?.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 1),
                              curve: Curves.fastOutSlowIn);
                        });

                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
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
                                        width: 320,
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
                                                              fontSize: 18
                                                          ),
                                                          textAlign: TextAlign.justify,
                                                          maxLines: 3, // Set the maximum number of lines
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
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text("Posted on:",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                      fontWeight: FontWeight.bold
                                                    ), textAlign: TextAlign.justify,
                                                    // Set the maximum number of lines
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text("${ad.AdsDate}",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15
                                                    ), textAlign: TextAlign.justify,
                                                    // Set the maximum number of lines
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),

                                                  Spacer(),

                                                  Text(ad.AdsTime,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15
                                                    ), textAlign: TextAlign.justify,
                                                    // Set the maximum number of lines
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),






                                              Spacer(),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [

                                                    InkWell(
                                                      onTap: () async {
                                                        /**
                                                         * Navigate to login() function
                                                         * for web service request
                                                         */
                                                        checkExceedJobRequest(userid, ad.AdsId, ad.company?.companyId);


                                                      },
                                                      child: Container(
                                                        width: 100,
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
                                                              Icon(Icons.send,
                                                                  color: Colors.black),
                                                              SizedBox(width: 5),
                                                              Text(
                                                                  "Apply",
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize: 15,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w600
                                                                  )
                                                              ),
                                                            ],
                                                          ),
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
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder: (context)=>JobDescView(advertisement: ad, user: userid, username: widget.username,)
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
                                  openBuilder: (context, _) => JobDescView(advertisement: ad, user: userid, username: widget.username,),
                              );
                            },
                          );
                      }
                    ),
                  ),
                )
                : Center(child: CircularProgressIndicator(),),

            /**
             * Tab 2 - Application
             */
            jobRequests != null
            ? Container(
              padding: EdgeInsets.only(
                  left: 10, right: 10, bottom: 100
              ),
              decoration: BoxDecoration(
                color: Color(0xFFA6C1EE),
              ),
              child: RefreshIndicator(
                onRefresh: ()async{
                  Future.delayed(Duration(seconds: 10));
                  getUser();
                  getAdvertisement();
                },
                color: Colors.black,
                backgroundColor: Colors.yellow,
                child: Builder(
                  builder: (context) {
                    SchedulerBinding.instance?.addPostFrameCallback((_) {
                      _scroll02Controller.animateTo(
                          _scroll02Controller.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 1),
                          curve: Curves.fastOutSlowIn);
                    });
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _scroll02Controller,
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: jobRequests.length,
                        itemBuilder: (BuildContext context, int index){
                          //getJobApply(_user?.userId);
                          final requests = jobRequests[index];

                          // Function to get the index of a month from its name
                          int _getMonthIndex(String monthName) {
                            List<String> monthNames = [
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
                            return monthNames.indexOf(monthName) + 1;
                          }

                          // Function to parse a date string in the format "day month year" (e.g., "27 December 2028")
                          DateTime _parseDate(String dateString) {
                            List<String> parts = dateString.split(' ');
                            int day = int.parse(parts[0]);
                            int month = _getMonthIndex(parts[1]);
                            int year = int.parse(parts[2]);
                            return DateTime(year, month, day);
                          }

                          // Parse the ApplyEndDate string into a DateTime object
                          DateTime applyEndDate = _parseDate(requests.ApplyEndDate);

                          // Calculate the date that is 5 years after requests.ApplyEndDate
                          DateTime fiveYearsLater = applyEndDate.add(Duration(days: 5 * 365));

                          // Get the current date
                          DateTime currentDate = DateTime.now();

                          // Check if today is 5 years after requests.ApplyEndDate
                          if (currentDate.isAtSameMomentAs(fiveYearsLater)) {
                            autoUpdateApprovalStatus(requests.ApplyId, "Hidden");
                          } else if (currentDate.isAfter(fiveYearsLater)) {
                            autoUpdateApprovalStatus(requests.ApplyId, "Hidden");
                          }

                          return OpenContainer(
                              closedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              closedColor: Color(0xFFA6C1EE),
                              closedBuilder: (context, _) => Card(
                                elevation: 3,
                                child: Container(
                                  height: 260,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (jobRequests.last.adsId == requests.adsId)
                                        ? Colors.white
                                        : Color(0xFFFFF989),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Job Apply ${index + 1} : ${requests.adsId.jobPosition}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 18, color: Colors.black,
                                            fontWeight: FontWeight.bold
                                        ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(height: 10),

                                      Text(
                                        requests.adsId.jobDescription,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16, color: Colors.black,
                                        ),
                                        maxLines: 5, // Set the maximum number of lines
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Text(
                                            requests.ApplyStartDate,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16, color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ), // Set the maximum number of lines
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                          ),

                                          Spacer(),

                                          Text(
                                            requests.ApplyStartTime,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16, color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ), // Set the maximum number of lines
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ],
                                      ),

                                      Spacer(),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Visibility(
                                            visible: (jobRequests.last.adsId == requests.adsId)
                                                ? true
                                                : false,
                                            child: Chip(
                                              backgroundColor: Colors.red,
                                              avatar: Icon(
                                                Icons.notifications,
                                                color: Colors.white,
                                              ),
                                              label: Text("Latest", style: GoogleFonts.poppins(
                                                  color: Colors.white, fontSize: 15
                                              ), textAlign: TextAlign.center,),
                                            ),
                                          ),

                                          Spacer(),


                                          Icon((requests.ApplyStatus == 'Not approved yet')
                                              ? Icons.pending_outlined
                                              : (requests.ApplyStatus == 'Approved')
                                                ? Icons.done
                                                : (requests.ApplyStatus == 'Failed')
                                                  ? Icons.close
                                                  : Icons.hide_source,

                                            color: (requests.ApplyStatus == 'Not approved yet')
                                                ? Colors.red
                                                : (requests.ApplyStatus == 'Approved')
                                                  ? Color(0xFF009B0D)
                                                  : (requests.ApplyStatus == 'Failed')
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),

                                          Text(
                                            requests.ApplyStatus,
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: (requests.ApplyStatus == 'Not approved yet')
                                                    ? Colors.red
                                                    : (requests.ApplyStatus == 'Approved')
                                                      ? Color(0xFF009B0D)
                                                      : (requests.ApplyStatus == 'Failed')
                                                        ? Colors.black
                                                        : Colors.white,
                                                fontWeight: FontWeight.bold
                                            ),
                                            maxLines: 5, // Set the maximum number of lines
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ],
                                      ),


                                    ],
                                  ),
                                ),
                              ),
                              openBuilder: (context, _) => JobApplyView(advertisement: requests.adsId, applyStatus: requests.ApplyStatus,)
                          );
                        }
                    );
                  }
                ),
              )
            )
            : Center(
              child: CircularProgressIndicator(),
            ),

          ]
        )
        )
    );
  }



}
