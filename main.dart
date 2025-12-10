import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CartoonifyApp());
}

class CartoonifyApp extends StatelessWidget {
  const CartoonifyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CartoonifyAI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  bool _loading = false;
  String? _resultUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2000);
    setState(() { _image = picked; _resultUrl = null; });
  }

  Future<void> _takePhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2000);
    setState(() { _image = picked; _resultUrl = null; });
  }

  Future<void> _sendToServer() async {
    if (_image == null) return;
    setState(() { _loading = true; _resultUrl = null; });

    try {
      // TODO: replace with your server endpoint that runs the AI model
      final uri = Uri.parse('https://example.com/api/cartoonify');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        // Expect server to return JSON: { "result_url": "https://..." }
        final body = resp.body;
        // very lightweight parse (not using dart:convert to keep simple)
        final match = RegExp(r'"result_url"\s*:\s*"(.*?)"').firstMatch(body);
        setState(() {
          _resultUrl = match != null ? match.group(1) : null;
        });
      } else {
        _showMessage('Server error: \${resp.statusCode}');
      }
    } catch (e) {
      _showMessage('Network error: \$e');
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _showMessage(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CartoonifyAI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _image == null
                    ? const Text('Select a photo or take a picture', textAlign: TextAlign.center)
                    : Image.file(File(_image!.path)),
              ),
            ),
            if (_resultUrl != null) ...[
              const Text('Result (from server):'),
              Image.network(_resultUrl!)
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  onPressed: _loading ? null : _pickImage,
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: _loading ? null : _takePhoto,
                )),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: _loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.send),
              label: const Text('Cartoonify (send to server)'),
              onPressed: (_image != null && !_loading) ? _sendToServer : null,
            ),
            const SizedBox(height: 8),
            const Text('Server: replace https://example.com/api/cartoonify with your endpoint.'),
          ],
        ),
      ),
    );
  }
}
