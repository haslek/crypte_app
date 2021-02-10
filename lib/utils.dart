
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import "package:socket_io_client/socket_io_client.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = "http://192.168.43.159/crypte_web_app/";
  Future<dynamic> get(String url, {String token}) async {
    var responseJson;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader:"application/json",
    };
    if(token != null){
      headers[HttpHeaders.authorizationHeader] = token;
    }
    try {
      final response = await http.get(_baseUrl + url,headers: headers);
      responseJson = _response(response);
    } on SocketException {
      return 'No Internet connection';
    }
    return responseJson;
  }
  Future<dynamic> post(String url, Map<String,dynamic> data, {String token}) async {
    var responseJson;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader:"application/json",
    };
    if(token != null){
      headers[HttpHeaders.authorizationHeader] = token;
    }
    try {
      final response = await http.post(_baseUrl + url,headers:headers,body: jsonEncode(data));
      responseJson = _response(response);
    } on SocketException {
      return 'No Internet connection';
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    var responseJson = json.decode(response.body.toString());
    print(responseJson);
    switch (response.statusCode) {
      case 200:

        return responseJson;
      case 400:
        String error = 'Bad request\n';
        if(responseJson is Map){
          responseJson.forEach((key, value) {
            error = error+value.toString()+"\n";
          });
        }
        return error;
      case 401:

      case 403:
          return 'Unauthorized request';
      case 500:

      default:
            return 'Internal Sever error!';
    }
  }
}

class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }

Future<Response> postCalls(String url,Map<String,dynamic> creds,{String token}) async{
  ApiProvider provider = new ApiProvider();
  var response;
  if(token != null){
    response = await provider.post(url, creds,token: token);
  }else{
    response = await provider.post(url, creds);
  }

  Response resp;
  if(response is Map){
    if(response.containsKey("error")){
      resp = Response.error(response['error']);

    }else{
      resp = Response.completed(response);
    }

  }else{
    resp = Response.error(response);
  }
  return resp;
}
Future<Response> getCalls(String url,{String token}) async{
  ApiProvider provider = new ApiProvider();
  var response = await provider.get(url);
  Response resp;
  if(response is Map){
    if(response.containsKey("error")){
      resp.message = response['error'];
      resp.status = Status.ERROR;
    }else{
      resp.data = response;
      resp.status = Status.COMPLETED;
    }
  }else{
    resp.message = response;
    resp.status = Status.ERROR;
  }
  return resp;
}
class User{
   String _displayName;

   // ignore: unnecessary_getters_setters
   String get gAccessToken => _accessToken;

  // ignore: unnecessary_getters_setters
  set accessToken(String value) {
    _accessToken = value;
  }

  String _userId;

   // ignore: unnecessary_getters_setters
   String get gDisplayName => _displayName;

  // ignore: unnecessary_getters_setters
  set displayName(String value) {
    _displayName = value;
  }

  String _email;
   String _phone;
   String _firstName;
   String _lastName;
   String _accessToken;
   String _otp;
   bool isLoggedIn = false;
   User();

   Map<String, dynamic> toJson(){
     return {
       "display_name":_displayName,
       "user_id":_userId,
       "email":_email,
       "phone":_phone,
       "first_name":_firstName,
       "last_name":_lastName
     };
   }
   void fromJson(Map<String,dynamic> json){
     _email = json['email'].toString();
     _phone = json['phone'].toString();
     _userId = json['user_id'].toString();
     _lastName = json['last_name'].toString();
     _firstName = json['first_name'].toString();
     _otp = json['otp'].toString();
     _accessToken = json['access_token'].toString();
   }
   void login(){
     isLoggedIn = true;
   }

   // ignore: unnecessary_getters_setters
   String get gUserId => _userId;

  // ignore: unnecessary_getters_setters
  set userId(String value) {
    _userId = value;
  }

   // ignore: unnecessary_getters_setters
   String get gEmail => _email;

  // ignore: unnecessary_getters_setters
  set email(String value) {
    _email = value;
  }

   String get gPhone => _phone;

  // ignore: unnecessary_getters_setters
  set phone(String value) {
    _phone = value;
  }

   // ignore: unnecessary_getters_setters
   String get gFirstName => _firstName;

  // ignore: unnecessary_getters_setters
  set firstName(String value) {
    _firstName = value;
  }

   // ignore: unnecessary_getters_setters
   String get gLastName => _lastName;

  // ignore: unnecessary_getters_setters
  set lastName(String value) {
    _lastName = value;
  }

   // ignore: unnecessary_getters_setters
   String get gOtp => _otp;

  // ignore: unnecessary_getters_setters
  set otp(String value) {
    _otp = value;
  }
}

class SocketService{
  final _socketResponse = StreamController<String>();
  IO.Socket socket;
  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }
  Map<String,dynamic> userDetails = {
    "user_id":""
  };
  void connectAndListen(){
    this.socket = IO.io("http://localhost:3000",OptionBuilder().setTransports(['websocket']).build());
    this.socket.onConnect((_){
      print("Connected");
      this.socket.emit("online",);
    });
    this.socket.on('new message',(data)=>this.addResponse);
    this.socket.onDisconnect((_)=>print("Disconnected"));
  }

}