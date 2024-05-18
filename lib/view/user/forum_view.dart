import 'package:animations/animations.dart';
import 'package:bitu3923_group05/models/forum_post.dart';
import 'package:bitu3923_group05/models/user.dart';
import 'package:bitu3923_group05/view/user/home_navi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../controller/request_controller.dart';
import '../../models/company.dart';
import '../../models/forum.dart';
import 'forum_post.dart';

/**
 * Forum Basic Page
 */
class UserForum extends StatefulWidget {
  const UserForum({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<UserForum> createState() => _UserForumState();
}

class _UserForumState extends State<UserForum> {

  late List<Forum> forums = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> getForum() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/forum",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        forums = data.map((json) => Forum.fromJson(json)).toList();
      });

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
    } else {
      throw Exception('Failed to fetch forum');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getForum();
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
        title: Text("Forum", style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.white,
            fontSize: 30
        ),),
      ),
      body:
      forums != null
      ? Container(
          padding: EdgeInsets.only(
            top: 10, left: 10, right: 10, bottom: 30
          ),
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
          child: RefreshIndicator(
            onRefresh: ()async{
              Future.delayed(Duration(seconds: 10));
              getForum();
            },
            color: Colors.black,
            backgroundColor: Colors.yellow,
            child: ListView.builder(
              itemCount: forums.length,
              controller: _scrollController,
              reverse: true,
              itemBuilder: (context, index){
                final forum = forums[index];
                return OpenContainer(
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                      )
                  ),
                    closedBuilder: (context, _) =>  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              //Color(0xFFFBC2EB), // #fbc2eb
                              //Color(0xFFA6C1EE), #a6c1ee
                              Color.fromRGBO(249, 151, 119, 1),
                              Color.fromRGBO(98, 58, 162, 1),
                            ],
                          ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5),
                            ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [ Color(0xFFFBC2EB), Color(0xFFA6C1EE),],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                  )
                              ),
                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(forum.forumName, style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.black,
                                    ), textAlign: TextAlign.justify,
                                    ),
                                
                                    Divider(
                                      color: Colors.black,
                                      thickness: 2.0,
                                    ),
                                
                                    Text(forum.forumDesc, style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.black,
                                    ), maxLines: 3, textAlign: TextAlign.justify,
                                      overflow: TextOverflow.ellipsis,),
                                
                                    SizedBox(height: 5),
                                
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(forum.forumDate, style: GoogleFonts.poppins(
                                          fontSize: 18, color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ), maxLines: 3, overflow: TextOverflow.ellipsis,),
                                
                                        Spacer(),
                                
                                        Text(forum.forumTime, style: GoogleFonts.poppins(
                                          fontSize: 18, color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ), maxLines: 3, overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(onPressed: (){
                                    print(widget.id);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context)=>UserForumPost(id: forum.forumId, user: widget.id,)));
                                  },
                                    child: Text("Make Post", style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    ),),
                                  ),

                                  TextButton(onPressed: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context)=>ForumPostView(id: forum.forumId, user: widget.id,)));
                                  },
                                    child: Text("View Post", style: GoogleFonts.poppins(
                                        fontSize: 20, color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    ),),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ),
                    openBuilder: (context, _) => Scaffold(
                      appBar: AppBar(
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFBC2EB), // #fbc2eb
                                  Color(0xFFA6C1EE), // #a6c1ee
                                ],
                              )
                          ),
                        ),
                        title: Text("Forum Details", style: GoogleFonts.poppins(
                            fontSize: 23, color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      body: SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFBC2EB), // #fbc2eb
                                    Color(0xFFA6C1EE), // #a6c1ee
                                  ],
                                )
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Created on:', style: GoogleFonts.poppins(
                                          fontSize: 12,
                                      ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(width: 5,),
                                      Text('${forum.forumDate}', style: GoogleFonts.poppins(
                                        fontSize: 12, fontWeight: FontWeight.bold,
                                      ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(width: 5,),
                                      Text('${forum.forumTime}', style: GoogleFonts.poppins(
                                          fontSize: 12, fontWeight: FontWeight.bold,
                                      ), textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),

                                  Text("${forum.forumName}", style: GoogleFonts.poppins(
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

                                      Text('${forum.admin?.username}', style: GoogleFonts.poppins(
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

                                  Text('${forum.forumDesc}', style: GoogleFonts.poppins(
                                      fontSize: 18
                                  ), textAlign: TextAlign.justify,
                                  ),

                                  SizedBox(height: 15,),

                                  Row(
                                    children: [
                                      Text('Created on: ${forum.forumDate}', style: GoogleFonts.poppins(
                                          fontSize: 12
                                      ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(width: 5,),

                                      Text('${forum.forumTime}', style: GoogleFonts.poppins(
                                          fontSize: 12
                                      ), textAlign: TextAlign.justify,
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                    )
                );
              },
            ),
          )
      ): Center(child: CircularProgressIndicator(),),
    );
  }
}



/**
 * Make Post on Forum
 */
class UserForumPost extends StatefulWidget {
  const UserForumPost({Key? key, required this.id, required this.user}) : super(key: key);
  final int id, user;

  @override
  State<UserForumPost> createState() => _UserForumPostState();
}

class _UserForumPostState extends State<UserForumPost> {

  Forum? _forum;
  Future<void> getForumByID() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/forum/${widget.id}",
        server: "http://$server:8080");

    await req.get();
    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      // Parse the JSON response into a `User` object.
      final Map<String, dynamic> responseData = req.result();
      final forum = Forum.fromJson(responseData);

      setState(() {
        _forum = forum;
      });
    } else {
      throw Exception('Failed to fetch post');
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

  ForumPost post = ForumPost(0,
     User(0, "", "", "", "", "Job Seeker", "",
      Company(0, "", "", "", "", "", "", ""), ""),
      Forum(0, "", "", "", "",  User(0, "", "", "", "", "Job Seeker", "",
          Company(0, "", "", "", "", "", "", ""),"")),
      "", "", "", "",
  );

  /**
   * add forum post request
   */
  Future<void> addPost() async{
    print(widget.user);

    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String postDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String postTime = _formatTimeIn12Hour(currentDay);

    if(widget.user == null){
      Fluttertoast.showToast(
        msg: 'User ID is blank',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
    else {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController
        (path: "/inployed/post/addPost",
          server: "http://$server:8080");

      req.setBody(
          {
            'postId': 0,
            'userId': {
              'userId': widget.user
            },
            "forumId": {
              "forumId": _forum?.forumId
            },
            "postTitle": _postTitleCtrl.text,
            "postDesc": _postDescriptionCtrl.text,
            "postDate": postDate,
            "postTime": postTime,
          }
      );

      await req.post();


      print(req.result());

      if(req.status() == 200){
        // Handle the user data as needed
        // For example, you can navigate to the home screen or save user details to the app state.
        Fluttertoast.showToast(
          msg: 'You have make post successfully!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );

        Navigator.pop(context);
      }
      else {
        Fluttertoast.showToast(
          msg: 'Fail to make post',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getForumByID();
  }

  TextEditingController _postTitleCtrl = TextEditingController();
  TextEditingController _postDescriptionCtrl = TextEditingController();

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
        title: Text("Make Forum Post", style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.white,
            fontSize: 25
        ),),
      ),
      body: Container(
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
            children: [
              Card(
                elevation: 10,
                child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey,
                          offset: Offset(2, 10),
                          blurRadius: 26,
                          
                        ),
                      ],
                    ),
                    child: Text('${_forum?.forumName}', style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ), textAlign: TextAlign.justify,
                    ),
                ),
              ),
          
              SizedBox(height: 25,),
          
              Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey,
                        offset: Offset(2, 10),
                        blurRadius: 26,
          
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Forum Post", style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                      ),),
          
                      SizedBox(height: 25,),
          
                      TextField(
                        controller: _postTitleCtrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            prefixIcon: Icon(Icons.title),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
          
                            ),
                            hintText: "Enter title for your post",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "Title",
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
                        keyboardType: TextInputType.multiline,
                        maxLines: 10,
                        controller: _postDescriptionCtrl,
                        decoration: InputDecoration(
                          //errorText: 'Please enter a valid value',
                            prefixIcon: Icon(Icons.description),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintText: "Enter description for your post",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "Description",
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 15,
                            )
                        ),
                        style: GoogleFonts.poppins(
                            fontSize: 15
                        ),
          
                      ),

                      SizedBox(height: 50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: ()
                            {
                              /**
                               * Navigate to login() function
                               * for web service request
                               */
                              addPost();

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
                                        fontSize: 22, color: Colors.white,
                                        fontWeight: FontWeight.w600
                                    )),
                              ),
                            ),
                          ),

                          SizedBox(width: 10),

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
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE5D2F8), Color(0xFF908E8E)],
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
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                        fontSize: 22, color: Colors.black,
                                        fontWeight: FontWeight.w600
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),
                    ],
                  )

              ),
            ],
          ),
        ),
      ),
    );
  }
}
