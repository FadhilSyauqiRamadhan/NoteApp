import 'package:flutter/material.dart';
import '../../helper/db_helper.dart';
import '../../model/note.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();


  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final Color backgroundColor = const Color(0xFF1C1F2A);
  final Color fieldColor = const Color(0xFF2A2D3E);
  final Color accentColor = const Color(0xFF4FC3F7);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Add Note", style: TextStyle(color: Colors.white)),
        backgroundColor: fieldColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAnimatedTextField(
                  controller: _titleCtrl,
                  label: "Title",
                  icon: Icons.title,
                  validatorMsg: "Please enter a title",
                ),
                const SizedBox(height: 20),
                _buildAnimatedTextField(
                  controller: _contentCtrl,
                  label: "Content",
                  icon: Icons.note_alt_outlined,
                  validatorMsg: "Please enter the content",
                  maxLines: 7,
                ),
                const SizedBox(height: 40),

                // Save Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      colors: _isSaving
                          ? [accentColor.withOpacity(0.5), accentColor.withOpacity(0.5)]
                          : [accentColor, const Color(0xFF29B6F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isSaving = true);
                        final note = NoteModel(
                          title: _titleCtrl.text.trim(),
                          content: _contentCtrl.text.trim(),
                          date: DateTime.now().toIso8601String().split("T").first,
                        );
                        await DatabaseHelper().insertNote(note);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: _isSaving
                        ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text(
                      "Save Note",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMsg,
    int maxLines = 1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: validatorMsg == null
            ? null
            : (val) {
          if (val == null || val.trim().isEmpty) return validatorMsg;
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: accentColor),
          filled: true,
          fillColor: fieldColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
