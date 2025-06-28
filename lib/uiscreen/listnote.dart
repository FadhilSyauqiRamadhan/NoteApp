import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helper/db_helper.dart';
import '../../model/note.dart';
import 'addnote.dart';
import 'editnote.dart';

class ListNoteView extends StatefulWidget {
  const ListNoteView({super.key});

  @override
  State<ListNoteView> createState() => _ListNoteViewState();
}

class _ListNoteViewState extends State<ListNoteView> {
  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();

  void _getNotes() async {
    final data = await DatabaseHelper().getNotes();
    setState(() {
      _notes = data;
      _filteredNotes = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getNotes();
    _searchController.addListener(() {
      filterNotes(_searchController.text);
    });
  }

  void filterNotes(String keyword) {
    final filtered = _notes.where((note) {
      final title = note.title.toLowerCase();
      final content = note.content.toLowerCase();
      return title.contains(keyword.toLowerCase()) || content.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      _filteredNotes = filtered;
    });
  }

  String formatDate(String date) {
    final dt = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(dt);
  }

  Color _getDotColor(int index) {
    final colors = [
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.cyanAccent,
    ];
    return colors[index % colors.length];
  }

  void _showPopupMenu(BuildContext context, Offset offset, NoteModel note) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      color: const Color(0xFF1E2432),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text("Edit", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.redAccent),
              SizedBox(width: 8),
              Text("Hapus", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );

    if (result == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditNoteView(note: note)),
      );
      _getNotes();
    } else if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E2432),
            title: const Text(
              'Konfirmasi Hapus',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Apakah kamu yakin ingin menghapus catatan ini?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await DatabaseHelper().deleteNote(note.id!);
        _getNotes();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1321),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1321),
        elevation: 0,
        title: const Text(
          "Keep Note",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2432),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  hintText: "Search note...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredNotes.isEmpty
                  ? const Center(
                child: Text(
                  "No Notes Found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return InkWell(
                    borderRadius: borderRadius,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2432),
                        borderRadius: borderRadius,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  _showPopupMenu(context, details.globalPosition, note);
                                },
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getDotColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Text(
                                formatDate(note.date),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2979FF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteView()),
          ).then((_) => _getNotes());
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
