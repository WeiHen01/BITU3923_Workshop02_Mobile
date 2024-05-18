import 'user.dart';

/**
 * This is the Forum class for temporary
 */
class Forum {
  int forumId = 0;
  String forumName = "";
  String forumDesc = "";
  String forumDate = "";
  String forumTime = "";

  // foreign key
  User? admin;

  /**
   * constructor
   */
  Forum(this.forumId, this.forumName, this.forumDesc,
        this.forumDate, this.forumTime, this.admin);

  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  Forum.fromJson(Map<String, dynamic> json):
        forumId = json["forumId"],
        forumName = json["forumname"],
        forumDesc = json["forumDesc"],
        forumDate = json["forumDate"],
        forumTime = json["forumTime"],
        admin = json["adminID"] != null && json["adminID"] is Map<String, dynamic>
            ? User.fromJson(json["adminID"])
            : null;


  /**
   * getters and setters
   */
  int get _forumId => forumId;
  set _forumId(int value) => forumId = value;

  String get _forumName => forumName;
  set _forumName(String value) => forumName = value;

  String get _forumDesc => forumDesc;
  set _forumDesc(String value) => forumDesc = value;

  String get _forumDate => forumDate;
  set _forumDate(String value) => forumDate = value;

  String get _forumTime => forumTime;
  set _forumTime(String value) => forumTime = value;

  User? get _admin => admin;
  set _admin(User? value) => admin = value;
}