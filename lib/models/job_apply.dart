import 'package:bitu3923_group05/models/advertisement.dart';
import 'package:bitu3923_group05/models/user.dart';

import 'company.dart';

/**
 * This is the Job Apply class for temporary
 */

class JobApply {
  int ApplyId;
  String ApplyStartDate = "";
  String ApplyEndDate = "";
  String ApplyStartTime = "";
  String ApplyEndTime = "";
  String ApplyStatus = "";

  // foreign key
  User user;
  Advertisement adsId;

  /**
   * constructor
   */
  JobApply(this.ApplyId,
      this.user, this.adsId, this.ApplyStartDate,
      this.ApplyEndDate, this.ApplyStartTime, this.ApplyEndTime,
      this.ApplyStatus);

  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  JobApply.fromJson(Map<String, dynamic> json) :
        ApplyId = json["id"],
        user = User.fromJson(json["userID"]),
        adsId = Advertisement.fromJson(json["adsId"]),
        ApplyStartDate = json["applyStartDate"],
        ApplyEndDate = json["applyEndDate"],
        ApplyStartTime = json["applyStartTime"],
        ApplyEndTime = json["applyEndTime"],
        ApplyStatus = json["applyStatus"];


  /**
   * getters and setters
   */
  User get _user => user;
  set _user(User value) => user = value;

  Advertisement get _adsId => adsId;
  set _adsId(Advertisement value) => adsId = value;

  String get _ApplyStartDate => ApplyStartDate;
  set _ApplyStartDate(String value) => ApplyStartDate = value;

  String get _ApplyEndDate => ApplyEndDate;
  set _ApplyEndDate(String value) => ApplyEndDate = value;

  String get _AdsDate => ApplyEndTime;
  set _AdsDate(String value) => ApplyEndTime = value;

  String get _ApplyStartTime => ApplyStartTime;
  set _ApplyStartTime(String value) => ApplyStartTime = value;

  String get _ApplyStatus => ApplyStatus;
  set _ApplyStatus(String value) => ApplyStatus = value;


}