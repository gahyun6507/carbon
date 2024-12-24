import 'package:flutter/material.dart';
import 'package:carbon_footprint/services/household_service.dart';

class HouseholdInputScreen extends StatefulWidget {
  @override
  _HouseholdInputScreenState createState() => _HouseholdInputScreenState();
}

class _HouseholdInputScreenState extends State<HouseholdInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _householdService = HouseholdService();

  double _electricity = 0.0;
  double _gas = 0.0;
  double _water = 0.0;
  double _transportation = 0.0;
  double _waste = 0.0;
  String _housingType = '아파트'; // 기본값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가정용 탄소발자국 계산기'),
        backgroundColor: Colors.green, // 앱바 색상 변경
        centerTitle: true, // 앱바 제목 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(
                label: '전기 사용량 (kWh/월)',
                icon: Icons.flash_on,
                onSaved: (value) => _electricity = double.parse(value ?? '0'),
              ),
              _buildInputField(
                label: '가스 사용량 (m³/월)',
                icon: Icons.local_gas_station,
                onSaved: (value) => _gas = double.parse(value ?? '0'),
              ),
              _buildInputField(
                label: '수도 사용량 (m³/월)',
                icon: Icons.water_drop,
                onSaved: (value) => _water = double.parse(value ?? '0'),
              ),
              _buildInputField(
                label: '교통 (km/월)',
                icon: Icons.directions_car,
                onSaved: (value) => _transportation = double.parse(value ?? '0'),
              ),
              _buildInputField(
                label: '폐기물 (L/월)',
                icon: Icons.delete,
                onSaved: (value) => _waste = double.parse(value ?? '0'),
              ),
              _buildDropdown(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _householdService.saveHouseholdData(
                      electricity: _electricity,
                      gas: _gas,
                      water: _water,
                      transportation: _transportation,
                      waste: _waste,
                      housingType: _housingType,
                    );
                    Navigator.pushNamed(context, '/householdResult', arguments: {
                      'electricity': _electricity,
                      'gas': _gas,
                      'water': _water,
                      'transportation': _transportation,
                      'waste': _waste,
                      'housingType': _housingType,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // 버튼 배경색
                  padding: EdgeInsets.symmetric(vertical: 15), // 버튼 여백
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 둥근 버튼
                  ),
                ),
                child: Text(
                  '다음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 입력 필드 공통 스타일
  Widget _buildInputField({required String label, required IconData icon, required FormFieldSetter<String> onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green), // 아이콘 추가
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // 둥근 테두리
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label은 필수 항목입니다.';
          }
          return null;
        },
      ),
    );
  }

  // 드롭다운 선택 필드
  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _housingType,
        items: ['아파트', '단독주택', '빌라']
            .map((type) => DropdownMenuItem(
          value: type,
          child: Text(type),
        ))
            .toList(),
        onChanged: (value) => setState(() => _housingType = value!),
        decoration: InputDecoration(
          labelText: '주거 형태',
          prefixIcon: Icon(Icons.home, color: Colors.green), // 아이콘 추가
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // 둥근 테두리
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }
}
