import 'package:flutter/material.dart';
import 'package:notes_app/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> notes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance; // Corrected Singleton Instance
    getNotes();
  }

  void getNotes() async {
    notes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: notes.isNotEmpty
          ? ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(notes[index]['TITLE']),
                    subtitle: Text(notes[index]['DESC']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context)
                                      .viewInsets
                                      .bottom, // Adjust for keyboard
                                ),
                                child: BottomSheetWidget(
                                  note: notes[index], // Pass existing note
                                  onNoteAdded: getNotes,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool check = await dbRef!.deleteNoteBySNo(
                              notes[index]['S_NO'],
                            );
                            if (check) {
                              getNotes();
                            }
                          },
                        ),
                      ],
                    ));
              },
            )
          : const Center(child: Text('No notes found')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: BottomSheetWidget(
                onNoteAdded: getNotes,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  final Function onNoteAdded;
  final Map<String, dynamic>? note; // Optional note for update mode

  const BottomSheetWidget({super.key, required this.onNoteAdded, this.note});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late TextEditingController titleController;
  late TextEditingController descController;
  DBHelper? dbRef;
  bool isUpdate = false; // Track if it's update mode

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;

    // Check if a note is provided (Edit Mode)
    isUpdate = widget.note != null;

    titleController =
        TextEditingController(text: isUpdate ? widget.note!['TITLE'] : '');
    descController =
        TextEditingController(text: isUpdate ? widget.note!['DESC'] : '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void saveNote() async {
    String title = titleController.text.trim();
    String desc = descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in both fields"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      bool check;
      if (isUpdate) {
        // If updating, update the note in the database
        check = await dbRef!.updateNoteBySNo(
          sNo: widget.note!['S_NO'],
          title: title,
          desc: desc,
        );
      } else {
        // If adding, insert a new note
        check = await dbRef!.addNote(title: title, desc: desc);
      }

      if (check) {
        Navigator.pop(context); // Close modal bottom sheet
        widget.onNoteAdded(); // Refresh notes list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUpdate ? 'Update Note' : 'Add Note',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              labelText: 'Title',
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Description',
              labelText: 'Description',
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saveNote,
                  child: Text(isUpdate ? 'Update Note' : "Save"),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
