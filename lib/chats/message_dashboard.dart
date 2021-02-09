import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class MessageDashboardScreen extends StatefulWidget {
  @override
  _MessageDashboardScreenState createState() => _MessageDashboardScreenState();
}

class _MessageDashboardScreenState extends State<MessageDashboardScreen> {
  final items = List<String>.generate(8, (index) => "$index");
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
                    child: ListView.builder(
                      itemCount: items.length + 8,
                      itemBuilder: (context,index){
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12,width: 2.0)
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