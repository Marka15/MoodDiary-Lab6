import 'dart:io';
import 'package:flutter/foundation.dart'; // Для роботи з файлами
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Пакет для галереї
import '../models/mood_option_model.dart';
import '../models/mood_entry_model.dart';
import '../repositories/mood_repository.dart';

void showAddMoodDialog(BuildContext context, {MoodEntryModel? entryToEdit}) {
  showDialog(
    context: context,
    barrierColor: const Color.fromARGB(255, 166, 194, 166).withOpacity(0.7),
    builder: (BuildContext context) {
      return AddMoodDialog(entryToEdit: entryToEdit);
    },
  );
}

class AddMoodDialog extends StatefulWidget {
  final MoodEntryModel? entryToEdit;
  const AddMoodDialog({Key? key, this.entryToEdit}) : super(key: key);

  @override
  _AddMoodDialogState createState() => _AddMoodDialogState();
}

class _AddMoodDialogState extends State<AddMoodDialog> {
  final MoodRepository _repository = MoodRepository();
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  MoodOption? _selectedMood;

  // Змінні для роботи з фото
  XFile? _newImageFile; // Для нового фото
  String? _existingImageUrl; // Для редагування старого фото
  final ImagePicker _picker = ImagePicker();

  final List<MoodOption> _moodOptions = const [
    MoodOption(emoji: '🤩', label: 'Відмінно', color: Color(0xFF90C890)),
    MoodOption(emoji: '😊', label: 'Добре', color: Color(0xFFB7DEB7)),
    MoodOption(emoji: '😐', label: 'Нормально', color: Color(0xFFFFF2A7)),
    MoodOption(emoji: '😟', label: 'Погано', color: Color(0xFFFFD19A)),
    MoodOption(emoji: '😭', label: 'Жахливо', color: Color(0xFFFFA994)),
    MoodOption(emoji: '🥰', label: 'Закоханий', color: Color(0xFFF7B4D4)),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _selectedDate = widget.entryToEdit!.date;
      _notesController = TextEditingController(text: widget.entryToEdit!.notes);
      _existingImageUrl = widget.entryToEdit!.imageUrl; // Зберігаємо старе URL
      
      try {
        _selectedMood = _moodOptions.firstWhere(
          (option) => option.emoji == widget.entryToEdit!.emoji
        );
      } catch (e) {
        _selectedMood = null;
      }
    } else {
      _selectedDate = DateTime.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Функція вибору фото
 Future<void> _pickImage() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _newImageFile = pickedFile; 
      });
    }
  } catch (e) {
    print("Error picking image: $e");
  }
}

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('uk', 'UA'),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5FB35F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Не авторизовано");

      // 3. НОВЕ: Логіка завантаження фото
      String? finalImageUrl = _existingImageUrl; // За замовчуванням - старе фото

      // Якщо користувач вибрав нове фото - вантажимо його
      if (_newImageFile != null) {
  // Передаємо _newImageFile напряму
  finalImageUrl = await _repository.uploadImage(_newImageFile!, user.uid);
}

      final entry = MoodEntryModel(
        id: widget.entryToEdit?.id,
        userId: user.uid,
        date: _selectedDate,
        emoji: _selectedMood!.emoji,
        moodText: _selectedMood!.label,
        summary: _notesController.text.isNotEmpty 
            ? _notesController.text 
            : _selectedMood!.label,
        notes: _notesController.text,
        imageUrl: finalImageUrl, // Зберігаємо URL
      );

      if (widget.entryToEdit == null) {
        await _repository.addEntry(entry);
      } else {
        await _repository.updateEntry(entry);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(widget.entryToEdit == null ? 'Запис створено!' : 'Запис оновлено!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final dateText = isToday 
        ? 'Сьогодні, ${DateFormat('d MMMM', 'uk_UA').format(_selectedDate)}'
        : DateFormat('d MMMM yyyy', 'uk_UA').format(_selectedDate);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.entryToEdit == null ? 'Як пройшов цей день? ✨' : 'Редагувати запис ✏️',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F0), 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFB7DEB7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF5FB35F)),
                              const SizedBox(width: 8),
                              Text(
                                dateText,
                                style: const TextStyle(
                                  color: Color(0xFF3E8B3E), 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _moodOptions.map((mood) {
                  return _MoodButton(
                    mood: mood,
                    isSelected: _selectedMood == mood,
                    onTap: () {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Додайте нотатку... (опціонально)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5FB35F)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. НОВЕ: Віджет для вибору фото
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildImagePreview(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedMood == null || _isSaving) 
                      ? null 
                      : _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5FB35F),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Зберегти запис'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
  if (_newImageFile != null) {
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_newImageFile!.path, fit: BoxFit.cover),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_newImageFile!.path), fit: BoxFit.cover),
      );
    }
  } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
    );
  } else {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text('Додати фото (опціонально)', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
}
class _MoodButton extends StatelessWidget {
  final MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    Key? key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95, // Трохи зменшив ширину, щоб влізало
        height: 95,
        decoration: BoxDecoration(
          color: mood.color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF3E8B3E), width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(mood.label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}