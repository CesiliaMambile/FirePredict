import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'dart:io';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _api = ApiService();
  final _noteCtrl = TextEditingController();
  File? _image;
  Position? _position;
  bool _submitting = false;
  String? _submitted;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _position = pos);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting your location first...')),
      );
      await _getLocation();
    }
    setState(() => _submitting = true);
    try {
      final res = await _api.reportFire(
        lat: _position?.latitude ?? -3.0674,
        lon: _position?.longitude ?? 37.3556,
        note: _noteCtrl.text,
      );
      setState(() {
        _submitted = res['report_id'] ?? 'RPT_OK';
        _submitting = false;
      });
    } catch (_) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit. Check server connection.')),
      );
    }
  }

  void _reset() => setState(() {
        _submitted = null;
        _image = null;
        _position = null;
        _noteCtrl.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Fire')),
      body: _submitted != null ? _SuccessView(id: _submitted!, onReset: _reset) : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF57C00)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your report does not create predictions — it helps validate the model and supports future improvements.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_image!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.black26),
                        SizedBox(height: 8),
                        Text('Tap to take photo',
                            style: TextStyle(color: Colors.black38)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Location (auto-detected)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _getLocation,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      color: _position != null
                          ? const Color(0xFF4CAF50)
                          : Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _position != null
                          ? '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                          : 'Tap to get current location',
                      style: TextStyle(
                          color: _position != null
                              ? Colors.black87
                              : Colors.black38),
                    ),
                  ),
                  if (_position != null)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Notes (optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe what you see — fire size, smoke direction...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label: Text(_submitting ? 'Submitting...' : 'Submit Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String id;
  final VoidCallback onReset;
  const _SuccessView({required this.id, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFF4CAF50)),
            const SizedBox(height: 20),
            const Text('Report Submitted!',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Report ID: $id',
                style: const TextStyle(color: Colors.black45, fontSize: 13)),
            const SizedBox(height: 12),
            const Text(
              'Thank you. Your fire report has been logged for expert review.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 30),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Submit Another Report'),
            ),
          ],
        ),
      ),
    );
  }
}
