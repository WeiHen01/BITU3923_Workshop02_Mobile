import 'dart:convert';  //for json encode/decode

import 'package:bitu3923_group05/models/company.dart';
import 'package:bitu3923_group05/view/widget/register_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:art_sweetalert/art_sweetalert.dart';

import 'package:crypto/crypto.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';
import '../user/forget_password.dart';
import '../widget/login_role.dart';
import 'adminhome_navi.dart';


/**
 * This is the login screen
 */
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {

  /**
   * Variables
   * 1. _password -> for Show/Hide password
   */
  bool _password = false;

  /**
   * This is the function to show and hide password
   */
  void togglePassword()
  {
    setState(() {
      _password = !_password;
    });
  }

  /**
   * Variables for controlling text fields
   */
  User user = User(0, "", "", "", "", "Admin", "",
      Company(0, "", "", "", "", "", "", ""),"");
  TextEditingController usernameTextCtrl = TextEditingController();
  TextEditingController passwordTextCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  /**
   * User login web service function
   */
  Future login() async{

    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(path: "/inployed/user/adminLogin",
          server: "http://$server:8080");

      req.setBody(
          {
            'username': usernameTextCtrl.text,
            'userPassword':  md5.convert(utf8.encode(passwordTextCtrl.text)).toString(),
          }
      );

      await req.post();
      print(req.result());


      /**
       * if HTTP response status code = 200, means OK
       * it will let user login successfully
       * and navigate to HomeNavi()
       */
      if (req.status() == 200) {
        // Successful login
        final userData = req.result();
        int id = userData["userId"];
        String userType = userData["userType"];

        // Handle the user data as needed
        // For example, you can navigate to the home screen or save user details to the app state.
        Fluttertoast.showToast(
          msg: 'Login Successfully！ Welcome, ${usernameTextCtrl.text}!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );

        String loggedUsername = usernameTextCtrl.text;
        OneSignal.login(id.toString());


        /** saving key **/
        final prefs = await SharedPreferences.getInstance();

        prefs.setString("usertype", userType);
        prefs.setInt("loggedUserId", id);
        prefs.setString("password",
            md5.convert(utf8.encode(passwordTextCtrl.text)).toString());
        prefs.setString("loggedUsername", loggedUsername);

        UpdateLoginDateTime(id);

        // clear the text field
        usernameTextCtrl.clear();
        passwordTextCtrl.clear();

        // navigate to HomeNavi() screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AdminHomeNavi(
                    username: loggedUsername, userid: id, tabIndexes: 0,),
            ), (route) => false);
      }
      else if(req.status() == 401){
        //final errorMessage = json.decode(response.body);
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "INVALID EMAIL OR PASSWORD",
              text: "Wrong combination of user email and password",
            )
        );
        // Display the error message to the user
      }
      else{
        Fluttertoast.showToast(
          msg: 'Error',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          fontSize: 16.0,
        );
      }
    }
    else {
      /**
       * Here we request web service using URL API
       * for login module
       */
      if (usernameTextCtrl.text == "" || passwordTextCtrl.text == "") {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.danger,
              title: "EMPTY INPUT!",
              text: "Both text fields cannot be blank!",
            )
        );
      }
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
  Future<void>UpdateLoginDateTime(int? userId) async
  {
    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String applyStartDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String applyStartTime = _formatTimeIn12Hour(currentDay);

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/updateLoginTimeDate/${userId}/${applyStartDate}/${applyStartTime}",
        server: "http://$server:8080");

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Your login timestamp is recorded successfully!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
    else{
      Fluttertoast.showToast(
        msg: 'Fail to record your login timestamp!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }



  /**
   * The UI or front-end design
   */
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
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      /**
                       * Illustration
                       */
                      Image.asset("images/login01.png",
                        height: 250, width: 160,),

                      //Spacing
                      SizedBox(width: 20),

                      /**
                       * Title
                       */
                      Column(
                        children: [
                          Text("ADMIN",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF545454),
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              )),
                          Text("LOGIN",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF545454),
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Center(
                        /**
                         * Create a region box for login form
                         */
                        child: Container(
                            padding: EdgeInsets.all(20),
                            height: 480,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFF3F3F3), Color(0xFFC8C8C8)],
                                ),
                                borderRadius: BorderRadius.circular(15)
                            ),

                            child: Column(
                              children: [
                                /**
                                 * The Username Field
                                 */
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
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
                                 * The Password Field
                                 */
                                TextFormField(
                                  // Hide text when _password is false
                                  obscureText: !_password,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                  controller: passwordTextCtrl,
                                  decoration: InputDecoration(
                                    //errorText: 'Please enter a valid value',
                                      filled: true,
                                      fillColor: Colors.white70,
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: Tooltip(
                                        message: _password ? 'Hide Password' : 'Show Password',
                                        child: IconButton(
                                          onPressed: togglePassword,
                                          icon: Icon(_password
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
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

                                 Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("Forget Password?",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.black, fontSize: 15
                                              )
                                          ),
                                          TextButton(onPressed: (){
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context)
                                                => ForgetPassword(usertypePassed: "Admin",)));
                                          }, child: Text("Reset here",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black, fontSize: 15
                                            ),),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20),

                                /**
                                 * Login button
                                 */
                                InkWell(
                                  onTap: ()
                                  {
                                    /**
                                     * Navigate to login() function
                                     * for web service request
                                     */
                                    login();

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
                                          "Login",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20, color: Colors.white,
                                              fontWeight: FontWeight.w600
                                          )),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                InkWell(
                                  onTap: ()
                                  {
                                    /**
                                     * Navigate to login() function
                                     * for web service request
                                     */
                                    Navigator.push(context, MaterialPageRoute(builder:
                                        (context) => UserRole())
                                    );
                                  },
                                  child: Container(
                                    width: 300,
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
                                          "Change Role",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20, color: Colors.black,
                                              fontWeight: FontWeight.w600
                                          )),
                                    ),
                                  ),
                                ),

                                 Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("No account yet?",
                                        style: GoogleFonts.poppins(
                                            color: Colors.black
                                        )),
                                    TextButton(onPressed: (){
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context)
                                          => UserRegisterRole()));
                                    }, child: Text("Create an account?",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),
                              ],
                            )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}
