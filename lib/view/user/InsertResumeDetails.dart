import 'dart:convert';

import 'package:bitu3923_group05/view/user/login.dart';
import 'package:bitu3923_group05/view/user/upload_new_resume.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/request_controller.dart';
import '../../models/resume.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class FirstTimeResume extends StatefulWidget {
  final int user;
  const FirstTimeResume({required this.user});

  @override
  State<FirstTimeResume> createState() => _FirstTimeResumeState();
}

class _FirstTimeResumeState extends State<FirstTimeResume> {

  TextEditingController educationTextCtrl = TextEditingController();
  TextEditingController instituteTextCtrl = TextEditingController();
  TextEditingController majorCourseTextCtrl = TextEditingController();

  Future<void> addResume() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/resume/newResume/${widget.user}",
        server: "http://$server:8080");

    req.setBody(
        {
          "userId": {
            "userId": widget.user
          },
          "major": majorCourseTextCtrl.text,
          "educationLvl": educationTextCtrl.text
        }
    );

    await req.post();

    print(req.result());


    if (req.result() != null) {

      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            title: "SUCCESSFUL ADDED!",
            text: "You have add your resume details successfully.",
          )
      );

      Fluttertoast.showToast(
        msg: 'Resume details is uploaded successful',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
              builder: (context) => NewResume(userid: widget.user),
            ), (route) => false
        );
      });



    }

    else
    {
      Fluttertoast.showToast(
        msg: 'Add resume details failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          // set the background color of the container to be gradient
          gradient: LinearGradient(
            // determine the direction and angle of each color stop in gradient
            begin: Alignment.topRight,
            end: Alignment.bottomRight,

            /**
             * 0xFF is needed to convert RGB Hex code to int value
                Hex code here is 29539B and 1E3B70
                Gradient Name: Unloved Teen
             */
            colors: [
              Color(0xFFFBC2EB), // #fbc2eb
              Color(0xFFA6C1EE), // #a6c1ee
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Add your resume",
                style: GoogleFonts.poppins(
                    shadows: [
                      Shadow(
                        color: Color(0xFF545454),
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                      ),
                    ],
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                ),
            ),

            SizedBox(height: 10),


            Text("As first time user, you are required to enter your resume details",
              style: GoogleFonts.poppins(
                  fontSize: 15
              ),
            ),

            SizedBox(height: 40),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Education Level",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold,
                  ),
                ),

                TextField(
                  controller: educationTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter your highest education",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter your highest education",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),
                ),

                SizedBox(height: 15),

                Text("Major Course",
                  style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.bold,
                  ),
                ),

                TextField(
                  controller: majorCourseTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter major course",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter major course",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),
                ),

                SizedBox(height: 15),





              ],
            ),

            SizedBox(height: 20),

            InkWell(
              onTap: ()
              {
                /**
                 * Navigate to register() function
                 * for web service request
                 */
                if(majorCourseTextCtrl.text == "" || educationTextCtrl.text == ""){
                  ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "EMPTY INPUT!",
                        text: "Both text fields cannot be blank!",
                      )
                  );
                }
                else {
                  addResume();
                }

              },
              child: Container(
                width: double.infinity,
                height: 40,
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
                      "Save",
                      style: GoogleFonts.poppins(
                          fontSize: 25, color: Colors.white,
                          fontWeight: FontWeight.w600
                      )),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
