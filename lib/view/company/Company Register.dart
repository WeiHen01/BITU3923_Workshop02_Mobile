import 'package:bitu3923_group05/models/user.dart';
import 'package:bitu3923_group05/view/company/Company%20Login.dart';
import 'package:bitu3923_group05/view/widget/login_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/company.dart';
import '../widget/register_role.dart';
import 'SelectCompany_register.dart';

/**
 * This is the user registration screen
 */

class CompanyRegister extends StatefulWidget {
  const CompanyRegister({super.key});

  @override
  State<CompanyRegister> createState() => _CompanyRegisterState();
}

class _CompanyRegisterState extends State<CompanyRegister> {

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

  /**
   * The text field controllers
   */
  TextEditingController usernameTextCtrl = TextEditingController();
  TextEditingController emailTextCtrl = TextEditingController();
  TextEditingController positionTextCtrl = TextEditingController();
  TextEditingController passwordTextCtrl = TextEditingController();
  TextEditingController confirmPassTextCtrl = TextEditingController();

  /**
   * default register url for web service api
   */
  // default real device to mysql localhost : 127.0.0.1
  // every device has its own localhost
  // default localhost address for emulator: 10.0.2.2
  String url = "http://10.0.2.2:8080/inployed/user/register";

  User user = User(0, "", "", "", "", "Company", "",
      Company(0, "", "", "", "", "", "", ""), "");
  /**
   * User registration web service function
   */
  Future register() async{

    // empty input validation
    if(usernameTextCtrl.text == "" || passwordTextCtrl.text == ""
        || emailTextCtrl.text == "" || positionTextCtrl.text == ""
        || confirmPassTextCtrl.text == ""){
      Fluttertoast.showToast(
        msg: 'All text fields cannot be blank',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
    else{
      // password and confirm password validation
      if(passwordTextCtrl.text != confirmPassTextCtrl.text){
        Fluttertoast.showToast(
          msg: 'Your password is not matched with confirm password field!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      }
      else{
        user.username = usernameTextCtrl.text;
        user.userEmail = emailTextCtrl.text;
        user.userPosition = positionTextCtrl.text;
        user.password = md5.convert(utf8.encode(passwordTextCtrl.text)).toString();

        /**
         * save the data registered to database
         */
        final prefs = await SharedPreferences.getInstance();
        String? server = prefs.getString("localhost");
        WebRequestController req = WebRequestController
          (path: "/inployed/user/register",
            server: "http://$server:8080");

        req.setBody(
            {
              'username': user.username,
              'userEmail': user.userEmail,
              'userPosition': user.userPosition,
              'userpassword': user.password,
              'userType': 'Company',
              'userStatus': 'Active',
              "company": null,
              "adminID": "1"
            }
        );

        await req.post();

        print(req.result());


        if (req.result()!= null) {

          var responseBody = req.result();
          var userString = responseBody['userId'];

          Fluttertoast.showToast(
            msg: 'Successful registered! You will be redirected to',
            backgroundColor: Colors.white,
            textColor: Colors.red,
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_LONG,
            fontSize: 16.0,
          );

          // after 5 seconds then auto navigate to next screen
          Future.delayed(Duration(seconds: 5), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectCompany(user: userString),
                ), (route) => false);
          });
        }

        else
        {
          Fluttertoast.showToast(
            msg: 'Registration failed!',
            backgroundColor: Colors.white,
            textColor: Colors.red,
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  /**
                   * Title
                   */
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("COMPANY",
                          style: GoogleFonts.poppins(
                              shadows: [
                                Shadow(
                                  color: Color(0xFF545454),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 4.0,
                                ),
                              ],
                              fontWeight: FontWeight.bold,
                              fontSize: 35
                          )),

                      Text("SIGN UP",
                          style: GoogleFonts.poppins(
                              shadows: [
                                Shadow(
                                  color: Color(0xFF545454),
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 4.0,
                                ),
                              ],
                              fontWeight: FontWeight.bold,
                              fontSize: 35
                          )),
                    ],
                  ),

                  //Spacing
                  SizedBox(width: 15),

                  /**
                   * Illustration
                   */
                  Image.asset("images/register01.png",
                    height: 200, width: 140,),
                ],
              ),
              Column(
                children: [
                  Center(
                    /**
                     * Create a region box for login form
                     */
                    child: Container(
                      padding: EdgeInsets.all(15),
                      height: 600, width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Column(
                        children: [
                          /**
                           * The Username Field
                           */
                          TextField(
                            controller: usernameTextCtrl,
                            decoration: InputDecoration(
                              //errorText: 'Please enter a valid value',
                                prefixIcon: Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Enter your username",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Enter your username",
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
                           * The email address field
                           */
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

                          SizedBox(height: 20),

                          /**
                           * User position field
                           */
                          TextField(
                            controller: positionTextCtrl,
                            decoration: InputDecoration(
                              //errorText: 'Please enter a valid value',
                                prefixIcon: Icon(Icons.work),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Enter your position",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Enter your position",
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

                          /**
                           * The text which navigate to login screen
                           * if user already has an existing account
                           */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Already have an account?",
                                  style: GoogleFonts.poppins(

                                  )),
                              TextButton(onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context)
                                    => UserRole()));
                              }, child: Text("Login Now",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700
                                ),)),
                            ],
                          ),


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
                              register();

                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
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
                                    "Register",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.white,
                                        fontWeight: FontWeight.w600
                                    )),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

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
                              Navigator.push(context, MaterialPageRoute(builder:
                                  (context)=>UserRegisterRole()));

                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
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
                                    "Change Role",
                                    style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    )),
                              ),
                            ),
                          ),

                        ],
                      ),


                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ),
    );
  }
}
