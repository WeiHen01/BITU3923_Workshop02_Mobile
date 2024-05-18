import 'package:bitu3923_group05/view/company/CompanyHome_Navi.dart';
import 'package:bitu3923_group05/view/user/home_navi.dart';
import 'package:bitu3923_group05/view/widget/login_role.dart';
import 'package:bitu3923_group05/view/widget/onboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// library to use Google Fonts
import 'package:google_fonts/google_fonts.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class IPAddressInput extends StatelessWidget {
  IPAddressInput({super.key});

  TextEditingController ipAddressTxtCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Linear gradient for background
            gradient: LinearGradient(

              //determine the direction and angle of each color stop in gradient
              begin: Alignment.topRight,
              end: Alignment.bottomRight,

              //0xFF is needed to convert RGB Hex code to int value
              // Hex code here is 29539B and 1E3B70
              // Gradient Name: Unloved Teen
              colors: [
                Color(0xFFFBC2EB), // #fbc2eb
                Color(0xFFA6C1EE), // #a6c1ee
              ],
            )
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("IP Address",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 40, color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xFF545454),
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                        ),
                      ],
                    )
                ),
                    
                Image.asset(
                    'images/ip_address.png',
                    height: 350, width: 350),
                    
                SizedBox(height: 10),
                    
                Row(
                  children: [
                    Expanded(
                      child: Text("Please enter IP address of your current connected network",
                          style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.black,
                          ),textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                /**
                 * The Username Field
                 */
                TextField(
                  controller: ipAddressTxtCtrl,
                  decoration: InputDecoration(
                    //errorText: 'Please enter a valid value',
                      prefixIcon: Icon(Icons.network_wifi),
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter the IP Address",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold
                      ),
                      labelText: "Enter the IP Address",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                      )
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 15
                  ),
            
                ),
                    
                SizedBox(height: 15),
            
                InkWell(
                  onTap: () async
                  {
                    /**
                     * Navigate to login() function
                     * for web service request
                     */
                    if(ipAddressTxtCtrl.text.isNotEmpty && ipAddressTxtCtrl.text != ""){
                      final prefs = await SharedPreferences.getInstance();
                      String ip = ipAddressTxtCtrl.text;
                      await prefs.setString("localhost", ip);
                    
                      int? userID = await prefs.getInt("loggedUserId");
                      String? username = await prefs.getString("loggedUsername");
                      String? usertype = await prefs.getString("usertype");
                      int? companyID = await prefs.getInt("company");
                    
                      ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.success,
                            title: "Bingo! Successful!",
                            text: "You have set IP Address successfully!",
                            onConfirm: (){
                    
                              /**
                               * This is to check
                               * if the user has logged in before,
                               * the system will directly load back to the user home page
                               * without have to login again
                               */
                    
                              if(usertype == "Admin"){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => UserRole()
                                )
                                );
                              }
                              else if(usertype == "Company"){

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanyHomeNavi(
                                              username: username ?? "",
                                              id: userID ?? 0,
                                              tabIndexes: 0,
                                              company: companyID ?? 0),
                                    ), (route) => false);
                              }
                              else if(usertype == "Job Seeker"){

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeNavi(
                                              username: username ?? "",
                                              id: userID ?? 0,
                                              tabIndexes: 0
                                          ),
                                    ), (route) => false);
                              }
                              else {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => OnBoarding()
                                )
                                );
                              }
                            }
                          )
                      );
                    
                    }
                    else {
                      ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "EMPTY INPUT!",
                            text: "This text field cannot be blank!",
                          )
                      );
                    }
                    
            
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
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
                      child: Text(
                          "Set IP Localhost",
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: Colors.black,
                              fontWeight: FontWeight.w600
                          )),
                    ),
                  ),
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}
