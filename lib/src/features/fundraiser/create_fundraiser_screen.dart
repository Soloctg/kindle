import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:random_avatar/random_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateFundraiserScreen extends StatefulWidget {
  const CreateFundraiserScreen({super.key});

  @override
  State<CreateFundraiserScreen> createState() => _CreateFundraiserScreenState();
}

class _CreateFundraiserScreenState extends State<CreateFundraiserScreen> {
  final _titleController = TextEditingController();
  final _tickerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  bool _loading = false;

  Future<void> _submitFundraiser() async {
    final title = _titleController.text.trim();
    final ticker = _tickerController.text.trim();
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text.trim();
    final tokenAmount = int.tryParse(amountText) ?? 0;

    if (title.isEmpty ||
        ticker.isEmpty ||
        description.isEmpty ||
        tokenAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields with valid data'),
        ),
      );
      return;
    }

    //final avatarSvg = randomAvatar(ticker);

    setState(() => _loading = true);

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        setState(() => _loading = false);
        return;
      }
      await Supabase.instance.client.from('posts').insert({
        'title': title,
        'ticker': ticker,
        'description': description,
        'token_amount': tokenAmount,
        'amount_raised': 0,
        'owner_id': currentUser.id,
        //'avatar_svg': avatarSvg,
      });

      if (!mounted) return;
      Navigator.pop(context, {
        'title': title,
        'ticker': ticker,
        'description': description,
        'amountRaised': 0.0,
        'tokenAmount': tokenAmount,
        //'avatarSvg': avatarSvg,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create fundraiser: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _tickerController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tickerController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Create Fundraiser',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputField(
              'Title',
              'Enter a fundraiser title',
              _titleController,
            ),
            const SizedBox(height: 16),
            _buildInputField('Ticker', 'e.g. KIND', _tickerController),
            const SizedBox(height: 16),
            _buildInputField(
              'Total Supply (in SOL)',
              'e.g. 1000000',
              _amountController,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              'Description',
              'Describe your cause...',
              _descriptionController,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            _buildTokenPreview(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submitFundraiser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  _loading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F3D1F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenPreview() {
    final title = _titleController.text.trim();
    final ticker = _tickerController.text.trim();
    final amount = _amountController.text.trim();

    if (title.isEmpty && ticker.isEmpty && amount.isEmpty) {
      return const SizedBox.shrink();
    }

    //final avatarSvg = randomAvatar(ticker.isEmpty ? '??' : ticker);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Preview',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //SvgPicture.string(avatarSvg, height: 48, width: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '[No title]' : title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x80FFFFFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ticker.isEmpty ? '???' : ticker.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Supply: ${amount.isEmpty ? '0' : '$amount SOL'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
