import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp 사용을 위해 추가

class PigeonUserDetails {
  final double electricity;
  final double gas;
  final double transportation;
  final double waste;
  final double water;
  final String housingType;
  final String createdAt;

  // 생성자
  PigeonUserDetails({
    required this.electricity,
    required this.gas,
    required this.transportation,
    required this.waste,
    required this.water,
    required this.housingType,
    required this.createdAt,
  });

  // Firestore에서 데이터를 Map 형태로 받아와서 PigeonUserDetails 객체로 변환하는 팩토리 메서드
  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      electricity: map['electricity'] ?? 0.0,
      gas: map['gas'] ?? 0.0,
      transportation: map['transportation'] ?? 0.0,
      waste: map['waste'] ?? 0.0,
      water: map['water'] ?? 0.0,
      housingType: map['housingType'] ?? 'Unknown',
      createdAt: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate().toString() // Timestamp를 DateTime으로 변환
          : 'Unknown Date',
    );
  }
}
