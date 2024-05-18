import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:bitu3923_group05/view/user/forum_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/forum.dart';
import '../../models/forum_post.dart';
import '../../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/**
 * View a certain forum details with the post
 */
class ForumPostView extends StatefulWidget {
  const ForumPostView({Key? key, required this.id, required this.user}) : super(key: key);
  final int id, user;

  @override
  State<ForumPostView> createState() => _ForumPostViewState();
}

class _ForumPostViewState extends State<ForumPostView> {

  /**
   * Get specific forum information
   */
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
      final forum = Forum.fromJson(req.result());

      setState(() {
        _forum = forum;
      });
    } else {
      throw Exception('Failed to fetch post');
    }
  }

  /**
   * Retrieve the posts of a certain forum
   */
  late List<ForumPost> postList = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> fetchPost(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/post/list/$id",
        server: "http://$server:8080");

    await req.get();

    try{
      if (req.status() == 200) {
        final List<dynamic> responseData = req.result();
        setState(() {
          postList = responseData.map((json) => ForumPost.fromJson(json)).toList();
          print("Number of posts: ${postList.length}");
        });

        //display the last item once refresh the screen
        SchedulerBinding.instance?.addPostFrameCallback((_) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 1),
              curve: Curves.fastOutSlowIn);
        });
      } else {
        throw Exception('Failed to load job applications');
      }
    } catch (e) {
      print('Error fetching user resume: $e');
      // Handle the exception as needed, for example, show an error message to the user
    }
  }

  /**
   * Finding certain user information
   * - to validate if  the user type = company
   * - the posts will be populated based on company id
   *   -> which means let says User A and User B has the same company id
   *   -> the post color background will be the same regardless different user id
   */
  User? _user;
  int? companyId = 0;
  Future<void> getUser() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/allUserType/${widget.user}",
        server: "http://$server:8080");

    await req.get();

    if (req.status()== 200) {

      // Parse the JSON response into a `User` object.
      final user = User.fromJson(req.result());

      setState(() {
        _user = user;
        companyId = user.company?.companyId;
      });
    } else {
      throw Exception('Failed to fetch post');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Forum ID: ${widget.id}");
    print("User ID: ${widget.user}");
    getForumByID();
    getUser();
    fetchPost(widget.id);
    print(postList);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text('View forum', style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 25
        ),),
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
        child: Stack (
          children: [
            postList!=null
            ? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFBC2EB), // #fbc2eb
                        Color(0xFFA6C1EE), // #a6c1ee
                      ],
                    )
                ),
                margin: EdgeInsets.only(
                  top: 380, bottom: 30
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Posts', style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 25
                        ),),

                        Spacer(),

                        TextButton(onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)
                              => UserForumPost(id: widget.id, user: widget.user)
                            )
                          );
                        }, child: Row(
                          children: [
                            Icon(Icons.post_add_outlined,  color: Colors.black,
                              size: 25
                            ),
                            Text('Make Posts', style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 20
                            ),),
                          ],
                        ),)
                      ],
                    ),

                    Divider(
                      thickness: 2.0,
                      color: Colors.grey,
                    ),

                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: postList.length,
                          reverse: true,
                          itemBuilder: (context, index){
                            final post = postList[index];
                            return Card(
                              elevation: 8,
                              margin: (post.user.userId == widget.user)
                                  ? EdgeInsets.only(left: 60, bottom: 10)
                                  : EdgeInsets.only(right: 60, bottom: 10),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: (post.user.userId != widget.user)
                                      ? Colors.indigo
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        // if the post is user's own post
                                        Visibility(
                                          visible: (post.user.userId == widget.user)? true : false,
                                          child: Row(
                                            mainAxisAlignment: (post.user.userId == widget.user)? MainAxisAlignment.end : MainAxisAlignment.start ,
                                            children: [
                                              Row(
                                                mainAxisAlignment: (post.user.userId == widget.user)? MainAxisAlignment.start : MainAxisAlignment.end ,
                                                children: [
                                                  Text('${post.postDate}', style: GoogleFonts.poppins(
                                                      fontSize: 12
                                                  ),),

                                                  SizedBox(width: 10),

                                                  Text('${post.postTime}', style: GoogleFonts.poppins(
                                                      fontSize: 12
                                                  ),),
                                                ],
                                              ),

                                              Spacer(),

                                              Text('${post.user.username}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15
                                              ),),
                                            ],
                                          ),
                                        ),

                                        Visibility(
                                          visible: (post.user.userId != widget.user)? true : false,
                                          child: Row(
                                            mainAxisAlignment: (post.user.userId == widget.user)? MainAxisAlignment.end : MainAxisAlignment.start ,
                                            children: [
                                              Text('${post.user.username}', style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                color: (post.user.userId == widget.user)
                                                    ? Colors.black : Colors.white,
                                              ),),

                                              Spacer(),

                                              Row(
                                                mainAxisAlignment: (post.user.userId == widget.user)? MainAxisAlignment.start : MainAxisAlignment.end ,
                                                children: [
                                                  Text('${post.postDate}', style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                    color: (post.user.userId == widget.user)
                                                        ? Colors.black : Colors.white,
                                                  ),),

                                                  SizedBox(width: 10),

                                                  Text('${post.postTime}', style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                    color: (post.user.userId == widget.user)
                                                        ? Colors.black : Colors.white,
                                                  ),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment: (post.user.userId == widget.user)? MainAxisAlignment.end : MainAxisAlignment.start ,
                                          children: [

                                            Visibility(
                                              visible:  (post.user.userId != widget.user)? true : false,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.blueGrey, // Border color
                                                        width: 4.0,           // Border width
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset("images/avatar01.jpg",
                                                        height: 50, width: 50, fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: 10),
                                                ],
                                              ),
                                            ),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(post.postTitle, style: GoogleFonts.poppins(
                                                    color: (post.user.userId == widget.user)
                                                        ? Colors.black : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ), softWrap: true, textAlign: TextAlign.justify,
                                                  ),

                                                  Text(post.postDesc, style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    color: (post.user.userId == widget.user)
                                                        ? Colors.black : Colors.white,
                                                  ), softWrap: true, textAlign: TextAlign.justify,
                                                  ),
                                                ],
                                              ),
                                            ),



                                            Visibility(
                                              visible:  (post.user.userId == widget.user)? true : false,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.blueGrey, // Border color
                                                    width: 4.0,           // Border width
                                                  ),
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset("images/avatar01.jpg",
                                                    height: 50, width: 50, fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
            )
            : Center(child: CircularProgressIndicator(),),


            Positioned(
                child: Container(
                  child: Column(
                    children: [
                    OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      transitionDuration: Duration(seconds: 1),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    closedBuilder: (context, _)=>  Container(
                        padding: EdgeInsets.all(10),
                        height: 370,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey,
                              offset: Offset(2, 15),
                              blurRadius: 26,

                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${_forum?.forumName}", style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 25
                            ),),

                            SizedBox(height: 25,),

                            Text('${_forum?.forumDesc}', style: GoogleFonts.poppins(
                                fontSize: 20
                            ), maxLines: 5, overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.navigate_next, color: Color(0xFF025cf7),),
                                Text('View more', style: GoogleFonts.poppins(
                                    fontSize: 20, color: Color(0xFF025cf7),
                                    fontWeight: FontWeight.bold
                                ), textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ],
                        )
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
                                      Text('${_forum?.forumDate}', style: GoogleFonts.poppins(
                                        fontSize: 12, fontWeight: FontWeight.bold,
                                      ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(width: 5,),
                                      Text('${_forum?.forumTime}', style: GoogleFonts.poppins(
                                        fontSize: 12, fontWeight: FontWeight.bold,
                                      ), textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),

                                  Text("${_forum?.forumName}", style: GoogleFonts.poppins(
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

                                      Text('${_forum?.admin?.username}', style: GoogleFonts.poppins(
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

                                  Text('${_forum?.forumDesc}', style: GoogleFonts.poppins(
                                      fontSize: 18
                                  ), textAlign: TextAlign.justify,
                                  ),

                                  SizedBox(height: 15,),

                                  Row(
                                    children: [
                                      Text('Created on: ${_forum?.forumDate}', style: GoogleFonts.poppins(
                                          fontSize: 12
                                      ), textAlign: TextAlign.justify,
                                      ),

                                      SizedBox(width: 5,),

                                      Text('${_forum?.forumTime}', style: GoogleFonts.poppins(
                                          fontSize: 12
                                      ), textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        )
                    )
                  )
                  ]
                )
              )
            )
          ]
        ),
      )
    );
  }
}

