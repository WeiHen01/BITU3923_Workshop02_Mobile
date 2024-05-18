import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserResumeViewFile extends StatefulWidget {
  final int? user;
  const UserResumeViewFile({required this.user});

  @override
  State<UserResumeViewFile> createState() => _UserResumeViewFileState();
}

class _UserResumeViewFileState extends State<UserResumeViewFile> {

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    pdfcontroller =  PdfViewerController();
    pdfData = fetchPdfData();
  }

  late Future<Uint8List> pdfData;
  late PdfViewerController pdfcontroller;

  Future<Uint8List> fetchPdfData() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(
      Uri.parse('http://$server:8080/inployed/file/getResume/${widget.user}'), // Replace with your API endpoint to fetch the PDF data.
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.bodyBytes);
    } else {
      throw Exception('Failed to load PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Resume Document", style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.bold),
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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                //Color(0xFFFBC2EB), // #fbc2eb
                //Color(0xFFA6C1EE), #a6c1ee
                Color(0xFFFBC2EB), // #fbc2eb
                Color(0xFFA6C1EE), // #a6c1ee
              ],
            )
        ),
        child: FutureBuilder<Uint8List>(
          future: pdfData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading PDF'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No PDF data available'));
            }

            final pdfBytes = snapshot.data!;

            return Stack(
              children: [
                SfPdfViewer.memory(
                  pdfBytes,
                  controller: pdfcontroller,
                  maxZoomLevel: 5,
                ),
                Positioned(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.zoom_in,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          pdfcontroller.zoomLevel = 2;
                        },
                      ),


                    ],
                  ),
                )
              ],
            );
          },
        ),
      )
    );
  }
}
