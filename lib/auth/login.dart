import 'package:cryptem_app/auth/signup_screen.dart';
import 'package:cryptem_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value){
                        if(value.isEmpty){
                          return "This field is required";
                        }
                        return null;
                      },
                      onChanged: (value){
                        email = value;
                      },
                      onSaved: (value){
                        email = value;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.email_outlined),
                          hintText: "Enter Email or phone",
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value){
                        if(value.isEmpty){
                          return "This field is required";
                        }
                        return null;
                      },
                      onChanged: (value){
                        password = value;
                      },
                      onSaved: (value){
                        password = value;
                      },
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter password",
                          suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off_outlined),
                          onPressed: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("New user?"),
                        FlatButton(
                          // color: Colors.orange,
                            onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                        }, child: Text("Sign up",style: TextStyle(decoration: TextDecoration.underline),))
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate returns true if the form is valid, otherwise false.
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            child: AlertDialog(
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("processing"),
                                  CircularProgressIndicator()
                                ],
                              ),
                            )
                        );
                        Map<String,dynamic> lCred = {"email":email,"password":password};

                        Response loginResponse = await postCalls("login",lCred);
                        if(loginResponse.status == Status.ERROR){
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                content: Text(
                                  loginResponse.message == null?"Unknown error occurred":loginResponse.message
                                ),
                                actions: [
                                  FlatButton(onPressed: (){
                                    Navigator.pop(context);
                                  }, child: Text("Dismiss"))
                                ],
                              )
                          );
                        }else{
                          Navigator.pop(context);
                          GetIt.I<User>().fromJson(loginResponse.data['user']);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Otp()));
                        }
                      }
                    },
                    child: Text('Submit'),
                  )

        ],
              ),
            ),
          )),
    );
  }

  Future<Response> login() async{
    return await postCalls("login",{"email":email,"password":password});
  }
}
