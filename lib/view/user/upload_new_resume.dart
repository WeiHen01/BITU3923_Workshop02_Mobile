import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:open_file/open_file.dart';

// for MediaType class
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class NewResume extends StatefulWidget {
  final int? userid;
  const NewResume({required this.userid});

  @override
  State<NewResume> createState() => _NewResumeState();
}

class _NewResumeState extends State<NewResume> {

  /**
   * Select file locally using file picker
   */
  String filename = "";
  String filepath = "";

  void uploadLocal() async {
    /**
     * Here allow only single files can be upload
     */

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      print(result.files.single.name);

      setState(() {
        filename = result.files.single.name;
        filepath = (result.files.single.path).toString();
      });
    } else {
      print("No files selected!");
    }
  }

  /**
   * Upload files to database
   */
  Future UploadFileToDatabase(String filename, String filepath) async{
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    String urlDatabase = "http://$server:8080/"
        "inployed/file/uploadSingleFile/${widget.userid}";

    var postUriDatabase = Uri.parse(urlDatabase);
    var request = new http.MultipartRequest("POST", postUriDatabase);
    request.fields['file'] = filename;
    request.files.add(await http.MultipartFile.fromPath(
        "file", filepath,
        contentType: new MediaType('application', 'pdf')
    ));

    var response = await request.send();
    var jsonRes = await http.Response.fromStream(response);
    print(response.statusCode);
    print(jsonRes.body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Success upload $filename to database",
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );

      Fluttertoast.showToast(
        msg: 'You will be navigate to login right now!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );

      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ), (route) => false
        );
      });
    }
    else{
      Fluttertoast.showToast(
        msg: "Upload fail to database!",
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload your resume", style: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.bold),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(249, 151, 119, 1),
              Color.fromRGBO(98, 58, 162, 1),
            ],
            stops: [0.0, 0.9],
            transform: GradientRotation(358.4 * (3.1415926 / 180)),
          ),
        ),
        padding: EdgeInsets.all(15),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                    height: 950,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white30
                    ),
                    child: Column(
                      children: [
                        Image.asset("images/upload.png"),
            
                        SizedBox(height: 15,),
            
                        Text("Select files", style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        ),
            
                        GestureDetector(
                          onTap: uploadLocal,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: Radius.circular(10),
                                dashPattern: [5, 6],
                                strokeCap: StrokeCap.round,
                                strokeWidth: 3,
                                child: Container(
                                  width: 700,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.black38.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open, color: Colors.white, size: 40,),
                                      SizedBox(width: 15,),
                                      Text('Select your file', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
            
                        SizedBox(height: 10),
            
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Resume", textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
            
                            /**
                             * File uploaded box view
                             */
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.file_copy),
                                      SizedBox(width: 10),
            
                                      Text("$filename", textAlign: TextAlign.start,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15, color: Colors.black,
                                        ), overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
            
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
            
                        InkWell(
                          onTap: (){
                            UploadFileToDatabase(filename, filepath);
                          },
                          child: Container(
                            width: 300,
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
                                      fontSize: 20, color: Colors.white,
                                      fontWeight: FontWeight.w600
                                  )),
                            ),
                          ),
                        ),
            
                      ],
                    ),
                ),
                    ]
                  ),
          ),
      ),
    );
  }
}
