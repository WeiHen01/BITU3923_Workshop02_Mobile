import 'dart:convert'; //json encode/decode
import 'package:http/http.dart' as http;

class WebRequestController{
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  /**
   * 10.0.2.2 -> emulator on Android Studio
   * 10.0.3.2 -> emulator on Genymotion
   * 10.132.7.13 -> ipconfig for network connection
   **/
  WebRequestController({required this.path,
    required this.server});
  setBody(Map<String, dynamic> data){
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );

    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }

  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  Future<void> put() async{
    _res = await http.put(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }

  Future<void> delete() async {

    // Make a DELETE request to the server
    _res = await http.delete(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );

    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }



  void _parseResult(){
    // parse result into json structure if possible
    try{
      print("raw response:${_res?.body}");
      _resultData = jsonDecode(_res?.body?? "");
    }catch(ex){
      // otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }
  dynamic result(){
    return _resultData;
  }

  int status(){
    return _res?.statusCode ?? 0;
  }
}