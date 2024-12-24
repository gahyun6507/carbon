import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carbon_footprint/models/PigeonUserDetails.dart';  // PigeonUserDetails 파일을 가져옵니다.

class RecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('carbon_emissions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('저장된 기록이 없습니다.'));
        }

        // 데이터 출력해서 타입 확인
        snapshot.data!.docs.forEach((doc) {
          print("Document Data: ${doc.data()}");  // 데이터 확인용 로그
        });

        final records = snapshot.data!.docs.map((doc) {
          // Firestore에서 데이터를 Map<String, dynamic>으로 가져와 PigeonUserDetails로 변환
          try {
            return PigeonUserDetails.fromMap(doc.data() as Map<String, dynamic>);
          } catch (e) {
            print("Error converting document: $e");
            return null;
          }
        }).toList();

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];

            // null check
            if (record == null) {
              return ListTile(title: Text("데이터 변환 오류"));
            }

            return ListTile(
              title: Text(
                'Electricity: ${record.electricity}, Gas: ${record.gas}, Transportation: ${record.transportation}, '
                    'Waste: ${record.waste}, Water: ${record.water}',
              ),
              subtitle: Text('Housing: ${record.housingType}\nDate: ${record.createdAt}'),
            );
          },
        );
      },
    );
  }
}
