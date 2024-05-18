import 'company.dart';

/**
 * This is the Advertisement class for temporary
 */

class Advertisement {
  int AdsId = 0;
  String jobPosition = "";
  String jobDescription = "";
  String jobRemote = "";
  String jobDate = "";
  String jobTime = "";
  String AdsDate = "";
  String AdsTime = "";
  String jobCommit = "";
  String salary = "";
  String industry = "";

  // foreign key
  Company company;

  /**
   * constructor
   */
  Advertisement(this.AdsId,
      this.jobPosition, this.jobDescription, this.jobRemote,
      this.jobDate, this.jobTime,
      this.AdsDate, this.AdsTime, this.jobCommit,
      this.salary, this.industry, this.company);

  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  Advertisement.fromJson(Map<String, dynamic> json) :
    AdsId = json["adsId"],
    jobPosition = json["jobPosition"],
    jobDescription = json["jobDescription"],
    jobRemote = json["jobRemote"],
    jobDate = json["jobDate"],
    jobTime = json["jobTime"],
    AdsDate = json["adsDate"],
    AdsTime = json["adsTime"],
    jobCommit = json["jobCommit"],
    salary = json["salary"],
    industry = json["industry"],
    company = Company.fromJson(json['companyId']);

  /**
   * getters and setters
   */
  int get _AdsId => AdsId;
  set _AdsId(int value) => AdsId = value;

  String get _jobPosition => jobPosition;
  set _jobPosition(String value) => jobPosition = value;

  String get _jobDescription => jobDescription;
  set _jobDescription(String value) => jobDescription = value;

  String get _jobRemote => jobRemote;
  set _jobRemote(String value) => jobRemote = value;

  String get _jobDate => jobDate;
  set _jobDate(String value) => jobDate = value;

  String get _jobTime => jobTime;
  set _jobTime(String value) => jobTime = value;

  String get _AdsDate => AdsDate;
  set _AdsDate(String value) => AdsDate = value;

  String get _AdsTime => AdsTime;
  set _AdsTime(String value) => AdsTime = value;

  String get _jobCommit => jobCommit;
  set _jobCommit(String value) => jobCommit = value;

  String get _salary => salary;
  set _salary(String value) => salary = value;

  String get _industry => industry;
  set _industry(String value) => industry = value;

  Company get _company => company;
  set _company(Company newCompany) => company = newCompany;

}