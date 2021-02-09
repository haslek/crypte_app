import 'package:cryptem_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MessageRoomScreen extends StatefulWidget {

  @override
  _MessageRoomScreenState createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends State<MessageRoomScreen> {
  SocketService socketService = GetIt.instance<SocketService>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            centerTitle: true,
            // flexibleSpace: ,
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StreamBuilder<Object>(
                  stream: socketService.getResponse,
                  builder: (context, snapshot) {
                    return Center(child: Text("hello"),);
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: TextField(
                        onChanged: (value){

                        },
                        maxLines: 10,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "Type your message..",
                          border: OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.camera_alt_outlined),
                                onPressed: (){

                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: (){

                                },
                              ),
                            ],
                          )
                        ),
                      )),
                      RawMaterialButton(
                        onPressed: null,
                        elevation: 2.0,
                        fillColor: Colors.grey,
                        child: Icon(Icons.send),
                        shape: CircleBorder(),

                        padding: EdgeInsets.all(10.0),
                        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
