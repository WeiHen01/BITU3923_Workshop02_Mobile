import 'package:bitu3923_group05/view/company/Company%20Create.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/company.dart';
import 'Company Login.dart';


class SelectCompany extends StatefulWidget {
  final int user;
  const SelectCompany({required this.user});

  @override
  State<SelectCompany> createState() => _SelectCompanyState();
}

class _SelectCompanyState extends State<SelectCompany> {

  /**
   * This is to retrieve all advertisements posted
   */
  late List<Company> companies = [];
  Future<void> getCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/company",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        companies = data.map((json) => Company.fromJson(json)).toList();
      });
      //return data.map((company) => Company.fromJson(company)).toList();
    } else {
      throw Exception('Failed to fetch job');
    }
  }

  int? selectedCompanyId;

  /**
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>updateUserCompany(int? company) async
  {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/updateUserCompany/${widget.user}/${company}",
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Image.asset(
                      'images/company_select.png',
                      height: 350, width: 350),

                  Text("Select Your Company",
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

                  Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: DropdownButton(
                        isExpanded: true,
                        onChanged: (dynamic newValue){
                          setState(() {
                            print(newValue);
                            selectedCompanyId = newValue;
                          });
                        },
                        value: selectedCompanyId,
                        hint: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Icon(Icons.date_range),

                              SizedBox(width: 5),

                              Text("Select company", style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18,
                              )),
                            ],
                          ),
                        ),
                        items: companies.map((Company company){
                          return DropdownMenuItem(
                            child: Container(
                              color: Colors.white70,
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "${company.companyName}", style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18,
                              ),
                              ),
                            ),
                            value: company.companyId,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height:50),

                  InkWell(
                    onTap: () async
                    {
                      updateUserCompany(selectedCompanyId);
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

                  SizedBox(height:10),

                  InkWell(
                    onTap: () async
                    {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CreateCompany(user: widget.user,)));
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
                            "Create new company",
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
      ),
    );
  }
}
