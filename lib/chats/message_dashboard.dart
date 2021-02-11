import 'package:cryptem_app/chats/message_room_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import '../utils.dart';
class MessageDashboardScreen extends StatefulWidget {
  @override
  _MessageDashboardScreenState createState() => _MessageDashboardScreenState();
}

class _MessageDashboardScreenState extends State<MessageDashboardScreen> {
  final items = List<String>.generate(8, (index) => "$index");
  SocketService socketService = GetIt.instance<SocketService>();
  List<Room> userRooms = [];

  @override
  void initState(){
    super.initState();
    socketService.connectAndListen();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            centerTitle: true,
            title: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amberAccent,
                radius: 60.0,
              ),
              trailing: FaIcon(FontAwesomeIcons.ellipsisV),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.only(left: 10),
                    child: Text("My name"),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 2.0,color: Colors.orangeAccent)
                    ),
                    child: FaIcon(FontAwesomeIcons.search,color: Colors.white10,),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(padding: EdgeInsets.all(1),
                child: Center(
                  child: Text("2 online friends"),
                ),
              ),
            ),
            Expanded(
              flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context,index){
                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text('${items[index]}'),
                          radius: 40.0,
                        );
                      }
                  ),
                )
            ),
            Expanded(child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Center(
                child: Text("Recent Conversations"),
              ),
            )),
            Expanded(
              flex: 20,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(1, 10, 1, 1),
                    child: StreamBuilder<Map<String,dynamic>>(
                      stream: socketService.getResponse,
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          Map<String,dynamic> data = snapshot.data;
                          if(data['type'] == "your rooms"){
                            print(data['data']);
                          }
                        }
                        return ListView.builder(
                          itemCount: userRooms.length,
                          itemBuilder: (context,index){
                            return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>MessageRoomScreen(room: userRooms[index],)),);
                              },
                              child: PhysicalModel(
                                shape: BoxShape.rectangle,
                                color: Colors.white60,
                                elevation: 3.0,
                                shadowColor: Colors.black,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: Colors.black12,width: 2.0),
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.black26,
                                    ),
                                    trailing: Text("$index"),
                                    title: Text("My name$index"),
                                    subtitle: Text("07090909090"),
                                  ),
                                ),
                              ),
                            );
                          }
                  );
                      }
                    ),
              )
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: FaIcon(FontAwesomeIcons.commentMedical),
          onPressed: (){

          },
        ),
      ),
    );
  }
}
