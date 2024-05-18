import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/resume.dart';
import '../../models/user.dart';
import '../user/view_resumeFile.dart';

class ViewOtherAccount extends StatefulWidget {
  const ViewOtherAccount({required this.username});
  final String username;

  @override
  State<ViewOtherAccount> createState() => _ViewOtherAccountState();
}

class _ViewOtherAccountState extends State<ViewOtherAccount> {

  User? _user;
  int userid = 0;
  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getUser() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/${widget.username}",
        server: "http://$server:8080");

    await req.get();

    try{
      if (req.status() == 200) {

        // Parse the JSON response into a `User` object.
        final user = User.fromJson(req.result());

        setState(() {
          _user = user;
          userid = user.userId;
          print("User: $userid");
          getUserResume(user.userId);
          fetchProfileImage(user.userId);
          fetchFileDetails(user.userId);
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  int resumeId = 0;
  Resume? _resume;
  String education = "";
  String major = "";

  Future <void> getUserResume(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
          path: "/inployed/resume/$id",
          server: "http://$server:8080");

      await req.get();

      if (req.status() == 200) {
        // Parse the JSON response into a `Resume` object.
        final resume = Resume.fromJson(req.result());

        setState(() {
          _resume = resume;
          education = resume.educationLvl;
          major = resume.major;
          resumeId = resume.resumeId;
        });
      } else {
        throw Exception('Failed to fetch user resume');
      }
    } catch (e) {
      print('Error fetching user resume: $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  String filename = "Loading...";
  Future<void> fetchFileDetails(int user) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(
      Uri.parse('http://$server:8080/inployed/file/getResumeDetails/${user}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        filename = responseData['name'];
      });
    } else {
      // Handle error cases here, e.g., display an error message.
      setState(() {
        filename = 'File not found';
      });
    }
  }

  String imageUrl = "images/avatar01.jpg";
  Uint8List? _images; // Default image URL
  Future<void> fetchProfileImage(int userid) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/inployed/image/getProfileImage/${userid}')
    );

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.username);
    getUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.lock, size: 26,),
            SizedBox(width: 5),
            Text('${_user?.username ?? 'Loading username...'}', style: GoogleFonts.poppins(
                fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      ),
      body:
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFBC2EB), // #fbc2eb
                Color(0xFFA6C1EE), // #a6c1ee
              ],
            )
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(249, 151, 119, 1),
                    Color.fromRGBO(98, 58, 162, 1),
                  ],
                  stops: [0.0, 0.9],
                  transform: GradientRotation(358.4 * (3.1415926 / 180)),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey,
                    offset: Offset(0, 10),
                    blurRadius: 26,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('${_user?.username ?? 'Loading username...'}', style: GoogleFonts.poppins(
                            fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        // username
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_user?.username ?? 'Loading username...'}', textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold,
                                )
                            ),

                            Text('${_user?.userEmail ?? 'Loading user email...'}', textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                )
                            ),
                          ],
                        ),

                        Spacer(),

                        Container(
                          width: 100, height: 100, decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2, blurRadius: 10, color: Colors.black.withOpacity(0.1)
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: _images != null
                                ? DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(_images!)
                            )
                                : DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(imageUrl)
                            )
                        ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5),

            /**
             * User Resume
             */
            SingleChildScrollView(
              child: Card(
                elevation: 10,
                margin: EdgeInsets.all(10),
                child: Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                            "Resume",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600 )
                        ),

                        SizedBox(height: 15),

                        Text(
                            "Education : ${_resume?.educationLvl}",
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),

                        Text(
                            "Major : ${_resume?.major}",
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),

                        Text(
                            "Position : ${_user?.userPosition}",
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),

                        Spacer(),

                      ],
                    )
                ),
              ),
            ),

            Card(
              elevation: 10,
              margin: EdgeInsets.only(
                  left: 10, top: 5, bottom: 5, right: 10
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    left: 5, top: 5, bottom: 5, right: 10
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ Color.fromRGBO(249, 151, 119, 1),
                        Color.fromRGBO(98, 58, 162, 1),]
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>UserResumeViewFile(user: userid)));
                      },
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.file_copy_rounded, size: 35,),
                      ),
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Resume Document ", style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
                          ),),

                          Text("$filename", style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                          ),),


                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )


          ],
        ),
      ),
    );
  }
}
