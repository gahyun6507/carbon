// 친환경 팁 제공
// lib/widgets/eco_tips_widget.dart
import 'package:flutter/material.dart';
import '../models/eco_tips.dart';

class EcoTipsWidget extends StatelessWidget {
  final double carbonFootprint;

  const EcoTipsWidget({Key? key, required this.carbonFootprint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recommendedTips = EcoTipsManager.getRecommendedTips(carbonFootprint);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '맞춤형 친환경 팁',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]
              ),
            ),
            ...recommendedTips.map((tip) => ListTile(
              title: Text(tip.title),
              subtitle: Text(tip.description),
              leading: Icon(Icons.eco, color: Colors.green),
            )).toList(),
          ],
        ),
      ),
    );
  }
}