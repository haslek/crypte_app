import 'package:cryptem_app/chats/message_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils.dart';

class RequestChatScreen extends StatefulWidget {

  @override
  _RequestChatScreenState createState() => _RequestChatScreenState();
}

class _RequestChatScreenState extends State<RequestChatScreen> {
  final _formKey = new GlobalKey<FormState>();
  final dbService = GetIt.I<DBService>();
  final socketService = GetIt.I<SocketService>();
  String userInput;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      userInput = value;
                    },
                    onSaved: (value){
                      userInput = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.email_outlined),
                      hintText: "Enter Email or phone",
                    ),
                  ),
                ),
                Material(
                  elevation: 5.0,
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    padding: const EdgeInsets.fromLTRB(40,8,40,8),
                    minWidth: MediaQuery.of(context).size.width-80,
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
                        User user = GetIt.I<User>();
                        Map<String,dynamic> lCred = {"cred":userInput,"sender":user.gUserId};
                        var existingRoom = await dbService.getRoomFromPhone(userInput);
                        if(existingRoom is Room){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>MessageRoomScreen(room: existingRoom)));
                          // Navigator.popAndPushNamed(context, '/message_room',arguments: ex)
                        }
                        Response loginResponse = await postCalls("searchFriend",lCred,token: user.gAccessToken);
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
                          ChatMates chatM = ChatMates.fromJson(loginResponse.data['friend']);
                          // print(loginResponse.data['room']);
                          // print("friend:");
                          // print(loginResponse.data['friend']);
                          Room nRoom = Room.fromJson(loginResponse.data['room']);

                          await dbService.createRoom(nRoom);
                          await dbService.addRoomMember(chatM, int.parse(nRoom.roomId));
                          socketService.emitEvent("chat request",{"sent_to":chatM.email,"sender":userToChatMate(),"room":nRoom.toMap()});
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>MessageRoomScreen(room: nRoom)));
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MessageRoomScreen(room: nRoom)));
                        }
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
