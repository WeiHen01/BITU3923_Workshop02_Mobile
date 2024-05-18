import 'dart:typed_data';

import 'package:bitu3923_group05/models/user.dart';
import 'package:bitu3923_group05/view/company/CompanyHome_Navi.dart';
import 'package:bitu3923_group05/view/user/edit_profile.dart';
import 'package:bitu3923_group05/view/user/resume.dart';
import 'package:bitu3923_group05/view/user/view_resumeFile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/resume.dart';
import 'login.dart';

/**
 * This is the account screen
 * where users can view their personal info
 * after user login successfully
 */

class Account extends StatefulWidget {

  const Account({Key? key, required this.username}) : super(key: key);
  final String username;
  //const Account({required this.username});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {


  int resumeId = 0;
  Resume? _resume;
  String education = "";
  String major = "";

  Future <void> getUserResume(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(path: "/inployed/resume/$id",
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





  Future<void> updateResumeDetails(int? resume) async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (majorTxt.text != null && majorTxt.text.isNotEmpty) {
      requestBody["major"] = majorTxt.text;
      major = majorTxt.text;
    }

    if (educationTxt.text != null && educationTxt.text.isNotEmpty) {
      requestBody["educationLvl"] = educationTxt.text;
      education = educationTxt.text;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/resume/update/${resume}",
        server: "http://$server:8080");

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update successfully',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          educationTxt.clear();
          majorTxt.clear();
          Navigator.pop(context);
        });
      });

    }
    else{
      Fluttertoast.showToast(
        msg: 'Update failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
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
      if (req.status()== 200) {

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

  /**
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>deleteUser() async
  {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/delete/${userid}", server: "http://$server:8080");

    req.setBody(
        {
          "userId": userid,
          "userStatus": "Inactive"
        }
    );

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Deleted successfully',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      // clear all the keys registered in SharedPreferences
      await prefs.setInt("loggedUserId", 0);
      await prefs.setString("loggedUsername", "");
      await prefs.setString("usertype", "");
      await prefs.setInt("company", 0);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ), (route) => false);
    }
    else{
      Fluttertoast.showToast(
        msg: 'Delete failed!',
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
    print(widget.username);
    getUser();
  }

  /**
   * The drawer after click the icons.menu button
   * at the top right corner
   */
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: 250,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'What are you going to do?',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(onPressed: () async {
                      ArtDialogResponse response = await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              denyButtonText: "Cancel",
                              title: "Are you confirm to log out?",
                              text: "You have to login afterwards.",
                              confirmButtonText: "Yes",
                              type: ArtSweetAlertType.warning
                          )
                      );

                      if (response == null) {
                        return;
                      }

                      if (response.isTapConfirmButton) {

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("loggedUsername", "");
                        await prefs.setInt("loggedUserId", 0);
                        await prefs.setString("usertype", "");
                        OneSignal.logout();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ), (route) => false);
                      }
                    }, icon: Icon(Icons.logout),
                    ),

                    TextButton(onPressed: ()async {
                      ArtDialogResponse response = await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              denyButtonText: "Cancel",
                              title: "Are you confirm to log out?",
                              text: "You have to login afterwards.",
                              confirmButtonText: "Yes",
                              type: ArtSweetAlertType.warning
                          )
                      );

                      if (response == null) {
                        return;
                      }

                      if (response.isTapConfirmButton) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("loggedUsername", "");
                        await prefs.setInt("loggedUserId", 0);
                        await prefs.setString("usertype", "");
                        OneSignal.logout();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ), (route) => false);
                      }
                    }, child: Text("Log out", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18
                    )))

                  ],
                ),
                Row(
                  children: [
                    IconButton(onPressed: () async{
                      ArtDialogResponse response = await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              denyButtonText: "Cancel",
                              title: "Are you confirm to delete?",
                              text: "Your account data will be lost afterwards.",
                              confirmButtonText: "Yes",
                              type: ArtSweetAlertType.warning
                          )

                      );

                      if (response == null) {
                        return;
                      }

                      if (response.isTapConfirmButton) {
                        deleteUser();
                      }

                    }, icon: Icon(Icons.delete), style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),),

                    TextButton(onPressed: () async {
                      ArtDialogResponse response = await ArtSweetAlert.show(
                          barrierDismissible: false,
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                              denyButtonText: "Cancel",
                              title: "Are you confirm to delete?",
                              text: "Your account data will be lost afterwards.",
                              confirmButtonText: "Yes",
                              type: ArtSweetAlertType.warning
                          )
                      );

                      if (response == null) {
                        return;
                      }

                      if (response.isTapConfirmButton) {
                        deleteUser();
                      }
                    }, child: Text("Delete this account", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18
                    )))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /**
   * Variable for editing resume details dialog box
   */
  TextEditingController educationTxt = TextEditingController();
  TextEditingController majorTxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.lock, size: 26,),
            SizedBox(width: 5),
            Text('${_user?.username ?? 'Loading username...'}', style: GoogleFonts.poppins(
                fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){
                _showBottomSheet(context);
              }, icon: Icon(Icons.more_vert),
               style: ButtonStyle(
                   foregroundColor: MaterialStateProperty.all(Colors.black)
               ),
              ),
            ],
          ),
        ],
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

               Container(
                 padding: EdgeInsets.all(12),
                 decoration: BoxDecoration(
                     color: Colors.transparent,
                 ),
                 child: Column(
                   children: [
                     InkWell(
                       onTap: ()
                       {
                         /**
                          * Navigate to login() function
                          * for web service request
                          */
                         Navigator.push(context, MaterialPageRoute(
                           builder: (context) => UserEdit(id: _user?.userId,),),
                         );

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
                               "Edit your profile",
                               style: GoogleFonts.poppins(
                                   fontSize: 20, color: Colors.white,
                                   fontWeight: FontWeight.w600
                               )),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),

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


                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               IconButton(onPressed: (){
                                 showDialog(
                                     context: context,
                                     builder: (BuildContext context) => Dialog(
                                       elevation: 10,
                                       child: Container(
                                         padding: EdgeInsets.all(10),
                                         height: 350,
                                         decoration: BoxDecoration(
                                           gradient: LinearGradient(
                                               colors: [ Color.fromRGBO(249, 151, 119, 1),
                                                 Color.fromRGBO(98, 58, 162, 1),]
                                           ),
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Row(
                                               children: [
                                                 Text(
                                                     "Edit your resume details",
                                                     style: GoogleFonts.poppins(
                                                         fontSize: 20, fontWeight: FontWeight.bold,
                                                         color: Colors.white,
                                                     )
                                                 ),

                                                 Spacer(),

                                                 GestureDetector(
                                                   onTap: (){
                                                     Navigator.of(context).pop();
                                                   },
                                                   child: Icon(Icons.close, color: Colors.white,),
                                                 )
                                               ],
                                             ),

                                             SizedBox(height: 10),

                                             Container(
                                               decoration: BoxDecoration(
                                                 borderRadius: BorderRadius.circular(8),
                                                 color: Colors.white,
                                               ),
                                               width: double.infinity,
                                               padding: EdgeInsets.all(5),
                                               child: Column(
                                                 children: [
                                                   Row(
                                                     children: [
                                                       Text(
                                                           "Education Level",
                                                           style: GoogleFonts.poppins(
                                                             fontSize: 12, fontWeight: FontWeight.bold,
                                                             color: Colors.black,
                                                           )
                                                       ),

                                                       SizedBox(width: 10),

                                                       Expanded(
                                                         child: TextField(
                                                           controller: educationTxt,
                                                           decoration: InputDecoration(
                                                             labelText:  "Current: ${_resume?.educationLvl}",
                                                             labelStyle: GoogleFonts.poppins(
                                                               fontSize: 12,
                                                               color: Colors.black,
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),


                                                   Row(
                                                     children: [
                                                       Text(
                                                           "Major",
                                                           style: GoogleFonts.poppins(
                                                             fontSize: 12, fontWeight: FontWeight.bold,
                                                             color: Colors.black,
                                                           )
                                                       ),

                                                       SizedBox(width: 10),

                                                       Expanded(
                                                         child: TextField(
                                                           controller: majorTxt,
                                                           decoration: InputDecoration(
                                                             labelText:  "Current: ${_resume?.major}",
                                                             labelStyle: GoogleFonts.poppins(
                                                               fontSize: 12,
                                                               color: Colors.black,
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ],
                                               ),
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
                                                     int? resumesId = _resume?.resumeId;
                                                     updateResumeDetails(resumesId);

                                                   },
                                                   child: Container(
                                                     width: 300,
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
                                                               fontSize: 20, color: Colors.white,
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
                                     )
                                 );
                               }, icon: Icon(Icons.edit_square), color: Colors.black,),
                             ],
                           ),
                         ],
                       )
                   ),
                 ),
               ),

               SizedBox(height: 15),

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

                             SizedBox(height: 5),

                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: [
                                 IconButton(onPressed: (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>UserResume(userid:  _user?.userId,)));
                                 }, icon: Icon(Icons.edit_square), color: Colors.white,),

                                 IconButton(onPressed: (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>UserResume(userid:  _user?.userId)));
                                 }, icon: Icon(Icons.upload_file_rounded), color: Colors.white),
                               ],
                             )
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



