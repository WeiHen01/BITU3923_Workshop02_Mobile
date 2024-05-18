import 'package:bitu3923_group05/view/widget/login_role.dart';
import 'package:bitu3923_group05/view/user/register.dart';
import 'package:bitu3923_group05/view/widget/register_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/onboarding_list.dart';
import '../user/home.dart';
import '../user/login.dart';


/**
 * This is the onboarding screen which is a introductory screen
 * normally after splash screen.
 */

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}


class _OnBoardingState extends State<OnBoarding> {

  /**
   * Variables
   * 1. currentIndex -> used to identify the current page user located at
   * 2. lastIndex -> used to determine the last index based on number of item in the list
   * 3. PageController -> a class to control PageView
   *    The index of page starts with 0,1,2.. that's why
   *    lastIndex = List.length - 1
   * 4. label -> label for the button on each page in PageView
   */
  int currentIndex = 0;
  int lastIndex = contents.length - 1;
  final PageController _pageController = PageController();
  String label = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkOnboardingStatus();
  }

  /**
   * SharedPreferences here is used to
   * limit the onboarding screen to pop up for only one time.
   */

  /*Future<void> checkOnboardingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    if (onboardingCompleted) {
      // Onboarding has been completed, navigate to the main screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          // set the decoration of the container
          decoration: BoxDecoration(
            // set the background color of the container to be gradient
              gradient: LinearGradient(
                // determine the direction and angle of each color stop in gradient
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,

                  /**
                   * 0xFF is needed to convert RGB Hex code to int value
                      Hex code here is 29539B and 1E3B70
                      Gradient Name: Unloved Teen
                   */
                colors: [
                  Color(0xFFFBC2EB), // #fbc2eb
                  Color(0xFFA6C1EE), // #a6c1ee
                ],
              ),

          ),

          child: PageView.builder(
            /**
             * Number of items (which is the pages)
             * on the onboarding screen
             */
              itemCount: contents.length,

              // set the controller of the PageView
              controller: _pageController,

              // update at User Interface when user slides to other pages
              onPageChanged: (int pgIndex) {
                setState(() {
                  currentIndex = pgIndex;
                });
              },

              /**
               * Here we start building the content for each pages
               */
              itemBuilder: (BuildContext context, int index)
              {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /**
                     * This container box will including
                     * images, titles and description
                     * on the onboarding screen
                     */
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [

                          /**
                            This is the image for each page
                            Importing the image based on the List
                            on "models/onboarding_list.dart"
                          */
                          Image.asset(contents[index].image),

                          /**
                             The title of the onboarding screen pages
                           */
                          Text(
                            /**
                               here will looping the title
                               based on the List on
                               "models/onboarding_list.dart"
                             */
                              contents[index].title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )
                          ),

                          // The spacing needed
                          SizedBox(height: 10),

                          /**
                              This is the description on each page
                               here will looping the description
                               based on the List on
                               "models/onboarding_list.dart"
                             */
                          Text(
                              contents[index].description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black,
                              )
                          ),

                          // The spacing needed
                          SizedBox(height: 70),

                          /**
                           * Dot indicator
                           */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            /**
                             * List.generate is responsible for
                             * creating each individual generator
                             * based on the List in "models/onboarding_list.dart"
                             */
                            children: List.generate(
                              /**
                               * Padding is used for more spacing the dot so that the circle
                               * won't look tight in horizontal
                               */
                                contents.length, (index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: AnimatedContainer(
                                // the animation type
                                curve: Curves.easeIn,
                                // the animation duration
                                duration: const Duration(milliseconds: 500),
                                /**
                                 * The dot will be expanded through its width
                                 * if index == current index
                                 * where the width = 50 for true
                                 * else the width = 20
                                 */
                                width: index == currentIndex ? 50 : 20,
                                height: 15,
                                decoration: BoxDecoration(
                                  /**
                                   * if the index of a dot is same as the index at current page
                                   * the color of the dot will be changed
                                   */
                                    color: index == currentIndex? Color(
                                        0xfffff300) : Color(0xFFffffff),
                                    // how curvy for the border
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            )
                            ),



                          ),

                          // spacing needed
                          SizedBox(height: 40),

                          /**
                           * Visibility - used to hide and show the button at certain page
                           * Inkwell - used to create button using Text and Container
                           */
                          Visibility(
                            visible: currentIndex == lastIndex,
                            child: Center(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: ()
                                    {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserRegisterRole()));
                                    },
                                    child: Container(
                                      width: 300,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xfffff900),
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
                                            "Let's get started!",
                                            style: GoogleFonts.poppins(
                                                fontSize: 20, fontWeight: FontWeight.w600
                                            )),
                                      ),
                                    ),
                                  ),

                                  TextButton(onPressed: (){
                                    Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=>UserRole()));
                                  }, child: Text("I already have an account",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.black
                                      )))

                                ],
                              ),
                            ),
                          ),

                        ],
                      )
                    ),
                  ]
                );
              }

          ),

        )
      )
    );
  }
}
