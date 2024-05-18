import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:bitu3923_group05/view/company/JobDetails.dart';
import 'package:bitu3923_group05/view/company/View_Account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/OneSignalController.dart';
import '../../controller/request_controller.dart';
import '../../models/job_apply.dart';


class CompanyViewRequest extends StatefulWidget {
  const CompanyViewRequest({required this.company});
  final int company;

  @override
  State<CompanyViewRequest> createState() => _CompanyViewRequestState();
}

class _CompanyViewRequestState extends State<CompanyViewRequest> {

  late List<JobApply> requestsList = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> getJobRequests() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/jobapply/companyView/jobrequests/${widget.company}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        requestsList = data.map((json) => JobApply.fromJson(json)).toList();
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
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>updateApproval(int id, String status) async
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

      final userData = req.result();

      var userid = userData["userID"]["userId"];

      if(req.status() == 200) {
        if(status == "Approved"){
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "SUCCESSFULLY APPROVED!",
                text: "You have approved the job request!",
              )
          );

          setState(() {
            List<String> notifyUser = [];
            notifyUser.add(userid.toString());
            OneSignalController onesignal = OneSignalController();
            onesignal.SendNotification("Approval Success", "Your request is approved!", notifyUser);
          });


        }
        else{
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "SUCCESSFULLY DO NOT APPROVED!",
                text: "You have failed the job request!",
              )
          );

          setState(() {
            List<String> notifyUser2 = [];
            notifyUser2.add(userid.toString());
            OneSignalController onesignal = OneSignalController();
            onesignal.SendNotification("Approval Failed", "Your request is not approved!", notifyUser2);
          });
        }

        // Call getJobRequests to refresh the page
        getJobRequests();
      }
      else{
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "FAILED!",
              text: "Sorry, it's unsuccessful to approved!",
            )
        );
      }
    } catch (e) {
      // Handle any exceptions that may occur
      print('Error: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  //Color(0xFFFBC2EB), // #fbc2eb
                  //Color(0xFFA6C1EE), #a6c1ee
                  Color.fromRGBO(249, 151, 119, 1),
                  Color.fromRGBO(98, 58, 162, 1),
                ],
              )
          ),
        ),
        title: Text("Job Request", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, fontSize: 25,
          color: Colors.white
        ),),
      ),
      body: requestsList!=null
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
            Text("Notifications", style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),),

            Divider(
              thickness: 2.0,
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: requestsList.length,
                itemBuilder: (context, index) {
                  final request = requestsList[index];

                  /**
                   * Auto updates the status to "Failed"
                   * if the company does not make any approval on the request
                   * for 7 days
                   * (where current day = apply end date)
                   * as apply end date already set when user make job request
                   */

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

                  DateTime currentDay = DateTime.now();
                  DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
                  // Format the date as a string
                  String applyCurrentDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

                  if(applyCurrentDate == request.ApplyEndDate){
                    updateApproval(request.ApplyId, "Failed");
                  }

                  return OpenContainer(
                    openBuilder: (context, _) => JobDetails(advertisement: request.adsId),
                    transitionType: ContainerTransitionType.fade,
                    closedElevation: 10,
                    closedColor: Colors.transparent,
                    transitionDuration: Duration(seconds: 1),
                    closedBuilder: (context, _) => Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                          left: 10, top: 5, bottom: 10, right: 10
                      ),

                      margin: EdgeInsets.only(
                          bottom: 10
                      ),

                      height: 250,
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
                                builder: (context) => ViewOtherAccount(username: request.user.username,)
                              )
                            );
                          },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.person, color: Colors.white,),
                                SizedBox(width: 5),
                                Text("User: ${request.user.username}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, fontSize: 20
                                  ),
                                  textAlign: TextAlign.left,
                                ),

                                Spacer(),

                                Text("Apply ID: ${request.ApplyId}",
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

                          Text(request.adsId.jobPosition, style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white, fontSize: 18
                          ),),

                          SizedBox(height: 5),

                          Text("${request.adsId.jobDescription}", style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 14
                          ), textAlign: TextAlign.justify,
                            maxLines: 2, overflow: TextOverflow.clip,
                          ),

                          Spacer(),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                backgroundColor: Colors.white,
                                avatar: Icon(
                                  Icons.date_range,
                                  color: Colors.black,
                                ),
                                label: Text(request.ApplyStartDate, style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 12
                                ), textAlign: TextAlign.center,),
                              ),

                              Spacer(),

                              Chip(
                                backgroundColor: Colors.indigo,
                                avatar: Icon(
                                  Icons.label,
                                  color: Colors.white,
                                ),
                                label: Text(request.ApplyStartTime, style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 12
                                ), textAlign: TextAlign.center,),
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Spacer(),

                              Row(
                                children: [
                                  InkWell(
                                    onTap: ()
                                    {
                                      /**
                                       * Navigate to login() function
                                       * for web service request
                                       */
                                      print("id: ${request?.ApplyId}");
                                      updateApproval(request.ApplyId, "Approved");

                                    },
                                    child: Container(
                                      width: 120,
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
                                        child: Text(
                                            "Approve",
                                            style: GoogleFonts.poppins(
                                                fontSize: 16, color: Colors.black,
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
                                      print("id: ${request?.ApplyId}");
                                      updateApproval(request.ApplyId, "Failed");

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
                                        child: Text(
                                            "Don't Approve",
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
                    ),
                  );
                },
              ),
            )





          ],
        ),
              ) : Center(child: CircularProgressIndicator(),),
    );
  }
}
