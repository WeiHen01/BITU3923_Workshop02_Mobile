import 'package:bitu3923_group05/view/company/JobDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';
import '../user/JobDescriptionView.dart';
import 'own_JobPost.dart';


class CompanyHome extends StatefulWidget {
  const CompanyHome({this.company, this.username});
  final int? company;
  final String? username;

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {

  late List<Advertisement> advertisements = [];
  final ScrollController _scrollController = ScrollController();
  Future<void> getAdvertisement() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        advertisements = data.map((json) => Advertisement.fromJson(json)).toList();
      });

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });


    } else {
      throw Exception('Failed to fetch job');
    }
  }


  late List<Advertisement> ownAds = [];
  final ScrollController _scrollController02 = ScrollController();
  Future<void> getCompanyOwnAdvertisement() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/company/ownPost/${widget.company}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        ownAds = data.map((json) => Advertisement.fromJson(json)).toList();
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



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.company);
    getAdvertisement();
    getCompanyOwnAdvertisement();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              //disable leading on appBar
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(249, 151, 119, 1),
                        Color.fromRGBO(98, 58, 162, 1),// #a6c1ee
                      ],
                    )
                ),
              ),

              bottom:  TabBar(
                dividerColor: Colors.transparent,
                tabs: <Widget>[
                  Tab(
                    text: "Dashboard",
                  ),
                  Tab(
                      text: "Own Post"
                  ),
                ],
                labelStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                ),
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.black,
                indicator: BoxDecoration(
                    color: Color(0xFFA6C1EE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                ),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              title: Image.asset('images/logo_company.png',
                width: 100, height: 50,
              ),
            ),
            body: TabBarView(
                children: [
                  /**
                   * Tab 1 - Dashboard
                   */
                  advertisements != null
                      ? Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFA6C1EE),
                    ),
                    child: RefreshIndicator(
                      onRefresh: ()async{
                        Future.delayed(Duration(seconds: 10));
                        getAdvertisement();
                      },
                      color: Colors.black,
                      backgroundColor: Colors.yellow,
                      child: Builder(
                        builder: (context) {
                          SchedulerBinding.instance?.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 1),
                                curve: Curves.fastOutSlowIn);
                          });
                          getAdvertisement();
                          getCompanyOwnAdvertisement();


                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: advertisements.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final ad = advertisements[index];
                              return OpenContainer(
                                closedColor: Color(0xFFA6C1EE),
                                transitionType: ContainerTransitionType.fade,
                                transitionDuration: Duration(seconds: 1),
                                closedBuilder: (context, _) => Card(
                                  elevation: 4,
                                  margin: EdgeInsets.only(
                                      left: 10, top: 10, bottom: 10, right: 10
                                  ),
                                  child: Container(
                                      height: 300,
                                      padding: EdgeInsets.all(15),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueGrey,
                                            offset: Offset(2, 5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white54,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      ad.company.companyName,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 18, color: Colors.black,
                                                          fontWeight: FontWeight.w800
                                                      )
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  '${ad.AdsDate}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15, color: Colors.black,
                                                      fontWeight: FontWeight.w600
                                                  ), textAlign: TextAlign.justify,
                                                ),

                                                Spacer(),

                                                Text(
                                                  '${ad.AdsTime}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15, color: Colors.black,
                                                      fontWeight: FontWeight.w600
                                                  ), textAlign: TextAlign.justify,
                                                ),
                                              ],
                                            ),

                                            Divider(
                                              thickness: 2.0,
                                            ),

                                            Text(
                                                ad.jobPosition,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18, fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                )
                                            ),

                                            Text(
                                                ad.jobDescription,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 15, color: Colors.black,
                                                ), maxLines: 2, overflow: TextOverflow.ellipsis,
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Icon(Icons.navigate_next_sharp, color: Colors.indigo,),

                                                SizedBox(width: 2),

                                                Text(
                                                  "View More",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15, color: Colors.indigo,
                                                    fontWeight: FontWeight.w700
                                                  ), maxLines: 2, overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),

                                            Spacer(),

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
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context)=>JobDetails(advertisement: ad)
                                                        )
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 155,
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
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.description, color: Colors.black,),
                                                          SizedBox(width: 5,),
                                                          Text(
                                                              "Description",
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 15, color: Colors.black,
                                                                  fontWeight: FontWeight.w600
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ),
                                openBuilder: (context, _) => JobDetails(advertisement: ad),
                              );
                            },
                          );
                        }
                      ),
                    ),
                  )
                   : Center(child: CircularProgressIndicator(),),

                  /**
                   * Tab 2 - Application
                   */
                  ownAds != null
                      ? Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 100
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFA6C1EE),
                      ),
                      child: RefreshIndicator(
                        onRefresh: ()async{
                          Future.delayed(Duration(seconds: 10));
                          getCompanyOwnAdvertisement();
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
                              return ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  controller: _scrollController02,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: ownAds.length,
                                  itemBuilder: (BuildContext context, int index){
                                    final companyAds = ownAds[index];
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
                                                        '${companyAds.jobPosition}',
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
                                                  companyAds.jobDescription,
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
                                                      "${companyAds.AdsDate} ${companyAds.AdsTime}",
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
                                        openBuilder: (context, _) => OwnJobPost(ownPostId: companyAds.AdsId),
                                    );
                                  }
                              );
                            }
                        ),
                      )
                  )
                      : Center(
                    child: CircularProgressIndicator(),
                  ),


                ]
            )
        )
    );
  }
}
