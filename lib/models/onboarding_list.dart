import 'package:flutter/material.dart';

/**
 * This is the model class for displaying text
 * on Onboarding Screen (onboard_screen.dart)
 */
class UnboardingList{
   // Attributes
   String image;
   String title;
   String description;
   Color bground;

   /**
    * Constructor
    */
   UnboardingList(
       {required this.image,
         required this.title,
         required this.description,
         required this.bground}
       );
}

/**
 * List of contents to be displayed
 * where each item will be display in a page
 * on PageView
 */
List<UnboardingList> contents = [
  UnboardingList(
      title: 'Are you jobless?',
      image: 'images/job_hunt01.png',
      description: "Still finding jobs? Haven't obtain a satisfied job? Feel difficulty to find a job?",
      bground: Colors.white,
  ),
  UnboardingList(
      title: 'Fast Searching',
      image: 'images/job_hunt02.png',
      description: "We are here to provide a faster and easier way to help you to search for a job",
      bground: Colors.white,
  ),
  UnboardingList(
      title: 'Ready to Go!',
      image: 'images/job_hunt03.png',
      description: "Join us to start your job searching journey!",
      bground: Colors.white,
  ),
];