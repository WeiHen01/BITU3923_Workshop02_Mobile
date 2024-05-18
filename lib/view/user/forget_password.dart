import 'package:bitu3923_group05/view/user/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';

class ForgetPassword extends StatefulWidget {
  final String usertypePassed;
  const ForgetPassword({required this.usertypePassed});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  TextEditingController emailTextCtrl = TextEditingController();
  int userid = 0;
  String UserType = "";

  Future<void> validateReset() async{
    if(emailTextCtrl.text == ""){
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "EMPTY INPUT!",
          text: "You must enter email for resetting password!",
        ),

      );
    }
    else{
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
          path: "/inployed/user/allusers/email/${widget.usertypePassed}/${emailTextCtrl.text}",
          server: "http://$server:8080");
      await req.get();
      // final response = await http.get(Uri.parse('http://10.0.2.2:8080/inployed/user/allusers/email/${userType}/${emailTextCtrl.text}'));

      try{
        if (req.status() == 200) {
          // Parse the JSON response into a `User` object.
          final user = User.fromJson(req.result());

          setState(() {
            userid = user.userId;
            UserType = user.userType;

            ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.success,
                title: "ACCOUNT FOUND!",
                text: "The email is valid! You may reset your password now. "
                    "UserType = ${UserType} ",
                onConfirm: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPassword(user: userid, usertype: UserType,)),
                  );
                },
              ),

            );

          });
        } else {
          ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "ACCOUNT MISSING!",
              text: "This account is not exist!",
            ),

          );
          throw Exception('Failed to fetch user');
        }
      }catch(e){
        print('Error fetching user : $e');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.usertypePassed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              Color.fromRGBO(249, 151, 119, 1),
              Color.fromRGBO(98, 58, 162, 1),// #a6c1ee
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("images/forgot_password.png", height: 450),

              Text("FORGET PASSWORD",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 30, color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFF545454),
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                      ),
                    ],
                  )
              ),

              SizedBox(height: 15),

              Text("Please enter the email address when you joined and "
                  "we will send you instruction to reset your password",
                  style: GoogleFonts.poppins(
                    fontSize: 15, color: Colors.white,
                  ), textAlign: TextAlign.justify,
              ),

              SizedBox(height: 10),

              TextField(
                controller: emailTextCtrl,
                decoration: InputDecoration(
                  //errorText: 'Please enter a valid value',
                    prefixIcon: Icon(Icons.mail),
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Enter your email address",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold
                    ),
                    labelText: "Enter your email address",
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 15,
                    )
                ),
                style: GoogleFonts.poppins(
                    fontSize: 15
                ),
              ),


              SizedBox(height: 30),

              /**
               * The register button
               */
              InkWell(
                onTap: ()
                {
                  /**
                   * Navigate to register() function
                   * for web service request
                   */
                  validateReset();

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
                        "Request Reset Password",
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
      ),
    );
  }
}
