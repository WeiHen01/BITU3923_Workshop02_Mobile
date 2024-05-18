import 'package:bitu3923_group05/view/user/search_result.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../controller/request_controller.dart';
import '../../models/advertisement.dart';

class Search extends StatefulWidget {
  const Search({required this.user, required this.username});
  final int user;
  final String username;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  late List<Advertisement> advertisements = [];
  List<Advertisement> filteredAdvertisements = [];
  TextEditingController searchController = TextEditingController();

  Future<void> getAdvertisement() async {

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(path: "/inployed/job",
        server: "http://$server:8080");

    await req.get();
    if (req.status() == 200) {

      List<dynamic> data = req.result();

      setState(() {
        advertisements = data.map((json) => Advertisement.fromJson(json)).toList();
        filteredAdvertisements = List.from(advertisements);
      });

    } else {
      throw Exception('Failed to fetch user');
    }
  }

  void searchJobPosition(String query) {
    if(searchController.text.isNotEmpty){
      setState(() {
        filteredAdvertisements = advertisements
            .where((advertisement) =>
            advertisement.jobPosition.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("User: ${widget.user}");
    getAdvertisement();
  }

  bool isListViewVisible = false;

  @override
  Widget build(BuildContext context) {

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(
            top: 30,
            left: 20, right: 20,
          ),
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBC2EB), // #fbc2eb
                  Color(0xFFA6C1EE),
                ],
                stops: [0.0, 0.9],
                transform: GradientRotation(358.4 * (3.1415926 / 180)),
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Container(
                width: 500,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                        style: GoogleFonts.poppins(
                            fontSize: 20
                        ),
                        onChanged: (query) => searchJobPosition(query),
                        onTap: () {
                          setState(() {
                            isListViewVisible = true;
                          });
                          // Show the ListView when the TextField is pressed
                        },
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Search your job here",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 20
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15)
                              )
                          ),
                          suffixIcon: IconButton(onPressed:
                            (searchController.text.isNotEmpty && searchController.text != " ")
                            ? (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=>JobSearchResult(searchQuery: searchController.text, user: widget.user, username: widget.username,))
                              );
                            }
                            : null, icon: Icon(Icons.search)),
                        ),
                        maxLines: 1, // Use 1 for a single-line TextField
                    ),


                    Visibility(
                      visible: (searchController.text.isNotEmpty)
                          ? isListViewVisible = true
                          : isListViewVisible = false,
                      child: Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: 200
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)
                            )
                          ),
                          child: ListView.builder(
                            itemCount: advertisements?.length ?? 0,
                            itemBuilder: (context, index) {
                              if (filteredAdvertisements == null || index >= filteredAdvertisements.length) {
                                // Handle out-of-bounds condition
                                return SizedBox.shrink(); // or another placeholder widget
                              }
                              return ListTile(
                                title: Text(filteredAdvertisements[index].jobPosition,
                                  style: GoogleFonts.poppins(
                                      fontSize: 18
                                  ),
                                ),
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context)=>JobSearchResult(searchQuery: filteredAdvertisements[index].jobPosition, user: widget.user, username: widget.username,))
                                  );
                                },
                                // Add other details as needed
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
