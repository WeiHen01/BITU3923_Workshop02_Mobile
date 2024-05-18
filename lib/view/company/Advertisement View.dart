import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import 'CompanyHome_Navi.dart';

class CompanyAds extends StatefulWidget {
  final int company;
  final String? username;
  const CompanyAds({required this.company, this.username});

  @override
  State<CompanyAds> createState() => _CompanyAdsState();
}

class _CompanyAdsState extends State<CompanyAds> {

  /**
   * The text field controllers
   */
  TextEditingController positionTxtCtrl = TextEditingController();
  TextEditingController descTxtCtrl = TextEditingController();
  TextEditingController jobtimeCtrl = TextEditingController();
  TextEditingController industryCtrl = TextEditingController();
  TextEditingController salaryMinCtrl = TextEditingController();
  TextEditingController salaryMaxCtrl = TextEditingController();


  String? dropdownRemote;
  String? dropdownJobCommit;
  String? dropdownDate;
  String? newSalary;

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


  Future<void> addNewJob() async {

    DateTime currentDay = DateTime.now();
    DateTime currentDate = DateTime(currentDay.year, currentDay.month, currentDay.day);
    // Format the date as a string
    String postDate = "${currentDate.day} ${_getMonthName(currentDate.month)} ${currentDate.year}";

    String postTime = _formatTimeIn12Hour(currentDay);

    if(salaryMinCtrl.text == null || salaryMinCtrl.text.isEmpty){
      ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.danger,
            title: "NO MINIMUM SALARY",
            text: "You must input the minimum salary!",
          )
      );
    }
    else {
      if(salaryMaxCtrl.text != null && salaryMaxCtrl.text.isNotEmpty){
        newSalary = "RM${salaryMinCtrl.text} - RM${salaryMaxCtrl.text}";
      }
      else {
        newSalary = salaryMinCtrl.text;
      }
    }

    /**
     * save the data registered to database
     */
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController
      (path: "/inployed/job/addJobPost",
        server: "http://$server:8080");

    req.setBody(
        {
          "jobPosition": positionTxtCtrl.text,
          "jobDescription": descTxtCtrl.text,
          "jobRemote": dropdownRemote,
          "jobDate": dropdownDate,
          "jobTime": jobtimeCtrl.text,
          "jobCommit": dropdownJobCommit,
          "salary": newSalary,
          "industry": industryCtrl.text,
          "availability": "Available",
          "companyId": {
            "companyID": widget.company,
          },
          "adsDate": postDate,
          "adsTime": postTime
        }
    );

    await req.post();

    print(req.result());

    if (req.result()!= null) {

      Fluttertoast.showToast(
        msg: 'Successful making new post!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );

      Future.delayed(Duration(seconds: 3));
      positionTxtCtrl.clear();
      descTxtCtrl.clear();
      jobtimeCtrl.clear();
      industryCtrl.clear();
      salaryMinCtrl.clear();
      salaryMaxCtrl.clear();
      setState(() {
        dropdownJobCommit = "Job Commit";
        dropdownDate = "Select working day";
        dropdownRemote = "Job Remote";
      });

      Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyHomeNavi(
                username: widget.username ?? '', id: widget.company, tabIndexes: 0, company: widget.company,
              ),
            ), (route) => false);

    }

    else
    {
      Fluttertoast.showToast(
        msg: 'Registration failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: Text("New Job Post", style: GoogleFonts.poppins(
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
                Color(0xFFFBC2EB), // #fbc2eb
                Color(0xFFA6C1EE), // #a6c1ee
              ],
            )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New Job", style: GoogleFonts.poppins(
                      color: Colors.black, fontSize: 28,
                      fontWeight: FontWeight.bold
                  )),
                ],
              ),
          
              SizedBox(height: 15),
          
              Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(
                    bottom: 80
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white54,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Job Position", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                      fontWeight: FontWeight.bold
                    )),
          
                    TextField(
                      controller: positionTxtCtrl,
                      decoration: InputDecoration(
                        //errorText: 'Please enter a valid value',
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "New Job Position",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold
                          ),
                          labelText: "Enter new job",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                          )
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15
                      ),
          
                    ),
          
                    SizedBox(height: 10),
          
                    Text("Job Description", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
          
                    SingleChildScrollView(
                      child: TextField(
                        controller: descTxtCtrl,
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
                            hintText: "New Job Description",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "Enter new job description",
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

                    Text("Job Remote", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),

                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (dynamic newValue){
                            setState(() {
                              print(newValue);
                              dropdownRemote = newValue;
                            });
                          },
                          hint: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Icon(Icons.settings_remote),

                                SizedBox(width: 5),

                                Text("Job remote", style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 18,
                                )),
                              ],
                            ),
                          ),

                          value: dropdownRemote,
                          items: <String>['WFH', 'In-office', 'WFH and In-office']
                              .map((category){
                            return DropdownMenuItem(
                              child: Container(
                                color: Colors.white70,
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  category, style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 18
                                ),
                                ),
                              ),
                              value: category,
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Text("Job Commitment", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),

                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (dynamic newValue){
                            setState(() {
                              print(newValue);
                              dropdownJobCommit = newValue;
                            });
                          },
                          hint: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Icon(Icons.commit),

                                SizedBox(width: 5),

                                Text("Job commit", style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 18,
                                )),
                              ],
                            ),
                          ),
                          value: dropdownJobCommit,
                          items: <String>['Part-time', 'Full-time'].map((category){
                            return DropdownMenuItem(
                              child: Container(
                                color: Colors.white70,
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  category, style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 18,
                                ),
                                ),
                              ),
                              value: category,
                            );
                          }).toList(),
                        ),
                      ),
                    ),

          

          
                    SizedBox(height: 10),
                    Text("Working Time", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
          
                    TextField(
                      controller: jobtimeCtrl,
                      decoration: InputDecoration(
                        //errorText: 'Please enter a valid value',
                          prefixIcon: Icon(Icons.timelapse),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "New Working Time",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold
                          ),
                          labelText: "Enter new working time",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                          )
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15
                      ),
          
                    ),
          
                    SizedBox(height: 10),
                    Text("Working Day", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
          
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          onChanged: (dynamic newValue){
                            setState(() {
                              print(newValue);
                              dropdownDate = newValue;
                            });
                          },
                          value: dropdownDate,
                          hint: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Icon(Icons.date_range),

                                SizedBox(width: 5),

                                Text("Select working day", style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 18,
                                )),
                              ],
                            ),
                          ),
                          items: <String>['Weekdays only', 'Weekends only', 'Everyday'].map((category){
                            return DropdownMenuItem(
                              child: Container(
                                color: Colors.white70,
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  category, style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 18,
                                ),
                                ),
                              ),
                              value: category,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
          
                    SizedBox(height: 10),
                    Text("Industry", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
          
                    TextField(
                      controller: industryCtrl,
                      decoration: InputDecoration(
                        //errorText: 'Please enter a valid value',
                          prefixIcon: Icon(Icons.work),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "New Industry Field",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold
                          ),
                          labelText: "Enter new industry",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                          )
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15
                      ),
          
                    ),
          
                    SizedBox(height: 10),
                    Text("Salary", style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold
                    )),
          
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: salaryMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //errorText: 'Please enter a valid value',
                                prefixIcon: Icon(Icons.monetization_on),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Minimum Salary (RM)",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Minimum Salary (RM)",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                )
                            ),
                            style: GoogleFonts.poppins(
                                fontSize: 15
                            ),
          
                          ),
                        ),
          
                        Text(" - ", style: GoogleFonts.poppins(
                            color: Colors.black, fontSize: 18,
                            fontWeight: FontWeight.bold
                        )),
          
                        Expanded(
                          child: TextField(
                            controller: salaryMaxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //errorText: 'Please enter a valid value',
                                prefixIcon: Icon(Icons.monetization_on),
                                filled: true,
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Maximum Salary (RM)",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Maximum Salary (RM)",
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                )
                            ),
                            style: GoogleFonts.poppins(
                                fontSize: 15
                            ),
          
                          ),
                        ),
                      ],
                    ),
          
                    SizedBox(height: 30),
          
                    InkWell(
                      onTap: ()
                      {
                        /**
                         * Navigate to login() function
                         * for web service request
                         */
                        addNewJob();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
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
                                  fontSize: 20, color: Colors.white,
                                  fontWeight: FontWeight.w600
                              )),
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

