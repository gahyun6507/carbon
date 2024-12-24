import 'package:cloud_firestore/cloud_firestore.dart';

class HouseholdService {
  final CollectionReference _householdCollection =
  FirebaseFirestore.instance.collection('household');

  // 데이터 저장
  Future<void> saveHouseholdData({
    required double electricity,
    required double gas,
    required double water,
    required double transportation,
    required double waste,
    required String housingType,
  }) async {
    try {
      await _householdCollection.add({
        'electricity': electricity,
        'gas': gas,
        'water': water,
        'transportation': transportation,
        'waste': waste,
        'housingType': housingType,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Household data saved successfully');
    } catch (e) {
      print('Error saving household data: $e');
    }
  }

  // 데이터 가져오기
  Stream<QuerySnapshot> getHouseholdData() {
    return _householdCollection.orderBy('timestamp', descending: true).snapshots();
  }
}
