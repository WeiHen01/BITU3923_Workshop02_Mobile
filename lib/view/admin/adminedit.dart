import 'dart:io';
import 'dart:typed_data';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';
import 'adminhome_navi.dart';

class AdminEdit extends StatefulWidget {
  const AdminEdit({required this.id});
  final int id;

  @override
  State<AdminEdit> createState() => _AdminEditState();
}

class _AdminEditState extends State<AdminEdit> {

  User? _user;
  int id = 0;
  int adminId = 0;
  String username = "", email = "",
      phone = "", position = "", password = "";

  final TextEditingController usernamectrl = TextEditingController();
  final TextEditingController emailctrl = TextEditingController();
  final TextEditingController positionctrl = TextEditingController();
  final TextEditingController passwordctrl = TextEditingController();

  Future<void>UpdateLastEditedDateTime(int? userId) async
  {
    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String applyStartDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String applyStartTime = _formatTimeIn12Hour(currentDay);

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/LastupdatedTimeDate/${userId}/${applyStartDate}/${applyStartTime}",
        server: "http://$server:8080");

    await req.put();

    print(req.result());

    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Updated timestamp successfully!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
    else{
      Fluttertoast.showToast(
        msg: 'Fail to update timestamp!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  /**
   * Function to display account information
   * based on username passed from Login page
   */
  Future<void> getUser() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/adminId/${widget.id}",
        server: "http://$server:8080");

    await req.get();

    try{
      if (req.status()== 200) {

        // Parse the JSON response into a `User` object.
        final user = User.fromJson(req.result());

        setState(() {
          _user = user;

          username = user.username;
          email = user.userEmail;
          position = user.userPosition;
          password = user.password;

          usernamectrl.text = username;
          emailctrl.text = email;
          positionctrl.text = position;
          passwordctrl.text = password;

        });
      } else {
        throw Exception('Failed to fetch user');
      }
    }catch (e) {
      print('Error fetching user : $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }



  ImagePicker picker = ImagePicker();
  File? _image;

  /// Get from gallery
  _getFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> updateAdminAccount() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (usernamectrl.text != null && usernamectrl.text.isNotEmpty) {
      requestBody["username"] = usernamectrl.text;
      username = usernamectrl.text;
    }

    if (emailctrl.text != null && emailctrl.text.isNotEmpty) {
      requestBody["userEmail"] = emailctrl.text;
      email = emailctrl.text;
    }

    if (positionctrl.text != null && positionctrl.text.isNotEmpty) {
      requestBody["userPosition"] = positionctrl.text;
      position = positionctrl.text;

    }

    if (passwordctrl.text != null && passwordctrl.text.isNotEmpty) {
      requestBody["userpassword"] = passwordctrl.text;
      password = passwordctrl.text;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/user/update/${widget.id}",
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

      uploadImage();
      UpdateLastEditedDateTime(widget.id);

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder:
              (context) => AdminHomeNavi(username: username, userid: widget.id, tabIndexes: 4,)),
              (route) => false
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

  String imageUrl = "images/avatar01.jpg";
  late Uint8List? _images = Uint8List(0); // Default image URL
  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/inployed/image/getProfileImage/${widget.id}')
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



  Future<void> uploadImage() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");

    if (_image == null) {
      return;
    }

    final uri = Uri.parse('http://$server:8080/inployed/image/updateImage/${widget.id}'); // Replace with your API URL
    final request = http.MultipartRequest('PUT', uri);
    request.fields['userId'] = '${widget.id}';// Replace with the user ID
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Image is updated successfully',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Image failed to update successfully',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    fetchProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text("Edit your profile", style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, fontSize: 25,
        ),),
      ),
      body: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          height: double.infinity,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 130, height: 130, decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2, blurRadius: 10, color: Colors.black.withOpacity(0.1)
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: _image == null
                                ? DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(_images!)
                            )
                                : _image != null
                                ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(_image!)
                            )
                                : DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(imageUrl)
                            )
                        ),
                        ),
                        Positioned(
                            bottom: 0, right: 0,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: IconButton(onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text("Upload Image",style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold, fontSize: 25,
                                        ),),
                                        content: Text("Edit your image",style: GoogleFonts.poppins(
                                          fontSize: 18,
                                        ),),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              _getFromCamera();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              child: Text("Camera", style: GoogleFonts.poppins(
                                                fontSize: 15,
                                              ),),
                                            ),
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              _getFromGallery();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              child: Text("Gallery", style: GoogleFonts.poppins(
                                                fontSize: 15,
                                              ),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }, icon: const Icon(Icons.photo_camera)),
                                ),


                              ],
                            )


                        )
                      ],
                    ),

                  ],
                ),

                SizedBox(height: 25,),


                Row(
                  children: [
                    Text("Username",style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15,
                    ),),

                    SizedBox(width: 10,),

                    Expanded(
                      child: TextField(
                        // Hide text when _password is false
                        controller: usernamectrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            filled: true,
                            fillColor: Colors.white70,
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Set your new username",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "$username",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),
                        style: GoogleFonts.poppins(
                            fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Row(
                  children: [
                    Text("Email",style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15,
                    ),),

                    SizedBox(width: 48,),

                    Expanded(
                      child: TextField(
                        // Hide text when _password is false
                        controller: emailctrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            filled: true,
                            fillColor: Colors.white70,
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Set your new email",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "$email",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),
                        style: GoogleFonts.poppins(
                            fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Row(
                  children: [
                    Text("Position",style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15,
                    ),),

                    SizedBox(width: 28,),

                    Expanded(
                      child: TextField(
                        // Hide text when _password is false
                        controller: positionctrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            filled: true,
                            fillColor: Colors.white70,
                            prefixIcon: Icon(Icons.business_center),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Set your new position",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "$position",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),
                        style: GoogleFonts.poppins(
                            fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                Row(
                  children: [
                    Text("Password",style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15,
                    ),),

                    SizedBox(width: 15,),

                    Expanded(
                      child: TextField(
                        // Hide text when _password is false
                        controller: passwordctrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            filled: true,
                            fillColor: Colors.white70,
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Set your new password",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "$password",
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.black
                            )
                        ),
                        style: GoogleFonts.poppins(
                            fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50,),

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
                        updateAdminAccount();

                      },
                      child: Container(
                        width: 120,
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

                    SizedBox(width: 10,),

                    InkWell(
                      onTap: ()
                      {
                        /**
                         * Navigate to login() function
                         * for web service request
                         */
                        Navigator.pop(context);

                      },
                      child: Container(
                        width: 120,
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
                              "Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.black,
                                  fontWeight: FontWeight.w600
                              )),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          )
      ),
    );
  }
}
