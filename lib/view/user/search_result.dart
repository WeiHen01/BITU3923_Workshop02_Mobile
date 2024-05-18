import 'dart:ui';
import 'package:bitu3923_group05/view/user/JobDescriptionView.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';

class JobSearchResult extends StatefulWidget {
  final String searchQuery;
  final String username;
  final int user;
  const JobSearchResult({required this.searchQuery, required this.user, required this.username});

  @override
  State<JobSearchResult> createState() => _JobSearchResultState();
}


class _JobSearchResultState extends State<JobSearchResult> {

  late List<Advertisement> jobQuery = [];
  Future<void> searchJobQuery() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/job/search"
        "/${widget.searchQuery}",
        server: "http://$server:8080");

    await req.get();

    try{
      if (req.status() == 200) {
        final List<dynamic> responseData = req.result();
        setState(() {
          jobQuery = responseData.map((json) => Advertisement.fromJson(json)).toList();
          print("Number of posts: ${jobQuery.length}");
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
    searchJobQuery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Searching results",
          style: GoogleFonts.poppins(
            fontSize: 25, fontWeight: FontWeight.bold
          ),
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
          padding: EdgeInsets.only(
              left: 10, top: 5, right: 10
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBC2EB), // #fbc2eb
                  Color(0xFFA6C1EE), // #a6c1ee
                ],
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Searching query: ", style: GoogleFonts.poppins(
                      fontSize: 15,
                  ),),

                  Text("${widget.searchQuery}", style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.bold
                  ),),
                ],
              ),

              Row(
                children: [
                  Text("Results obtained: " , style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),),
                  Text("${(jobQuery != null ? jobQuery.length : 0)}", style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.bold
                  ),),
                ],
              ),

              SizedBox(height: 10),

              jobQuery != null
              ? Expanded(
                child: ListView.builder(
                    itemCount: jobQuery.length,
                    itemBuilder: (BuildContext builder, int index){
                      final jobsSearch = jobQuery[index];
                      return Card(
                        elevation: 10,
                        child: OpenContainer(
                            closedBuilder: (context, _) => Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Image.asset('images/logo.png',
                                    width: 100, height: 50,
                                  ),

                                  SizedBox(width: 20),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Job Result ${index+1} ", style: GoogleFonts.poppins(
                                          fontSize: 15,
                                        ),),
                                    
                                        Text("${jobsSearch.jobPosition}", style: GoogleFonts.poppins(
                                            fontSize: 15, fontWeight: FontWeight.bold
                                        ),),
                                    
                                        Text("${jobsSearch.company.companyName}", style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ), maxLines: 5, overflow: TextOverflow.ellipsis,),
                                    
                                    
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(Icons.navigate_next, size: 15, color: Colors.indigo),
                                            Text("View More", style: GoogleFonts.poppins(
                                              fontSize: 12, color: Colors.indigo,
                                              fontWeight: FontWeight.w700
                                            ),),
                                    
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            openBuilder: (context, _) => JobDescView(advertisement: jobsSearch, user: widget.user, username: widget.username,)
                        ),
                      );
                    }
                ),
              )
              : Center(child: CircularProgressIndicator(),),
            ],
          )
      ),
    );
  }
}


