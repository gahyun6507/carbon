import 'package:flutter/material.dart';
import 'package:carbon_footprint/services/carbon_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CarbonService _carbonService = CarbonService();

Future<void> saveData(BuildContext context) async {
  // 로딩 상태 표시
  showDialog(
    context: context,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  final data = {
    "recorded_date": "2024-12-07",
    "source": "Vehicle",
    "emission_type": "CO₂",
    "quantity": 18.4,
    "unit": "ton",
    "location": {
      "city": "Seoul",
      "country": "South Korea",
      "coordinates": {
        "latitude": 37.5665,
        "longitude": 126.9780
      }
    },
    "category": "Transportation",
    "metadata": {
      "created_by": "admin",
      "created_at": Timestamp.now(),
      "last_updated": Timestamp.now()
    }
  };

  try {
    // 데이터 저장
    await _carbonService.addCarbonEmissionData(data);
    // 데이터가 성공적으로 저장되었음을 출력
    print("데이터가 성공적으로 저장되었습니다.");

    // 저장 성공 메시지 (Snackbar 등으로 사용자에게 피드백)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터가 성공적으로 저장되었습니다.')));
  } catch (e) {
    print("데이터 저장 중 오류가 발생했습니다: $e");
    // 오류 발생 시 메시지 출력 (Snackbar 등으로 사용자에게 피드백)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 저장 중 오류가 발생했습니다: $e')));
  } finally {
    // 로딩 화면 닫기
    Navigator.of(context).pop();
  }
}
