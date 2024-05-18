import 'dart:convert';

import 'package:bitu3923_group05/view/company/Advertisement%20View.dart';
import 'package:bitu3923_group05/view/company/Company%20Profile.dart';
import 'package:bitu3923_group05/view/company/CompanyHome.dart';
import 'package:bitu3923_group05/view/user/forum_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../models/user.dart';
import 'Job Request View.dart';

/**
 * This is the home navigation bar
 * where user can swipe to other pages
 * based on items on navigation bar
 */

class CompanyHomeNavi extends StatefulWidget {

  const CompanyHomeNavi({Key? key,
    required this.username, this.id, required this.tabIndexes,
    required this.company
  }): super(key: key);
  final String username;
  final int? id;
  final int company;
  final int tabIndexes;
  // const HomeNavi({required this.username});

  @override
  State<CompanyHomeNavi> createState() => _CompanyHomeNaviState();
}

class _CompanyHomeNaviState extends State<CompanyHomeNavi> {

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
    super.initState();

    _tabIndex = widget.tabIndexes;
    /**
     * WidgetsBinding.instance?.addPostFrameCallback
     * -------------------------------------------------------
     * This code schedules a callback function to be executed
     * after the end of the frame.
     * -------------------------------------------------------
     */

    // to set the default page to be initiated based on tab index
    pageController = PageController(initialPage: _tabIndex);
  }

  User? _user;
  int userid = 0;
  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/user/account/company/${widget.username}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final user = User.fromJson(req.result());

      setState(() {
        _user = user;
        userid = user.userId;
        print(userid);
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
          Icon(Icons.notifications, color: Colors.white, size: 35,),
          Icon(Icons.post_add_outlined, color: Colors.white, size: 35),
          Icon(Icons.forum, color: Colors.white, size: 35,),
          Icon(Icons.business, color: Colors.white, size: 35,),
         ],

        /**
         * when the other pages are not active
         * the tab will be displayed as text
         */
        inactiveIcons:  [
          Text("Home", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Requests", style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold
          ),),
          Text("Post", style: GoogleFonts.poppins(
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
          CompanyHome(company: widget.company, username: widget.username),
          CompanyViewRequest(company: widget.company),
          CompanyAds(company: widget.company, username: widget.username),
          UserForum(id: widget.id ?? 0),
          CompanyAccount(username: widget.username, userid: widget.id ?? 0, company: widget.company),
        ],
      ),
    );
  }
}
