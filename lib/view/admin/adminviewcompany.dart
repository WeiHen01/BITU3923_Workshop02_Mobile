import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../controller/request_controller.dart';
import '../../models/company.dart';
import '../../models/user.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';


class AdminCompanyAccount extends StatefulWidget {
  const AdminCompanyAccount({required this.username});
  final String username;

  @override
  State<AdminCompanyAccount> createState() => _AdminCompanyAccountState();
}


class _AdminCompanyAccountState extends State<AdminCompanyAccount> {

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
        path: "/inployed/user/account/allcompanyUser/${widget.username}",
        server: "http://$server:8080");

    await req.get();

    try {
      if (req.status() == 200) {
        // Parse the JSON response into a `User` object.

        final user = User.fromJson(req.result());

        setState(() {
          _user = user;
          userid = user.userId;
          print("User: $userid");
          fetchProfileImage(userid);
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print('Error fetching user : $e');
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

  late List<Company> company = [];
  /**
   * lists to extract attributes needed
   */
  late List<String> companyNames = [];
  late List<int> companyIds = [];
  late List<dynamic> companyList = [];
  Company? selectedCompany;

  Future<void> getAllCompany() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/company",
        server: "http://$server:8080");

    await req.get();
    try{
      if (req.status() == 200) {
        final List<dynamic> responseData = req.result();
        setState(() {
          company = responseData.map((json) => Company.fromJson(json)).toList();

          print(company);
          //print(companyList);
          print("Number of company: ${company.length}");

        });
      } else {
        throw Exception('Failed to load job applications');
      }
    } catch (e) {
      print('Error fetching user resume: $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3));
    getUser();
    getAllCompany();
  }

  @override
  Widget build(BuildContext context) {

    /**
     * default value for Company selection
     */

    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){
                // _showBottomSheet(context);
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
      body: Container(
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
             * Company
             */
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                  "${
                                      (_user?.company != null)
                                          ? _user?.company?.companyName
                                          : ""
                                  }",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600 )
                              ),

                              Spacer(),
                            ],
                          ),

                          SizedBox(height: 10),

                          Text(
                              "ID: ${_user?.company?.companyId}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,)
                          ),

                          Text(
                            'Address: ${_user?.company?.companyCity}, '
                                '${_user?.company?.companyState},'
                                '${_user?.company?.companyCountry}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,),
                            textAlign: TextAlign.justify,
                          ),

                          Text(
                              'Contact: ${_user?.company?.companyContact}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,)
                          ),

                          Text(
                              'Email: ${_user?.company?.companyEmail}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,)
                          ),
                        ],
                      )
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}