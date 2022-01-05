import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add(userMap);

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width / 1,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 15,
                width: size.width / 1.1,
                child: Stack(
                  children: [
                    Container(
                      width: size.width / 1.36,
                      child: TextField(
                        controller: _search,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: "Search",
                          contentPadding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 0, 6),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: size.height / 15,
                            width: size.width / 7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.blue,
                                )
                            ),
                            // margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton(
                              onPressed: onSearch,
                              child: Icon(
                                Icons.search,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height / 90,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  child: Container(),
                ),
            userMap != null
                ? Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: Container(
                      width: size.width / 1.1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade300,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey.shade300,
                          )
                      ),
                      child: ListTile(
                          onTap: onAddMembers,
                          leading: Icon(Icons.account_circle, size: 42),
                          title: Text(userMap!['name']),
                          subtitle: Text(userMap!['email']),
                          trailing: Icon(Icons.add),
                        ),
                    ),
                  ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
