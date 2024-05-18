import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:bitu3923_group05/view/admin/admineditforum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../../models/forum.dart';
import '../../models/job_apply.dart';
import '../user/forum_post.dart';
import '../user/forum_view.dart';

class ViewForum extends StatefulWidget {
  final int? forumId;

  const ViewForum({required this.forumId});

  @override
  State<ViewForum> createState() => _ViewForumState();
}

class _ViewForumState extends State<ViewForum> {
  late String admin;


  @override
  void initState() {
    super.initState();
    getForumByID();
  }

  Forum? forums;

  Future<void> getForumByID() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "/inployed/forum/${widget.forumId}",
      server: "http://$server:8080",
    );

    await req.get();

    if (req.status() == 200) {
      final forum = Forum.fromJson(req.result());
      setState(() {
        forums = forum;
        print(forums);
      });
    } else {
      throw Exception('Failed to fetch post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(249, 151, 119, 1),
                Color.fromRGBO(98, 58, 162, 1),
              ],
            ),
          ),
        ),
        title: Text(
          "Forum Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 30,
        ),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(249, 151, 119, 1),
              Color.fromRGBO(98, 58, 162, 1),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            Future.delayed(Duration(seconds: 10));
            getForumByID();
          },
          color: Colors.black,
          backgroundColor: Colors.yellow,
          child:Expanded(
            child:SingleChildScrollView(
              child:Container(
               child: Column(
                  children:[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Created on: ', style: GoogleFonts.poppins(
                          fontSize: 12,
                        ), textAlign: TextAlign.justify,
                        ),

                        SizedBox(width: 5,),
                        Text('${forums?.forumDate}', style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.bold,
                        ), textAlign: TextAlign.justify,
                        ),

                        SizedBox(width: 5,),
                        Text('${forums?.forumTime}', style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.bold,
                        ), textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),

                    Text("${forums?.forumName}", style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ), textAlign: TextAlign.justify,
                    ),

                    SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Created by: ', style: GoogleFonts.poppins(
                            fontSize: 15
                        ), textAlign: TextAlign.justify,
                        ),

                        Text('${forums?.admin?.username}', style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold,
                        ), textAlign: TextAlign.justify,
                        ),

                      ],
                    ),

                    Divider(
                      thickness: 2.0,
                      color: Colors.black,
                    ),

                    SizedBox(height: 15,),

                    Text('${forums?.forumDesc}', style: GoogleFonts.poppins(
                        fontSize: 18
                    ), textAlign: TextAlign.justify,
                    ),

                    SizedBox(height: 15,),

                    Row(
                      children: [
                        Text('Created on: ${forums?.forumDate}', style: GoogleFonts.poppins(
                            fontSize: 12
                        ), textAlign: TextAlign.justify,
                        ),

                        SizedBox(width: 5,),

                        Text('${forums?.forumTime}', style: GoogleFonts.poppins(
                            fontSize: 12
                        ), textAlign: TextAlign.justify,
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                  ],
              ),
          ),
          )
        ),
      ),
      ),
    );
  }
}
