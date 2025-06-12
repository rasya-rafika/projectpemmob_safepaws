import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KomunitasInputEditor extends StatefulWidget {
  final String hintText;
  final String username;
  final Function(String text, File? image) onSend;

  const KomunitasInputEditor({
    Key? key,
    required this.hintText,
    required this.username,
    required this.onSend,
  }) : super(key: key);

  @override
  State<KomunitasInputEditor> createState() => _KomunitasInputEditorState();
}

class _KomunitasInputEditorState extends State<KomunitasInputEditor> {
  final TextEditingController _controller = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Keyboard langsung muncul
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(FocusNode());
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pickedImage == null) return;

    widget.onSend(text, _pickedImage);
    _controller.clear();
    setState(() {
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Posting',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: _send,
                child: const Text(
                  'Kirim',
                  style: TextStyle(
                    color: Color(0xFFFF661E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '@${widget.username}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
              ),
            ),
          ),
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  Image.file(_pickedImage!, height: 200),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Colors.grey),
                onPressed: _pickImage,
              ),
              const Text('Tambah Gambar'),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}