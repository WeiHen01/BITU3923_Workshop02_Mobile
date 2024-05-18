import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/job_apply.dart';
import 'Edit Advertisement.dart';

class OwnJobPost extends StatefulWidget {
  final int ownPostId;
  const OwnJobPost({required this.ownPostId});

  @override
  State<OwnJobPost> createState() => _OwnJobPostState();
}

class _OwnJobPostState extends State<OwnJobPost> {


  late int adsId, applyId;
  int AdsId = 0;
  String jobPosition = "";
  String jobDescription = "";
  String jobRemote = "";
  String AdsDate = "";
  String AdsTime = "";
  String jobDate = "";
  String jobTime = "";
  String jobCommit = "";
  String salary = "";
  String industry = "";
  String companyName = "";
  String applyStatus = "";
  String companyState = "";
  String companyCity = "";
  String companyCountry = "";
  JobApply? jobRequests;
  Advertisement? adsVer;// Declare userId as a class variable

  @override
  void initState() {
    super.initState();
    // Access the advertisement property and assign the AdsId to userId in initState
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
        path: "/inployed/job/${widget.ownPostId}",
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
        jobTime = ads.jobTime;
        jobDate = ads.jobDate;
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

  Future<void> deleteJob() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/company/delete/ownPost/${widget.ownPostId}",
        server: "http://$server:8080");

    await req.delete();

    if (req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Successful delete the post',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: 'Fail to delete job post!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
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
                    Expanded(
                      child: Text(companyName, style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ), softWrap: true,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Text("Post on ${AdsDate}", style: GoogleFonts.poppins(
                      fontSize: 13,
                    ), softWrap: true,
                    ),

                    Spacer(),

                    Text("${AdsTime}", style: GoogleFonts.poppins(
                      fontSize: 13,
                    ), softWrap: true,
                    ),
                  ],
                ),

                Divider(
                  thickness: 2.0,
                  color: Colors.black,
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
                            child: Icon(Icons.view_day),
                          ),
                        ),
                        TableCell(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("${jobDate}",
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
                            child: Text("${companyCity}, ${companyState}, ${companyCountry}",
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


                InkWell(
                  onTap: ()
                  {
                    /**
                     * Navigate to register() function
                     * for web service request
                     */
                    Navigator.push(context, MaterialPageRoute(builder:
                        (context) => EditCompanyAds(ads: AdsId,)
                      )
                    );
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
                          "Update Post",
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: Colors.black,
                              fontWeight: FontWeight.w600
                          )),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                InkWell(
                  onTap: ()
                  {
                    /**
                     * Navigate to register() function
                     * for web service request
                     */
                    deleteJob();
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
                          "Delete Post",
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
