import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/OneSignalController.dart';
import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';

class EditCompanyAds extends StatefulWidget {
  final int ads;
  const EditCompanyAds({required this.ads});

  @override
  State<EditCompanyAds> createState() => _EditCompanyAdsState();
}

class _EditCompanyAdsState extends State<EditCompanyAds> {

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

  Advertisement? _job;
  int adsid = 0;
  String salary = "";
  int? minSalary, maxSalary;

  Future<void> getCurrentJobInfo() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/${widget.ads}",
        server: "http://$server:8080");

    await req.get();

    if (req.status() == 200) {

      // Parse the JSON response into a `User` object.
      final Map<String, dynamic> responseData = req.result();
      final job = Advertisement.fromJson(responseData);

      setState(() {
        _job = job;
        salary = job.salary;
        positionTxtCtrl.text = job.jobPosition;
        descTxtCtrl.text = job.jobDescription;
        jobtimeCtrl.text = job.jobTime;
        industryCtrl.text = job.industry;
        dropdownRemote = job.jobRemote;
        dropdownJobCommit = job.jobCommit;
        dropdownDate = job.jobDate;

        // Split the string using ' - ' as the delimiter
        List<String> parts = job.salary.split(' - ');

        // Ensure that we have two parts
        if (parts.length == 2) {
          // Extract the amounts and remove 'RM' before parsing
          String amountA = parts[0].replaceAll('RM', '');
          String amountB = parts[1].replaceAll('RM', '');

          // Parse the extracted amounts to integers
          int variableA = int.tryParse(amountA) ?? 0;
          int variableB = int.tryParse(amountB) ?? 0;

          salaryMinCtrl.text = variableA.toString();
          salaryMaxCtrl.text = variableB.toString();
        } else {
          print('Invalid input format');
        }

      });
    } else {
      throw Exception('Failed to fetch user');
    }
  }


  Future<void> updateJob() async{

    /**
     * optionally update only the text field is not null
     */
    Map<String, dynamic> requestBody = {};

    if (positionTxtCtrl.text != null && positionTxtCtrl.text.isNotEmpty) {
      requestBody["jobPosition"] = positionTxtCtrl.text;
    }

    if (descTxtCtrl.text != null && descTxtCtrl.text.isNotEmpty) {
      requestBody["jobDescription"] = descTxtCtrl.text;
    }

    if (jobtimeCtrl.text != null && jobtimeCtrl.text.isNotEmpty) {
      requestBody["jobTime"] = jobtimeCtrl.text;
    }

    if (industryCtrl.text != null && industryCtrl.text.isNotEmpty) {
      requestBody["industry"] = positionTxtCtrl.text;
    }

    if(salaryMinCtrl.text != null && salaryMinCtrl.text.isNotEmpty){
      if(salaryMaxCtrl.text != null && salaryMaxCtrl.text.isNotEmpty){
        newSalary = "RM${salaryMinCtrl.text} - RM${salaryMaxCtrl.text}";
      }
      else {
        newSalary = salaryMinCtrl.text;
      }

      requestBody["salary"] = newSalary;
    }

    if (dropdownDate != null && dropdownDate.toString().isNotEmpty) {
      requestBody["jobDate"] = dropdownDate;
    }

    if (dropdownJobCommit != null && dropdownJobCommit.toString().isNotEmpty) {
      requestBody["jobCommit"] = dropdownJobCommit;
    }

    if (dropdownRemote != null && dropdownRemote.toString().isNotEmpty) {
      requestBody["jobRemote"] = dropdownRemote;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "/inployed/job/update/jobPost/${widget.ads}",
        server: "http://$server:8080");

    req.setBody(requestBody);
    await req.put();

    print(req.result());


    if(req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update successfully',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      positionTxtCtrl.clear();
      descTxtCtrl.clear();
      jobtimeCtrl.clear();
      industryCtrl.clear();
      dropdownRemote = "";
      dropdownJobCommit = "";
      dropdownDate = "";
      salaryMinCtrl.clear();
      salaryMaxCtrl.clear();

      Navigator.pop(context);



    }
    else{
      Fluttertoast.showToast(
        msg: 'Update failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentJobInfo();
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
        title: Text("Edit your job", style: GoogleFonts.poppins(
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
                  Text("Update Job", style: GoogleFonts.poppins(
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
                          hintText: "Current :${_job?.jobPosition}",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold
                          ),
                          labelText: "Current :${_job?.jobPosition}",
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
                            hintText: "Current :${_job?.jobDescription}",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold
                            ),
                            labelText: "Current :${_job?.jobDescription}",
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


                    Table(
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Job Remote", style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 18,
                                    fontWeight: FontWeight.bold
                                )),
                              ),
                            ),

                            TableCell(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Job Commitment", style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 18,
                                    fontWeight: FontWeight.bold
                                )),
                              ),
                            ),
                          ],
                        ),


                        TableRow(
                          children: [
                            TableCell(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Card(
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
                              ),
                            ),

                            TableCell(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Card(
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
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          hintText: "Enter new jobtime",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold
                          ),
                          labelText: "Enter new jobtime",
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
                          hintText: "Enter new industry",
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
                                hintText: "Min salary (RM)",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Min salary (RM)",
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
                                hintText: "Max salary (RM)",
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.bold
                                ),
                                labelText: "Max salary (RM)",
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
                        updateJob();
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
                              "Update",
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

