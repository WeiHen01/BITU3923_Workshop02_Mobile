import 'dart:convert';

import 'package:bitu3923_group05/view/user/forum_view.dart';
import 'package:bitu3923_group05/view/user/search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/request_controller.dart';
import '../../models/user.dart';
import 'account.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

/**
 * This is the home navigation bar
 * where user can swipe to other pages
 * based on items on navigation bar
 */


class HomeNavi extends StatefulWidget {

  const HomeNavi({Key? key, required this.username, required this.id, required this.tabIndexes}) : super(key: key);
  final String username;
  final int id;
  final int tabIndexes;
  // const HomeNavi({required this.username});

  @override
  State<HomeNavi> createState() => _HomeNaviState();
}

class _HomeNaviState extends State<HomeNavi> {
  // set the default initial page
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }
  
  // controller for Page view
  late PageController pageController;

  @override
  void initState() {
    _tabIndex = widget.tabIndexes;
    super.initState();
    /**
     * WidgetsBinding.instance?.addPostFrameCallback
     * -------------------------------------------------------
     * This code schedules a callback function to be executed
     * after the end of the frame.
     * -------------------------------------------------------
     */
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Show SnackBar with a welcome message and the username
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome! ${widget.username}'),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 5),
        ),
      );
    });

    // to set the default page to be initiated based on tab index
    pageController = PageController(initialPage: _tabIndex);
    getUser();
  }

  User? _user;
  int userid = 0;
  Future<void> getUser() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/${widget.username}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final user = req.result();

      setState(() {
        _user = user;
        userid = user.userId;
      });
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      /**
       * Using CircleNavBar as packages
       * setting up in pubspec.yaml for dependencies
       *
       * This will enable to be used as navigation bar
       * which is more dynamic
       */
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          /**
           * icons on navigation bar
           * will be appeared when user is at current page
           */
          Icon(Icons.home, color: Colors.white, size: 35,),
          Icon(Icons.search, color: Colors.white, size: 35,),
          Icon(Icons.forum, color: Colors.white, size: 35,),
          Icon(Icons.person, color: Colors.white, size: 35,),
        ],

        /**
         * when the other pages are not active
         * the tab will be displayed as text
         */
        inactiveIcons:  [
          Text("Home", style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Search", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Forum", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Account", style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold
          ),),
        ],
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        // the rounded corner for the navigation bar
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.blueGrey,
        elevation: 10,
        /**
         * Background color of the bar
         */
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(249, 151, 119, 1),
            Color.fromRGBO(98, 58, 162, 1),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          /**
           * when the user switch the page
           * the index of current page will be assigned to the tabIndex
           */
          tabIndex = v;
        },
        children: [
          /**
           * Here will import the screens
           * based on the navigation bar in sequence
           *
           * The index of the screen starts from 0 in sequence
           * which is related to variable tabIndex later on
           */
          HomePage(username: widget.username, user: widget.id),
          Search(user: widget.id, username: widget.username,),
          UserForum(id: widget.id),
          Account(username: widget.username),

        ],
      ),
    );
  }
}
