import 'package:animations/animations.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:bitu3923_group05/models/forum.dart';
import 'package:bitu3923_group05/view/admin/adminforumview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';
import '../../models/forum.dart';
import 'adminviewadminforum.dart';

class AdminForum extends StatefulWidget {
  const AdminForum({Key? key, required this.id}) : super(key: key);
  final int? id;


  @override
  State<AdminForum> createState() => _AdminForumState();
}

class _AdminForumState extends State<AdminForum> {
  // Declare attributes
  TextEditingController forumnameTextCtrl = TextEditingController();
  TextEditingController forumdescTextCtrl = TextEditingController();
  User? user;


  String _getMonthName(int month) {
    // Convert the numeric month to its corresponding name
    List<String> monthNames = [
      "", // Month names start from index 1
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December",
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

  Future<void> addNewForum() async {
    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String postDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String postTime = _formatTimeIn12Hour(currentDay);

    if (forumnameTextCtrl.text == "" || forumdescTextCtrl.text == "") {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "EMPTY INPUT!",
          text: "You must input all the text fields!",
        ),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      WebRequestController req = WebRequestController(
        path: "/inployed/forum/create",
        server: "http://$server:8080",
      );

      req.setBody({
        "forumname": forumnameTextCtrl.text,
        "forumDesc": forumdescTextCtrl.text,
        "forumDate": postDate,
        "forumTime": postTime,
        "adminID": {
          "userId": widget.id,
        },
      });

      await req.post();

      print(req.result());

      if (req.result() != null) {
        Fluttertoast.showToast(
          msg: 'Successful create new forum!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG,
          fontSize: 16.0,
        );

        Future.delayed(Duration(seconds: 3));
        forumnameTextCtrl.clear();
        forumdescTextCtrl.clear();
      } else {
        Fluttertoast.showToast(
          msg: 'Create Forum failed!',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      }
    }
  }


  late List<Forum> viewforum = [];
  final ScrollController _scrollController02 = ScrollController();
  Future<void> getAllForum() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/forum",
        server: "http://$server:8080");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        viewforum = data.map((json) => Forum.fromJson(json)).toList();
      });

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController02.animateTo(
            _scrollController02.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
    } else {
      throw Exception('Failed to fetch job');
    }
  }

  late List<Forum> viewadminforum = [];
  final ScrollController _scrollController03 = ScrollController();

  Future<void> getAdminForum() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/forum/admin/ctrlForumAdmin/${widget.id}",
        server: "http://$server:8080");

    // Pass the adminId as a query parameter

    await req.get();
    print(req.result());
    if (req.status() == 200) {

      List<dynamic> data = req.result();
      setState(() {
        viewadminforum = data.map((json) => Forum.fromJson(json)).toList();
      });

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController03.animateTo(
            _scrollController03.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
    } else {
      throw Exception('Failed to fetch job');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllForum();
    print(widget.id);
    getAdminForum();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(
                  text: "List Forum"
              ),
              Tab(
                  text: "Own Forum"
              ),
              Tab(
                  text: "Create Forum"
              ),
            ],
            labelStyle: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.black,
            indicator: BoxDecoration(
              color: Color(0xFFA6C1EE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          title: Text(
            "FORUM",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 26,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            /**
             * Tab 1 - View All Forum
             */
            viewforum != null
              ? Container(
              padding: EdgeInsets.only(
                left:10, right: 10, bottom:100, top: 5
              ),
              decoration: BoxDecoration(
                  color: Color(0xFFA6C1EE),
                ),
                  child: RefreshIndicator(
                  onRefresh: ()async{
                    Future.delayed(Duration(seconds: 10));
                    getAllForum();
                  },
                  color: Colors.black,
                  backgroundColor: Colors.yellow,
                  child: Builder(
                      builder: (context) {
                        SchedulerBinding.instance?.addPostFrameCallback((_) {
                          _scrollController02.animateTo(
                            _scrollController02.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 1),
                            curve: Curves.fastOutSlowIn,
                          );
                        });
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Forum: ${viewforum.length}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, fontSize: 20
                                ),
                                textAlign: TextAlign.left,
                              ),

                              Divider(
                                thickness: 2.0,
                              ),

                              Expanded(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    controller: _scrollController02,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: viewforum.length,
                                    itemBuilder: (BuildContext context, int index){
                                      final forums = viewforum[index];
                                      return OpenContainer(
                                        closedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        closedColor: Color(0xFFA6C1EE),
                                        closedBuilder: (context, _) => Card(
                                          elevation: 3,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${forums.forumName}',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 18, color: Colors.black,
                                                            fontWeight: FontWeight.bold
                                                        ), textAlign: TextAlign.justify,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Divider(
                                                  thickness: 2.0,
                                                ),

                                                Text(
                                                  forums.forumDesc,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16, color: Colors.black,
                                                  ),
                                                  maxLines: 5, // Set the maximum number of lines
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.justify,
                                                ),

                                                SizedBox(height: 10),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${forums.forumDate} ${forums.forumTime}",
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12, color: Colors.black,
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                      maxLines: 5, // Set the maximum number of lines
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.justify,
                                                    ),

                                                    Spacer(),

                                                    Icon(Icons.navigate_next, color: Colors.indigo,),
                                                    Text(
                                                      "View More",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16, color: Colors.indigo,
                                                      ),
                                                      maxLines: 5, // Set the maximum number of lines
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ],
                                                )

                                              ],
                                            ),
                                          ),
                                        ),
                                        openBuilder: (context, _) => ViewForum(forumId: forums?.forumId),
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                )
            ):
            Center(
              child: CircularProgressIndicator(),
            ),
            /**
             * Tab 2 - View and Update Forum
             */
            viewadminforum != null
                ? Container(
                padding: EdgeInsets.only(
                    left: 10, right: 10, bottom: 100, top: 5
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFA6C1EE),
                ),
                  child: RefreshIndicator(
                  onRefresh: ()async{
                    Future.delayed(Duration(seconds: 10));
                    getAdminForum();
                  },
                  color: Colors.black,
                  backgroundColor: Colors.yellow,
                  child: Builder(
                      builder: (context) {
                        SchedulerBinding.instance?.addPostFrameCallback((_) {
                          _scrollController03.animateTo(
                            _scrollController03.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 1),
                            curve: Curves.fastOutSlowIn,
                          );
                        });
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Forum created: ${viewforum.length}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, fontSize: 20
                                ),
                                textAlign: TextAlign.left,
                              ),

                              Divider(
                                thickness: 2.0,
                              ),

                              Expanded(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    controller: _scrollController02,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: viewadminforum.length,
                                    itemBuilder: (BuildContext context, int index){
                                      final forums = viewadminforum[index];
                                      return OpenContainer(
                                        closedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        closedColor: Color(0xFFA6C1EE),
                                        closedBuilder: (context, _) => Card(
                                          elevation: 3,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${forums.forumName}',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 18, color: Colors.black,
                                                            fontWeight: FontWeight.bold
                                                        ), textAlign: TextAlign.justify,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Divider(
                                                  thickness: 2.0,
                                                ),

                                                Text(
                                                  forums.forumDesc,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16, color: Colors.black,
                                                  ),
                                                  maxLines: 5, // Set the maximum number of lines
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.justify,
                                                ),

                                                SizedBox(height: 10),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${forums.forumDate} ${forums.forumTime}",
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12, color: Colors.black,
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                      maxLines: 5, // Set the maximum number of lines
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.justify,
                                                    ),

                                                    Spacer(),

                                                    Icon(Icons.navigate_next, color: Colors.indigo,),
                                                    Text(
                                                      "View More",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16, color: Colors.indigo,
                                                      ),
                                                      maxLines: 5, // Set the maximum number of lines
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ],
                                                )

                                              ],
                                            ),
                                          ),
                                        ),
                                        openBuilder: (context, _) => ViewAdminForum(forumId: forums?.forumId),
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                )
            )
                : Center(
                  child: CircularProgressIndicator(),
            ),

            /**
             * Tab 3 - Create Forum
             */
            Container(
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
                            "New Forum",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Divider(
                            thickness: 2,

                          ),

                          Text(
                            "Forum Name",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: forumnameTextCtrl,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.forum_rounded),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "New Forum Name",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              labelText: "Enter new forum name",
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 15,
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 15),
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
                              controller: forumdescTextCtrl,
                              keyboardType: TextInputType.multiline,
                              maxLines: 10,
                              autocorrect: true,
                              autofocus: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.description),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "New Forum Description",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelText: "Enter new forum description",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              addNewForum();
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
                                  "Save",
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
          ],
        ),
      ),
    );
  }
}
