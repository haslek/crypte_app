import 'package:cryptem_app/auth/login.dart';
import 'package:cryptem_app/util_widget/c_alert_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _cObscureText = true;
  String firstName;
  String lastName;
  String phone;
  String email;
  String displayName;
  String designation;
  String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
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
                          designation = value;
                        },
                        onSaved: (value){
                          designation = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Mr, Mrs ....",
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
                          firstName = value;
                        },
                        onSaved: (value){
                          firstName = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.person),
                          hintText: "Enter first name",
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
                          lastName = value;
                        },
                        onSaved: (value){
                          lastName = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.person),
                          hintText: "Enter last name",
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
                          displayName = value;
                        },
                        onSaved: (value){
                          displayName = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter display name",
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
                          phone = value;
                        },
                        onSaved: (value){
                          phone = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.phone),
                          hintText: "Enter phone",
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
                          email = value;
                        },
                        onSaved: (value){
                          email = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.email_outlined),
                          hintText: "Enter Email",
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
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        validator: (value){
                          if(value.isEmpty || value!= password){
                            return "This field value must be equal to th password field value";
                          }
                          return null;
                        },
                        obscureText: _cObscureText,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Confirm password",
                            suffixIcon: IconButton(
                              icon: Icon(_cObscureText ? Icons.visibility : Icons.visibility_off_outlined),
                              onPressed: (){
                                setState(() {
                                  _cObscureText = !_cObscureText;
                                });
                              },
                            )
                        ),
                      ),
                    )
                    ,
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Already have account?"),
                          FlatButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                          }, child: Text("Login",style: TextStyle(decoration: TextDecoration.underline),))
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        onPrimary: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      ),
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
                          Map<String,dynamic> lCred = {"email":email,"password":password,"phone":phone,
                            "first_name":firstName,"last_name":lastName,"designation":designation,"display_name":displayName};
                          print(displayName);

                          Response loginResponse = await postCalls("signup",lCred);
                          if(loginResponse.status == Status.ERROR){
                            Navigator.pop(context);
                            await showFailureDialog(loginResponse.message,context);
                          }else{
                            Navigator.pop(context);
                            Map<String,dynamic> data = loginResponse.data;
                            await showSuccessDialog(loginResponse.message, context);
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("pKey", data["key"]);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreen()));
                          }
                        }
                      },
                      child: Text('Submit'),
                    )

                  ],
                ),
              ),
            ),
          )),
    );

  }
}
