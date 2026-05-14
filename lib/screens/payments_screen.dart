import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_client.dart';

class PaymentsScreen extends StatefulWidget {
  final ApiClient api;
  const PaymentsScreen({super.key, required this.api});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<dynamic> _cars = [];
  List<dynamic> _payments = [];
  int? _selectedCarId;
  final _amountCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _cars = await widget.api.getCars();
      _payments = await widget.api.getPayments();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_selectedCarId == null || _amountCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.api.addPayment(
        _selectedCarId!,
        double.parse(_amountCtrl.text),
        method: 'cash',
      );
      _amountCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
    if (mounted) setState(() => _saving = false);
  }

  String _formatDate(String? dt) {
    if (dt == null) return '';
    try {
      return DateFormat('dd.MM HH:mm').format(DateTime.parse(dt));
    } catch (_) { return dt; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Оплаты')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedCarId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Автомобиль',
                            ),
                            items: _cars.map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['name'] ?? ''),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedCarId = v),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Сумма',
                              prefixText: '₽ ',
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.add),
                              label: Text('Добавить оплату'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _payments.length,
                    itemBuilder: (_, i) => Card(
                      child: ListTile(
                        leading: Text('💰', style: TextStyle(fontSize: 24)),
                        title: Text('${_payments[i]['amount']} ₽'),
                        subtitle: Text(_formatDate(_payments[i]['paid_at'])),
                        trailing: Text(
                          _payments[i]['method'] ?? '',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
}