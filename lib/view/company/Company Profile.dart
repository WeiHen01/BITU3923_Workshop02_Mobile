import 'dart:typed_data';

import 'package:bitu3923_group05/view/widget/login_role.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../controller/request_controller.dart';
import '../../models/company.dart';
import '../../models/user.dart';
import '../user/home_navi.dart';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'Company Profile Edit.dart';

class CompanyAccount extends StatefulWidget {
  const CompanyAccount({Key? key, required this.username, required this.userid, required this.company}) : super(key: key);
  final int company;
  final int userid;
  final String username;

  @override
  State<CompanyAccount> createState() => _CompanyAccountState();
}


class _CompanyAccountState extends State<CompanyAccount> {

  User? _user;
  int userid = 0;
  int userCompany = 0;

  String? companyName;
  String? companyCity;
  String? companyState;
  String? companyCountry;
  String? companyEmail;
  String? companyContact;

  TextEditingController companyNameCtrl = TextEditingController();
  TextEditingController companyCityCtrl = TextEditingController();
  TextEditingController companyStateCtrl = TextEditingController();
  TextEditingController companyCountryCtrl = TextEditingController();
  TextEditingController companyEmailCtrl = TextEditingController();
  TextEditingController companyContactCtrl = TextEditingController();

  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getUser() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/company/${widget.username}",
        server: "http://$server:8080");

    await req.get();


    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final Map<String, dynamic> responseData = req.result();
      final user = User.fromJson(responseData);

      setState(() {
        _user = user;
        userid = user.userId;

        selectedCompanyId = _user?.company?.companyId;
        companyNameCtrl.text = _user?.company?.companyName ?? "";
        companyCityCtrl.text = _user?.company?.companyCity ?? "";
        companyStateCtrl.text = _user?.company?.companyState ?? "";
        companyCountryCtrl.text = _user?.company?.companyCountry ?? "";
        companyContactCtrl.text = _user?.company?.companyContact ?? "";
        companyEmailCtrl.text = _user?.company?.companyEmail ?? "";

        print("User ID: $userid");
        if (_user?.company != null) {
          print("Company Name: ${_user?.company?.companyName}");
        } else {
          print("Company not available");
        }

        fetchProfileImage(user.userId);

      });
    } else {
      throw Exception('Failed to fetch user');
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


  Future<void> updateCompany(int id) async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (companyNameCtrl.text != null && companyNameCtrl.text.isNotEmpty) {
      requestBody["companyName"] = companyNameCtrl.text;
    }

    if (companyCityCtrl.text != null && companyCityCtrl.text.isNotEmpty) {
      requestBody["companyCity"] = companyCityCtrl.text;
    }

    if (companyStateCtrl.text != null && companyStateCtrl.text.isNotEmpty) {
      requestBody["companyState"] = companyStateCtrl.text;
    }

    if (companyCountryCtrl.text != null && companyCountryCtrl.text.isNotEmpty) {
      requestBody["companyCountry"] = companyCountryCtrl.text;
    }

    if (companyContactCtrl.text != null && companyContactCtrl.text.isNotEmpty) {
      requestBody["companyContact"] = companyCountryCtrl.text;
    }

    if (companyEmailCtrl.text != null && companyEmailCtrl.text.isNotEmpty) {
      requestBody["companyEmail"] = companyEmailCtrl.text;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/company/update/company/$id",
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
  String? selectedCompanyName;

  /**
   * Functions for Soft delete account
   * by disable account status(update user status to inactive)
   */
  Future<void>updateUserCompany(int? company) async
  {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/updateUserCompany/${widget.userid}/${company}",
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
    }
    else{
      Fluttertoast.showToast(
        msg: 'Update user company failed!',
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
    Future.delayed(Duration(seconds: 3));
    getUser();
    getCompanies();
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
          height: 300,
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
                              builder: (context) => UserRole(),
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
                              builder: (context) => UserRole(),
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

                      }
                    }, child: Text("Delete this account", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18
                    ))
                    )
                  ],
                ),


              ],
            ),
          ),
        );
      },
    );
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
                      print("user id here : $userid");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CompanyEdit(id: userid, company: widget.company))
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
             * Company
             */
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  "${
                                      (_user?.company != null)
                                       ? _user?.company?.companyName
                                       : ""
                                   }",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600 )
                              ),
                            ),

                            Spacer(),

                            Column(
                              children: [
                                IconButton(onPressed:(){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) => Center(
                                        child: SingleChildScrollView(
                                          child: Dialog(
                                            elevation: 10,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              width: 500,
                                              height: 250,
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
                                                          "Edit your company",
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

                                                            // Get the selected company name based on the newValue
                                                            Company selectedCompany = companies
                                                                .firstWhere((company) => company.companyId == newValue);
                                                            selectedCompanyName = selectedCompany.companyName;

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

                                                  Spacer(),

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async
                                                        {
                                                          /**
                                                           * Navigate to login() function
                                                           * for web service request
                                                           */
                                                          print(companyNames);
                                                          updateUserCompany(selectedCompanyId);

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
                                          ),
                                        ),
                                      )
                                  );
                                }, icon: Icon(Icons.mode_edit_outlined, color: Colors.black,)),
                              ],
                            ),


                          ],
                        ),

                        Divider(
                          thickness: 2
                        ),

                        SizedBox(height: 10),



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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => SingleChildScrollView(
                                    child: Dialog(
                                      elevation: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        width: 500,
                                        height: 750,
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
                                                    "Edit your company details",
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
                                                padding: EdgeInsets.all(5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "Name: ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    SizedBox(height: 10),

                                                    TextField(
                                                      controller: companyNameCtrl,
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

                                                    Text(
                                                        "Email: ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    SizedBox(height: 10),

                                                    TextField(
                                                      controller: companyEmailCtrl,
                                                      decoration: InputDecoration(
                                                        //errorText: 'Please enter a valid value',
                                                          prefixIcon: Icon(Icons.person),
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

                                                    Text(
                                                        "Contact Number:  ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    SizedBox(height: 10),

                                                    TextField(
                                                      controller: companyContactCtrl,
                                                      decoration: InputDecoration(
                                                        //errorText: 'Please enter a valid value',
                                                          prefixIcon: Icon(Icons.person),
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

                                                    Text(
                                                        "City:  ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    SizedBox(height: 10),

                                                    TextField(
                                                      controller: companyCityCtrl,
                                                      decoration: InputDecoration(
                                                        //errorText: 'Please enter a valid value',
                                                          prefixIcon: Icon(Icons.person),
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

                                                    Text(
                                                        "State:  ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    TextField(
                                                      controller: companyStateCtrl,
                                                      decoration: InputDecoration(
                                                        //errorText: 'Please enter a valid value',
                                                          prefixIcon: Icon(Icons.person),
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

                                                    Text(
                                                        "Country:  ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        )
                                                    ),

                                                    SizedBox(height: 10),

                                                    TextField(
                                                      controller: companyCountryCtrl,
                                                      decoration: InputDecoration(
                                                        //errorText: 'Please enter a valid value',
                                                          prefixIcon: Icon(Icons.person),
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
                                                  ],
                                                )
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
                                                    print(companyNames);
                                                    updateCompany(_user?.company?.companyId ?? 0);

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
                                    ),
                                  )
                              );
                            }, icon: Icon(Icons.edit_square, color: Colors.black,)),
                          ],
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






