import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Pie Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PieChartScreen(),
    );
  }
}

class PieChartScreen extends StatelessWidget {
  const PieChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Pie Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.2,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('householdData').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('데이터가 없습니다.'));
              }

              // Firestore에서 첫 번째 문서의 데이터를 가져옴
              final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

              // 데이터의 총합 계산
              final total = (data['electricity'] ?? 0) +
                  (data['gas'] ?? 0) +
                  (data['water'] ?? 0) +
                  (data['transportation'] ?? 0) +
                  (data['waste'] ?? 0);

              if (total == 0) {
                return const Center(child: Text('데이터 총합이 0입니다.'));
              }

              return PieChart(
                PieChartData(
                  sections: _buildPieChartSections(data, total),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, dynamic> data, double total) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: (data['electricity'] ?? 0) / total * 100,
        title: '전기',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: (data['gas'] ?? 0) / total * 100,
        title: '가스',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: (data['water'] ?? 0) / total * 100,
        title: '수도',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: (data['transportation'] ?? 0) / total * 100,
        title: '교통',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: (data['waste'] ?? 0) / total * 100,
        title: '폐기물',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}
