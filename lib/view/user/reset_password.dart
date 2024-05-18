import 'package:bitu3923_group05/view/company/Company%20Login.dart';
import 'package:bitu3923_group05/view/user/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:art_sweetalert/art_sweetalert.dart';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../controller/request_controller.dart';

class ResetPassword extends StatefulWidget {
  final int user;
  final String usertype;
  const ResetPassword({required this.user, required this.usertype});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  /**
   * Variables
   * 1. _password -> for Show/Hide password
   */
  bool _password = false;
  bool _confirmPass = false;

  /**
   * This is the function to show and hide password
   * for both password field and confirm password field
   */
  void togglePassword()
  {
    setState(() {
      _password = !_password;
    });
  }

  void toggleconfirmPassword()
  {
    setState(() {
      _confirmPass = !_confirmPass;
    });
  }

  TextEditingController passwordTextCtrl = TextEditingController();
  TextEditingController confirmPassTextCtrl = TextEditingController();

  Future<void> resetPassword() async{
    if(passwordTextCtrl.text == "" || confirmPassTextCtrl.text == ""){
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "EMPTY INPUT!",
            text: "Both text fields cannot be blank!",
          )
      );
    }
    else{
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
          path: "/inployed/user/resetJobseeker/${widget.user}",
          server: "http://$server:8080");

      req.setBody({
        'userpassword': md5.convert(utf8.encode(passwordTextCtrl.text)).toString(),
      });
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

        if(widget.usertype == "Job Seeker"){
          Navigator.push(context, MaterialPageRoute(builder:
              (context) => LoginPage())
          );
        }
        else if(widget.usertype == "Company"){
          Navigator.push(context, MaterialPageRoute(builder:
              (context) => CompanyLogin())
          );
        }
        else if(widget.usertype == "Admin"){
          Navigator.push(context, MaterialPageRoute(builder:
              (context) => LoginPage())
          );
        }

        /*Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => HomeNavi(username: username, tabIndexes: 3,)), (route) => false
        );*/
      }
      else
      {
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
              Image.asset("images/reset_password.png", height: 400),
              Text("RESET PASSWORD",
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
          
              Text("Please set new password",
                style: GoogleFonts.poppins(
                  fontSize: 15, color: Colors.white,
                ), textAlign: TextAlign.justify,
              ),
          
              SizedBox(height: 10),
          
              /**
               * The Password Field
               */
              TextField(
                // Hide text when _password is false
                obscureText: !_password,
                controller: passwordTextCtrl,
                decoration: InputDecoration(
                  //errorText: 'Please enter a valid value',
                    filled: true,
                    fillColor: Colors.white70,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: togglePassword,
                      icon: Icon(_password
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Enter your password",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold
                    ),
                    labelText: "Enter your password",
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 15,
                    )
                ),
                style: GoogleFonts.poppins(
                    fontSize: 15
                ),
              ),
          
              SizedBox(height: 20),
          
              /**
               * Confirm Password Field
               */
              TextField(
                // Hide text when _password is false
                obscureText: !_confirmPass,
                controller: confirmPassTextCtrl,
                decoration: InputDecoration(
                  //errorText: 'Please enter a valid value',
                    filled: true,
                    fillColor: Colors.white70,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: toggleconfirmPassword,
                      icon: Icon(_confirmPass
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Confirm your password",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold
                    ),
                    labelText: "Confirm your password",
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
                  resetPassword();
          
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
                        "Reset Password",
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
