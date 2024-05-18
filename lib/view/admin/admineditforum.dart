import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/OneSignalController.dart';
import '../../controller/request_controller.dart';
import '../../models/forum.dart';

class EditForum extends StatefulWidget {
  final int? forumid;
  const EditForum({required this.forumid});

  @override
  State<EditForum> createState() => _EditForumState();
}

class _EditForumState extends State<EditForum> {

  TextEditingController forumNameTxtCtrl = TextEditingController();
  TextEditingController forumDescTxtCtrl = TextEditingController();

  Forum? _forum;

  Future<void> getCurrentForumInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "/inployed/forum/${widget.forumid}",
      server: "http://$server:8080",
    );

    await req.get();

    if (req.status() == 200) {
      final Map<String, dynamic> responseData = req.result();
      final forum = Forum.fromJson(responseData);
      setState(() {
        _forum = forum;
        forumNameTxtCtrl.text = forum.forumName;
        forumDescTxtCtrl.text = forum.forumDesc;

      });
    } else {
      throw Exception('Failed to fetch forum');
    }
  }

  Future<void> updateForum() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (forumNameTxtCtrl.text != null && forumNameTxtCtrl.text.isNotEmpty) {
      requestBody["forumname"] = forumNameTxtCtrl.text;
    }

    if (forumDescTxtCtrl.text != null && forumDescTxtCtrl.text.isNotEmpty) {
      requestBody["forumDesc"] = forumDescTxtCtrl.text;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/forum/update/Forum/${widget.forumid}",
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

      Navigator.pop(context);

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

  @override
  void initState(){
    //TODO: implement initState
    super.initState();
    getCurrentForumInfo();
    print("User: ${widget.forumid}");
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
        title: Text("Edit your forum", style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.white,
            fontSize: 26
        ),),
      ),
      body: Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFBC2EB),
                    Color(0xFFA6C1EE),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white54,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Update Forum",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),

                          Text(
                            "Forum Name",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: forumNameTxtCtrl,
                            decoration: InputDecoration(
                              //errorText: 'Please enter a valid value',
                                prefixIcon: Icon(Icons.title),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Current :${_forum?.forumName}",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Current :${_forum?.forumName}",
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
                            "Forum Description",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SingleChildScrollView(
                            child: TextField(
                              controller: forumDescTxtCtrl,
                              keyboardType: TextInputType.multiline,
                              maxLines: 10,
                              autocorrect: true,
                              autofocus: true,
                              decoration: InputDecoration(
                                //errorText: 'Please enter a valid value',
                                  prefixIcon: Icon(Icons.description),
                                  filled: true,
                                  fillColor: Colors.white70,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Current :${_forum?.forumDesc}",
                                  hintStyle: GoogleFonts.poppins(
                                      fontSize: 15, fontWeight: FontWeight.bold
                                  ),
                                  labelText: "Current :${_forum?.forumDesc}",
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                  )
                              ),
                              style: GoogleFonts.poppins(
                                  fontSize: 15
                              ),

                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              updateForum();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(249, 151, 119, 1),
                                    Color.fromRGBO(98, 58, 162, 1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1f1f1f),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Update",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
