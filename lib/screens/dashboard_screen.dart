import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cars_screen.dart';
import 'payments_screen.dart';
import 'add_mileage_screen.dart';
import '../api_client.dart';

class DashboardScreen extends StatefulWidget {
  final String serverUrl;
  const DashboardScreen({super.key, required this.serverUrl});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiClient _api = ApiClient();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api.serverUrl = widget.serverUrl;
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final cars = await _api.getCars();
      setState(() { _data = {'cars': cars}; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int _activeCars() => (_data?['cars'] as List?)?.where(
    (c) => c['is_active'] == true || c['is_active'] == 1
  ).length ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('🚗 ', style: TextStyle(fontSize: 20)),
            Text('ProRent', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () { setState(() => _loading = true); _loadDashboard(); },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(),
                  SizedBox(height: 16),
                  _buildActionGrid(),
                  SizedBox(height: 16),
                  _buildCarsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('🚙', '${_activeCars()}', 'В работе'),
            _statItem('📊', '${(_data?['cars'] as List?)?.length ?? 0}', 'Всего авто'),
            _statItem('💰', '...', 'Сегодня'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 28)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(child: _actionCard(Icons.speed, 'Пробег', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddMileageScreen(api: _api)));
        })),
        SizedBox(width: 12),
        Expanded(child: _actionCard(Icons.attach_money, 'Оплата', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsScreen(api: _api)));
        })),
        SizedBox(width: 12),
        Expanded(child: _actionCard(Icons.directions_car, 'Авто', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CarsScreen(api: _api)));
        })),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarsList() {
    final cars = (_data?['cars'] as List?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Автомобили', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...cars.map((car) => Card(
          child: ListTile(
            leading: Text('🚙', style: TextStyle(fontSize: 28)),
            title: Text(car['name'] ?? 'Без имени'),
            subtitle: Text('Пробег: ${car['last_mileage'] ?? 0} км'),
            trailing: Icon(Icons.chevron_right),
          ),
        )),
        if (cars.isEmpty)
          Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Нет автомобилей. Добавьте через API.')))),
      ],
    );
  }
}