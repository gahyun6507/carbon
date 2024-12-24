import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('carbon_emissions');

  // 데이터 추가 함수
  Future<void> addCarbonEmissionData(Map<String, dynamic> data) async {
    try {
      await _collection.add(data);
      print("Data added successfully");
    } catch (e) {
      print("Error adding data: $e");
    }
  }

  // 특정 날짜의 데이터 조회 함수
  Future<List<Map<String, dynamic>>> getCarbonEmissionsByDate(String date) async {
    try {
      final querySnapshot =
      await _collection.where('recorded_date', isEqualTo: date).get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error retrieving data: $e");
      return [];
    }
  }
}
