import 'package:flutter/material.dart';
import '../api_client.dart';

class CarsScreen extends StatefulWidget {
  final ApiClient api;
  const CarsScreen({super.key, required this.api});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  List<dynamic> _cars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _cars = await widget.api.getCars();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Автомобили')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _cars.length,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    leading: Text('🚙', style: TextStyle(fontSize: 36)),
                    title: Text(_cars[i]['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Пробег: ${_cars[i]['last_mileage'] ?? 0} км'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_cars[i]['is_active'] == true || _cars[i]['is_active'] == 1)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('В работе', style: TextStyle(fontSize: 11, color: Colors.green)),
                          ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}