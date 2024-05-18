import 'user.dart';

/**
 * This is the Resume class for temporary
 */
class Resume {
  int resumeId = 0;
  User user;
  String educationLvl = "";
  String major = "";
  String docName = "";
  String docYear = "";
  String docMonth = "";


  /**
   * constructor
   */
  Resume(this.resumeId, this.user, this.educationLvl, this.major);

  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  Resume.fromJson(Map<String, dynamic> json):
        resumeId = json["resumeId"],
        user = User.fromJson(json["userId"]),
        educationLvl = json["educationLvl"],
        major = json["major"];

  /**
   * getters and setters
   */
  int get _forumId => resumeId;
  set _forumId(int value) => resumeId = value;

  User get _user => user;
  set _user(User value) => user = value;

  String get _educationLvl => educationLvl;
  set _educationLvl(String value) => educationLvl = value;

  String get _major => major;
  set _major(String value) => major = value;



}