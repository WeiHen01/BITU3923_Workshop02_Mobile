/**
 * This is the Company class for temporary
 */

class Company {
  int companyId = 0;
  String companyName = "";
  String companyCity = "";
  String companyState = "";
  String companyCountry = "";
  String companyEmail = "";
  String companyContact = "0";
  String companyStatus = "Active";

  /**
   * constructor
   */
  Company(
      this.companyId,
      this.companyName,
      this.companyCity,
      this.companyState,
      this.companyCountry,
      this.companyEmail,
      this.companyContact,
      this.companyStatus
      );


  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  Company.fromJson(Map<String, dynamic> json) {
    companyId = json["companyID"];
    companyName = json["companyName"];
    companyCity = json["companyCity"];
    companyState = json["companyState"];
    companyCountry = json["companyCountry"];
    companyEmail = json["companyEmail"];
    companyContact = json["companyContact"];
    companyStatus = json["companyStatus"];

  }

  /**
   * getters and setters
   */
  int get _companyId => companyId;
  set _companyId(int value) => companyId = value;

  String get _companyName => companyName;
  set _companyName(String value) => companyName = value;

  String get _companyCity => companyCity;
  set _companyCity(String value) => companyCity = value;

  String get _companyState => companyState;
  set _companyState(String value) => companyState = value;

  String get _companyCountry => companyCountry;
  set _companyCountry(String value) => companyCountry = value;

  String get _companyEmail => companyEmail;
  set _companyEmail(String value) => companyEmail = value;

  String get _companyContact => companyContact;
  set _companyContact(String value) => companyContact = value;

  String get _companyStatus => companyStatus;
  set _companyStatus(String value) => companyStatus = value;

}