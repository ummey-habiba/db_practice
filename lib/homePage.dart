import 'package:db_practice/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;
  String errorMsg = "";

  @override
  void initState() {
    dbRef = DbHelper.getInstance;
    super.initState();
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(allNotes[index][DbHelper.Column_Note_Title]),
                  subtitle: Text(allNotes[index][DbHelper.Column_Note_Desc]),
                  leading: Text('${index + 1}'),
                  trailing: SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  titleController.text = allNotes[index]
                                      [DbHelper.Column_Note_Title];
                                  descController.text = allNotes[index]
                                      [DbHelper.Column_Note_Desc];

                                  return getBottomSheetWidget(
                                      isUpdate: true,
                                      sno: allNotes[index]
                                          [DbHelper.Column_Note_Sno]);
                                },
                              );
                            },
                            child: Icon(Icons.edit)),
                        InkWell(
                            onTap: () async {
                              bool check = await dbRef!.deleteNote(
                                  sno: allNotes[index]
                                      [DbHelper.Column_Note_Sno]);
                              if (check) {
                                getNotes();
                              }
                            },
                            child: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No Notes yet!!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {

              return StatefulBuilder(builder: (context, state) {
                return getBottomSheetWidget();
              });
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              isUpdate ? 'Update Note' : 'Add Note',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: titleController,
              onChanged: (value) {
                print(value);
              },
              decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter your title here ',
                  hintStyle: const TextStyle(color: Colors.black38),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              maxLines: 4,
              controller: descController,
              decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter description here ',
                  hintStyle: const TextStyle(color: Colors.black38),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          var title = titleController.text;
                          var desc = descController.text;
                          if (title.isNotEmpty && desc.isNotEmpty) {
                            bool check = isUpdate
                                ? await dbRef!.updateNote(
                                    mTitle: title, mDesc: desc, sno: sno)
                                : await dbRef!
                                    .addNote(mTitle: title, mDesc: desc);
                            if (check) {
                              getNotes();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'please fill all the required blanks')));
                          }
                          titleController.clear();
                          descController.clear();
                          Navigator.pop(context);
                        },
                        child: Text(isUpdate ? 'Update Note' : 'Add Note'))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
