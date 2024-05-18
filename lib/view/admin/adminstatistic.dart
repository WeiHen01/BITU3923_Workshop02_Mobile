import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart'; // Import your WebRequestController class
import '../../models/user.dart';

class AdminStats extends StatefulWidget {
  const AdminStats({Key? key}) : super(key: key);

  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> {
  late List<User> companyuser;
  late List<User> jobseekers;

  Future<void> getJobSeeker() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "/inployed/user/admin/ctrlUserJobSeeker/Job Seeker",
      server: "http://$server:8080",
    );

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        jobseekers = data.map((json) => User.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to fetch job');
    }
  }

  Future<void> getCompanyUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "/inployed/user/admin/ctrlUserCompany/Company",
      server: "http://$server:8080",
    );

    await req.get();

    if (req.status() == 200) {
      List<dynamic> data = req.result();
      setState(() {
        companyuser = data.map((json) => User.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to fetch job');
    }
  }

  Future<void> fetchData() async {
    // Fetch jobseekers and companyuser data
    await getJobSeeker();
    await getCompanyUser();
  }

  @override
  void initState() {
    super.initState();
    jobseekers = [];
    companyuser = [];
    fetchData();
  }

  //double JobSeekerPercent = 0.0;
  //double CompanyUserPercent = 0.0;


  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 20.0;
      final radius = isTouched
          ? 200.0
          : 150.0; // Adjusted radius for zoom effect
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: jobseekers.length.toDouble(),
            title: 'Job Seekers: ${(jobseekers.length /
                (jobseekers.length + companyuser.length)).toDouble() * 100}%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              color: Colors.black,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: companyuser.length.toDouble(),
            title: 'Company Users: ${(companyuser.length /
                (jobseekers.length + companyuser.length)).toDouble() * 100}%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              color: Colors.black,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  int touchedIndex = -1;


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
            title: Text(
              'Statistics',
              style: GoogleFonts.poppins(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: <Widget>[
                Tab(
                  text: "Users",
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
          ),
          body: TabBarView(
              children: [
                /**
                 * Tab 1 - User statistics
                 */
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFBC2EB), // #fbc2eb
                        Color(0xFFA6C1EE), // #a6c1ee
                      ],
                    ),
                  ),
                  child: jobseekers.isNotEmpty && companyuser.isNotEmpty
                      ? AspectRatio(
                    aspectRatio: 1.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Statistics',
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Divider(
                          thickness: 2.0,
                          color: Colors.black,

                        ),

                        Text(
                          'Pie chart of users statistics: ',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),

                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event,
                                      pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                sections: showingSections(),
                                borderData: FlBorderData(show: false),
                                centerSpaceRadius: 0,
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : CircularProgressIndicator(),
                ),
              ]
          )
      ),
    );
  }
}

