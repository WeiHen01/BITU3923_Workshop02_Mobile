import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:bitu3923_group05/view/company/Company%20Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';

class CreateCompany extends StatefulWidget {
  final int user;
  const CreateCompany({required this.user});

  @override
  State<CreateCompany> createState() => _CreateCompanyState();
}

class _CreateCompanyState extends State<CreateCompany> {

  TextEditingController usernameTextCtrl = TextEditingController();
  TextEditingController emailTextCtrl = TextEditingController();
  TextEditingController contactTextCtrl = TextEditingController();
  TextEditingController cityTextCtrl = TextEditingController();
  TextEditingController stateTextCtrl = TextEditingController();
  TextEditingController countryTextCtrl = TextEditingController();

  /**
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>updateUserCompany(int user, int company) async
  {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/updateUserCompany/${user}/${company}",
        server: "http://$server:8080");

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update user company successfully',
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

      // navigate to HomeNavi() screen
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyLogin()
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

  Future<void> addnewCompany() async {


    if(usernameTextCtrl.text == "" || emailTextCtrl.text == ""
        || contactTextCtrl.text == "" || cityTextCtrl.text == ""
        || stateTextCtrl.text == "" || countryTextCtrl.text == ""){
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "EMPTY INPUT!",
            text: "You must input all the text fields!",
          )
      );
    }
    else {
      /**
       * save the data registered to database
       */
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController
        (path: "/inployed/company/addCompany",
          server: "http://$server:8080");

      req.setBody(
          {
            "companyName": usernameTextCtrl.text,
            "companyCity": cityTextCtrl.text,
            "companyState": stateTextCtrl.text,
            "companyCountry": countryTextCtrl.text,
            "companyEmail": emailTextCtrl.text,
            "companyContact": contactTextCtrl.text,
            "companyStatus": "Active"
          }
      );

      await req.post();

      print(req.result());

      if (req.result()!= null) {

        final companyData = req.result();
        int companyId = companyData["companyID"];
        print(companyId);

        Fluttertoast.showToast(
          msg: 'Successful create new company!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          fontSize: 16.0,
        );

        updateUserCompany(widget.user, companyId);

        Future.delayed(Duration(seconds: 3));
        usernameTextCtrl.clear();
        cityTextCtrl.clear();
        stateTextCtrl.clear();
        countryTextCtrl.clear();
        emailTextCtrl.clear();
        contactTextCtrl.clear();



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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create your company", style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.bold),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        ),

        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [

                Text("New Company",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 25, color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xFF545454),
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                        ),
                      ],
                    )
                ),

                SizedBox(height: 20),

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
                      hintText: "Enter company name",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company name",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),

                SizedBox(height: 10),

                TextField(
                  controller: emailTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter company email",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company email",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),


                SizedBox(height: 10),

                TextField(
                  controller: contactTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.phone),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter company contact",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company contact",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),

                SizedBox(height: 10),

                TextField(
                  controller: cityTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.location_city),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter company city",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company city",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),

                SizedBox(height: 10),

                TextField(
                  controller: stateTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.location_on),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter company state",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company state",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),


                SizedBox(height: 10),

                TextField(
                  controller: countryTextCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.flag),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter company country",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter company country",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),

                ),

                SizedBox(height:50),

                InkWell(
                  onTap: () async
                  {
                    addnewCompany();
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
                          "Save your details",
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
      ),
    );
  }
}
