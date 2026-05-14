import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_client.dart';

class AddMileageScreen extends StatefulWidget {
  final ApiClient api;
  const AddMileageScreen({super.key, required this.api});

  @override
  State<AddMileageScreen> createState() => _AddMileageScreenState();
}

class _AddMileageScreenState extends State<AddMileageScreen> {
  List<dynamic> _cars = [];
  int? _selectedCarId;
  final _mileageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      _cars = await widget.api.getCars();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_selectedCarId == null || _mileageCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.api.addMileage(
        _selectedCarId!,
        int.parse(_mileageCtrl.text),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пробег сохранён'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Записать пробег')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Выберите авто', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedCarId,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Автомобиль',
            ),
            items: _cars.map((c) => DropdownMenuItem(
              value: c['id'],
              child: Text('${c['name']} (${c['last_mileage'] ?? 0} км)'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCarId = v),
          ),
          SizedBox(height: 16),
          Text('Текущий пробег', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _mileageCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Например: 203126',
              suffixText: 'км',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Заметки (необязательно)',
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.save),
              label: Text('Сохранить пробег'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mileageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}