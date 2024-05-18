import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/job_apply.dart';

class JobApplyView extends StatefulWidget {
  final Advertisement? advertisement;
  final String applyStatus;
  const JobApplyView({required this.advertisement, required this.applyStatus});

  @override
  State<JobApplyView> createState() => _JobApplyViewState();
}

class _JobApplyViewState extends State<JobApplyView> {

  late int adsId, applyId;
  int AdsId = 0;
  String jobPosition = "";
  String jobDescription = "";
  String jobRemote = "";
  String AdsDate = "";
  String AdsTime = "";
  String jobCommit = "";
  String salary = "";
  String industry = "";
  String companyName = "";
  String applyStatus = "";
  String jobDate = "";
  String jobTime = "";
  String companyState = "";
  String companyCity = "";
  String companyCountry = "";
  JobApply? jobRequests;
  Advertisement? adsVer;// Declare userId as a class variable

  @override
  void initState() {
    super.initState();
    // Access the advertisement property and assign the AdsId to userId in initState
    adsId = widget.advertisement?.AdsId ?? 0;
    getAds();
  }

  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getAds() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/$adsId",
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
                Row(
                  children: [
                    Image.asset('images/logo.png', width: 160, height: 60,),
                    SizedBox(width: 15,),
                    Expanded(
                      child: Text(companyName, style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ), softWrap: true,
                      ),
                    ),
                  ],
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
                  children: [
                    Icon((widget.applyStatus == 'Not approved yet')
                        ? Icons.close
                        : Icons.done,

                      color: (widget.applyStatus == 'Not approved yet')
                          ? Colors.red
                          : Color(0xFF009B0D),
                    ),

                    Text('${widget.applyStatus}',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold,
                        color: (widget.applyStatus == "Not approved yet")
                            ? Colors.red
                            : Color(0xFF009B0D),
                      ), textAlign: TextAlign.justify,
                    ),
                  ],
                ),

                SizedBox(height: 10),

                InkWell(
                  onTap: () async
                  {
                    /**
                     * Navigate to register() function
                     * for web service request
                     */
                    ArtDialogResponse response = await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            denyButtonText: "Cancel",
                            title: "Are you confirm to cancel this apply?",
                            text: "You have to resend this job apply afterwards.",
                            confirmButtonText: "Yes",
                            type: ArtSweetAlertType.warning
                        )
                    );

                    if (response == null) {
                      return;
                    }

                    if (response.isTapConfirmButton) {
                      //deleteJobApply(a);
                      print("Apply ID: $applyId");
                    }


                  },
                  child: Container(
                    width: double.infinity,
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
                          "Delete This Apply",
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: Colors.black,
                              fontWeight: FontWeight.w600
                          )),
                    ),
                  ),
                ),

                SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
