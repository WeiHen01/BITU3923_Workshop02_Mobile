import 'package:animations/animations.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:bitu3923_group05/view/admin/adminviewcompany.dart';
import 'package:bitu3923_group05/view/company/Company%20Profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';
import '../company/View_Account.dart';


class AdminControl extends StatefulWidget {
  const AdminControl({required this.id, required this.userType});
  final int id;
  final String userType;

  @override
  State<AdminControl> createState() => _AdminControlState();
}

class _AdminControlState extends State<AdminControl> {

  User jobs = User(
    0,
    "",
    "",
    "",
    "",
    "Job Seeker",
    "",
    null,
    "",
  );

  /**
   * This is to retrieve all job apply made by the user
   */
  ScrollController _scroll02Controller = ScrollController();
  late List<User> jobseekers = [];

  Future<void> getJobSeeker() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/admin/ctrlUserJobSeeker/Job Seeker",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        jobseekers = data.map((json) => User.fromJson(json)).toList();
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

  late List<User> companyuser = [];
  Future<void> getCompanyUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/admin/ctrlUserCompany/Company",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        companyuser = data.map((json) => User.fromJson(json)).toList();
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
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>UpdateStatus(int? userId, String status) async
  {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/updatestatus/${userId}/${status}",
        server: "http://$server:8080");

    req.setBody(
        {
          "userStatus": status
        }
    );

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update user status to ${status} successfully',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
      getJobSeeker();
      getCompanyUser();
    }
    else{
      Fluttertoast.showToast(
        msg: 'Update Status failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  late List<User> viewalluser = [];
  final ScrollController _scrollController02 = ScrollController();
  Future<void> getAllUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user",
        server: "http://$server:8080");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        viewalluser = data.map((json) => User.fromJson(json)).toList();
      });

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController02.animateTo(
            _scrollController02.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
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
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>UpdateLastEditedDateTime(int? userId) async
  {
    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String applyStartDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String applyStartTime = _formatTimeIn12Hour(currentDay);

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/LastupdatedTimeDate/${userId}/${applyStartDate}/${applyStartTime}",
        server: "http://$server:8080");

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Updated timestamp successfully!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
    else{
      Fluttertoast.showToast(
        msg: 'Fail to udpate timestamp!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUser();
    getJobSeeker();
    getCompanyUser();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _scroll02Controller.animateTo(
          _scroll02Controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });

  }


@override
Widget build(BuildContext context) {
  return DefaultTabController(
      length: 3,
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
                  text: "All User",
                ),
                Tab(
                  text: "Job Seeker",
                ),
                Tab(
                  text: "Company User"
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
            title:  Text("Control User", style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.white,
            fontSize: 30
            ),),
            ),
            body: TabBarView(
              children: [
                /**
                 * Tab 1 - All User
                 */
                viewalluser != null
                    ? Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFBC2EB), // #fbc2eb
                          Color(0xFFA6C1EE), // #a6c1ee
                        ],
                      )
                    ),
                    padding: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom:  10
                    ),
                    width: double.infinity,
                    height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total User: ${viewalluser.length}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, fontSize: 20
                            ),
                            textAlign: TextAlign.left,
                          ),

                          Divider(
                            thickness: 2.0,
                          ),

                          Expanded(
                            child: ListView.builder(
                              controller: _scroll02Controller,
                              itemCount: viewalluser.length,
                              itemBuilder: (context, index) {
                                final request = viewalluser[index];

                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      left: 10, top: 5, bottom: 10, right: 10
                                  ),

                                  margin: EdgeInsets.only(
                                      bottom: 10
                                  ),

                                  height: 140,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [ Color.fromRGBO(249, 151, 119, 1),
                                            Color.fromRGBO(98, 58, 162, 1),]
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person, color: Colors.white,),
                                            SizedBox(width: 5),
                                            Text("User: ${request.username}",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 20
                                              ),
                                              textAlign: TextAlign.left,
                                            ),

                                            Spacer(),

                                            Text("ID USER: ${request.userId}",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 20
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),

                                      Divider(
                                        thickness: 2.0,
                                        color: Colors.white,
                                      ),

                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.work, color: Colors.white,),
                                            SizedBox(width: 5),
                                            Text("Position: ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 15
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            
                                            Expanded(
                                              child: Text("${request.userPosition}",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white, fontSize: 15
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                ) : Center(child: CircularProgressIndicator(),),

                /**
                 * Tab 2 - Job Seeker
                 */
                  jobseekers != null
                    ? Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFBC2EB), // #fbc2eb
                            Color(0xFFA6C1EE), // #a6c1ee
                          ],
                        )
                    ),
                    padding: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom:  10
                    ),
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Job Seekers: ${jobseekers.length}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, fontSize: 20
                            ),
                            textAlign: TextAlign.left,
                          ),

                        Divider(
                          thickness: 2.0,
                        ),

                        Expanded(
                          child: ListView.builder(
                            controller: _scroll02Controller,
                            itemCount: jobseekers.length,
                            itemBuilder: (context, index) {
                              final request = jobseekers[index];

                              return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      left: 10, top: 5, bottom: 10, right: 10
                                  ),

                                  margin: EdgeInsets.only(
                                      bottom: 10
                                  ),

                                  height: 170,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [ Color.fromRGBO(249, 151, 119, 1),
                                            Color.fromRGBO(98, 58, 162, 1),]
                                      ),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      TextButton(onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => ViewOtherAccount(username: request.username)
                                        )
                                        );
                                      },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person, color: Colors.white,),
                                            SizedBox(width: 5),
                                            Text("User: ${request.username}",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 20
                                              ),
                                              textAlign: TextAlign.left,
                                            ),

                                            Spacer(),

                                            Text("ID USER: ${request.userId}",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 20
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),

                                      Divider(
                                        thickness: 2.0,
                                        color: Colors.white,
                                      ),

                                      Text("Last Access to the system: ${request.lastAccessDate}  ${request.lastAccessTime}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12, color: Colors.white
                                          )
                                      ),

                                      Text("Last Updated to the system: ${request.lastUpdateDate} ${request.lastUpdateTime}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 12, color: Colors.white
                                          )
                                      ),


                                      Spacer(),

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
                                              print("Status: ${request?.userStatus}");

                                              if(request?.userStatus == "Active"){
                                                UpdateStatus(request?.userId, "Inactive");
                                                UpdateLastEditedDateTime(request?.userId);
                                              }
                                              if(request?.userStatus == "Inactive") {
                                                UpdateStatus(request?.userId, "Active");
                                                UpdateLastEditedDateTime(request?.userId);
                                              }
                                            },
                                            child: Container(
                                              width: 180,
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
                                                child: Text((request?.userStatus == "Inactive")
                                                    ? "Enable"
                                                    : "Disable",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16, color: Colors.black,
                                                        fontWeight: FontWeight.w600
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                            },
                          ),
                      )
                    ],
                  ),
                ) : Center(child: CircularProgressIndicator(),),

                /**
                 * Tab 3 - Company
                 */
                companyuser != null
                    ? Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFBC2EB), // #fbc2eb
                            Color(0xFFA6C1EE), // #a6c1ee
                          ],
                        )
                    ),
                    padding: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom:  10
                    ),
                    width: double.infinity,
                    height: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Total Company User: ${companyuser.length}",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, fontSize: 20
                              ),
                              textAlign: TextAlign.left,
                            ),

                            Divider(
                              thickness: 2.0,
                            ),

                            Expanded(
                              child: ListView.builder(
                                controller: _scroll02Controller,
                                itemCount: companyuser.length,
                                itemBuilder: (context, index) {
                                  final request = companyuser[index];

                                  return Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(
                                        left: 10, top: 5, bottom: 10, right: 10
                                    ),

                                    margin: EdgeInsets.only(
                                        bottom: 10
                                    ),

                                    height: 190,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [ Color.fromRGBO(249, 151, 119, 1),
                                              Color.fromRGBO(98, 58, 162, 1),]
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        TextButton(onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => AdminCompanyAccount(username: request.username)
                                          )
                                          );
                                        },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.person, color: Colors.white,),
                                              SizedBox(width: 5),
                                              Text("User: ${request.username}",
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white, fontSize: 20
                                                ),
                                                textAlign: TextAlign.left,
                                              ),

                                              Spacer(),

                                              Text("ID USER: ${request.userId}",
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white, fontSize: 20
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                        ),

                                        Divider(
                                          thickness: 2.0,
                                          color: Colors.white,
                                        ),

                                        Text("Last Access to the system: ${request.lastAccessDate}  ${request.lastAccessTime}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12, color: Colors.white
                                            )
                                        ),

                                        Text("Last Updated to the system: ${request.lastUpdateDate} ${request.lastUpdateTime}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 12, color: Colors.white
                                            )
                                        ),

                                        Spacer(),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [

                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: ()
                                                  {
                                                    /**
                                                     * Navigate to status() function
                                                     * for web service request
                                                     */
                                                    print("Status: ${request?.userStatus}");

                                                    if(request?.userStatus == "Active"){
                                                      UpdateStatus(request?.userId, "Inactive");
                                                      UpdateLastEditedDateTime(request?.userId);
                                                    }
                                                    if(request?.userStatus == "Inactive") {
                                                      UpdateStatus(request?.userId, "Active");
                                                      UpdateLastEditedDateTime(request?.userId);
                                                    }

                                                  },
                                                  child: Container(
                                                    width: 180,
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
                                                      child: Text((request?.userStatus == "Inactive")
                                                          ? "Enable"
                                                          : "Disable",
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 16, color: Colors.black,
                                                              fontWeight: FontWeight.w600
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                  ) : Center(child: CircularProgressIndicator(),),
            ])
      )
    );

  }
}


