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

class UserResume extends StatefulWidget {
  final int? userid;
  const UserResume({required this.userid});

  @override
  State<UserResume> createState() => _ResumeState();
}

class _ResumeState extends State<UserResume> {

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
        "inployed/file/updateFile/${widget.userid}";

    if (filename == null) return;

    var putUriDatabase = Uri.parse(urlDatabase);
    var request = new http.MultipartRequest("PUT", putUriDatabase);
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
        msg: "Success update $filename to database",
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );

      Navigator.pop(context);
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

  Future<void> fetchFileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(
      Uri.parse('http://$server:8080/inployed/file/getResumeDetails/${widget.userid}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        filename = responseData['name'];
      });
    } else {
      // Handle error cases here, e.g., display an error message.
      setState(() {
        filename = 'File not found';
      });
    }
  }


  /**
   * download file to local storage
   */

  Future downloadFile(String filename) async{
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    String urlDownload = "http://$server:8080/inployed/downloadFile/";
    final response = await http.get(Uri.parse(urlDownload + filename));

    print(response.statusCode);
    print(response.body);

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Save the file to the device
      final file = File(Directory.systemTemp.path + '/$filename');
      await file.writeAsBytes(response.bodyBytes);
      print(file.path);

      // Open the file
      OpenFile.open(file.path);

    } else {
      print('Error downloading file: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFileDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update your resume", style: GoogleFonts.poppins(
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
                    height: 1000,
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
                              width: double.infinity,
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
                                          fontSize: 13, color: Colors.black,
                                        ), overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
            
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(onPressed: (){
                                        downloadFile(filename);
                                      },
                                          icon: Icon(Icons.download)),
                                      IconButton(onPressed: (){
                                        setState(() {
                                          filename = "";
                                          print(filename);
                                        });
                                      }, icon: Icon(Icons.close)),
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
