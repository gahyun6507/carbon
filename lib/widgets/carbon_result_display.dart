import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carbon_footprint/screens/home_screen.dart'; // 홈 화면 import

import '../widgets/eco_tips_widget.dart'; // EcoTipsWidget 가져오기

class CarbonResultDisplay extends StatelessWidget {
  final double totalEmissions;

  const CarbonResultDisplay({Key? key, required this.totalEmissions})
      : super(key: key);

  Future<void> _saveToFirestore() async {
    final collection = FirebaseFirestore.instance.collection('carbon_records');
    await collection.add({
      'emissions': totalEmissions,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결과 화면'),
        backgroundColor: Colors.teal, // AppBar 색상을 teal로 설정
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '총 탄소 배출량',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalEmissions.toStringAsFixed(2)} kg CO2',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveToFirestore,
                  child: Text('Firestore에 저장'),
                ),
                SizedBox(height: 20), // 탄소 배출량과 팁 사이의 간격
                EcoTipsWidget(carbonFootprint: totalEmissions), // 친환경 팁 위젯 추가
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 홈 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('홈으로'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
