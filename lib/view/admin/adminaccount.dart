import 'dart:convert';
import 'dart:typed_data';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/request_controller.dart';
import '../../models/user.dart';
import '../widget/login_role.dart';
import 'adminedit.dart';
import 'adminhome_navi.dart'; // Assuming you have a file for CompanyEdit

class AdminAccount extends StatefulWidget {
  const AdminAccount({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<AdminAccount> createState() => _AdminAccountState();
}

class _AdminAccountState extends State<AdminAccount> {
  User? _user; // Initialize with default values
  int userid = 0;
  int adminId = 0;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(path: "/inployed/user/account/admin/${widget.username}",
          server: "http://$server:8080");

      await req.get();


      if (req.status() == 200) {
        final Map<String, dynamic> responseData = req.result();
        final user = User.fromJson(responseData);

        setState(() {
          _user = user;
          userid = user.userId;
          print("User ID: $userid");
          fetchProfileImage(user.userId);
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (error) {
      print('Error fetching user: $error');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _showBottomSheet(context);
                },
                icon: const Icon(Icons.more_vert),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
              ),
            ],
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(249, 151, 119, 1),
                Color.fromRGBO(98, 58, 162, 1),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFBC2EB),
              Color(0xFFA6C1EE),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(249, 151, 119, 1),
                    Color.fromRGBO(98, 58, 162, 1),
                  ],
                  stops: [0.0, 0.9],
                  transform: GradientRotation(358.4 * (3.1415926 / 180)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey,
                    offset: const Offset(0, 10),
                    blurRadius: 26,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text(
                          '${_user?.username ?? 'Loading username...'}',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_user?.username ?? 'Loading username...'}',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_user?.userEmail ?? 'Loading user email...'}',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                              ),
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
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEdit(id: userid),
                        ),
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

                  SizedBox(height: 10),

                  Image.asset("images/admin.png")

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

}

