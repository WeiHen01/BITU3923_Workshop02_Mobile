import 'company.dart';

/**
 * This is the User class for temporary
 */
class User {
  int userId = 0;
  String username = "";
  String password = "";
  String userEmail = "";
  String userPosition = "";
  String userType = "";
  String userStatus = "Active";
  String adminId = "";
  String? lastAccessDate = "";
  String? lastAccessTime = "";
  String? lastUpdateDate = "";
  String? lastUpdateTime = "";

  Company? company;

  /**
   * constructor
   */
  User(this.userId, this.username, this.password, this.userEmail,
      this.userPosition, this.userType, this.userStatus, 
      this.company, this.adminId);

  /**
   * mapping to JSON body
   * for getting responses from JSON
   */
  User.fromJson(Map<String, dynamic> json):
    userId = json["userId"],
    username = json["username"],
    userEmail = json["userEmail"],
    password = json["userpassword"],
    userPosition = json["userPosition"],
    userStatus = json["userStatus"],
    userType = json["userType"],
    lastAccessDate = json["accessDate"],
    lastAccessTime = json["accessTime"],
    lastUpdateDate = json["updateDate"] != null? json["updateDate"] : null,
    lastUpdateTime = json["updateTime"] != null? json["updateTime"] : null,
    company = json["company"] != null && json["company"] is Map<String, dynamic>
            ? Company.fromJson(json["company"])
            : null;


  /**
   * getters and setters
   */
  int get _userId => userId;
  set _userId(int value) => userId = value;

  String get name => username;
  set name(String value) => username = value;

  String get _userEmail => userEmail;
  set _userEmail(String value) => userEmail = value;

  String get _password => password;
  set _password(String value) => password = value;

  String get _userPosition => userPosition;
  set _userPosition(String value) => userPosition = value;

  String get _userStatus => userStatus;
  set _userStatus(String value) => userStatus = value;

  String? get _lastAccessDate => lastAccessDate;
  set _lastAccessDate(String? value) => lastAccessDate = value;

  String? get _lastAccessTime => lastAccessTime;
  set _lastAccessTime(String? value) => lastAccessTime = value;

  String? get _lastUpdateDate => lastUpdateDate;
  set _lastUpdateDate(String? value) => lastUpdateDate = value;

  String? get _lastUpdateTime => lastUpdateTime;
  set _lastUpdateTime(String? value) => lastUpdateTime = value;

  Company? get _company => company;
  set _company(Company? value) => company = value;

}