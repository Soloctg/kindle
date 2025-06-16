import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kindle/src/features/web3/web3.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import '../features/web3/web3_service.dart';

class CreateFundraiserScreen extends StatefulWidget {
  const CreateFundraiserScreen({super.key});

  @override
  State<CreateFundraiserScreen> createState() => _CreateFundraiserScreenState();
}

class _CreateFundraiserScreenState extends State<CreateFundraiserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String> _uploadImageToSupabase(
    File imageFile,
    String fundraiserId,
  ) async {
    final supabase = Supabase.instance.client;
    final bytes = await imageFile.readAsBytes();
    final filePath = 'fundraisers/$fundraiserId.png';

    final response = await supabase.storage
        .from('fundraiser-images')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: true,
          ),
        );

    if (response.isEmpty) {
      throw Exception('Image upload failed');
    }

    final imageUrl = supabase.storage
        .from('fundraiser-images')
        .getPublicUrl(filePath);
    return imageUrl;
  }

  Future<void> _createFundraiser() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields and add an image"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;

    try {
      final fundraiserId = const Uuid().v4();
      final imageUrl = await _uploadImageToSupabase(_imageFile!, fundraiserId);

      // Mint token (replace with your logic)

      //final tokenAddress = await Web3Service().mintFundraiserToken(
      //name: _titleController.text.trim(),
      //symbol: fundraiserId.substring(0, 6).toUpperCase(),
      //description: _descriptionController.text.trim(),
      //uri: Uri.parse(imageUrl),
      //);

      final response = await supabase.from('fundraisers').insert({
        'id': fundraiserId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'target_amount': double.parse(_targetAmountController.text.trim()),
        'image_url': imageUrl,
        //'token_address': tokenAddress,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create fundraiser: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Fundraiser")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 150)
                        : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text("Tap to upload image"),
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Fundraiser Title',
                ),
                validator: (value) => value!.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator:
                    (value) => value!.isEmpty ? "Enter a description" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (SOL)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return "Enter target amount";
                  if (double.tryParse(value) == null)
                    return "Enter valid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _createFundraiser,
                    child: const Text("Create Fundraiser"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
