import 'package:flutter/material.dart';
import 'package:carbon_footprint/services/carbon_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp 오류 수정
import 'package:carbon_footprint/widgets/carbon_input_form.dart';
import 'package:carbon_footprint/widgets/carbon_result_display.dart'; // 결과 화면 import

final CarbonService _carbonService = CarbonService();

class PersonalInputScreen extends StatefulWidget {
  @override
  _PersonalInputScreenState createState() => _PersonalInputScreenState();
}

class _PersonalInputScreenState extends State<PersonalInputScreen> {
  bool _isLoading = false;
  String _selectedTransport = '자동차';
  final _distanceController = TextEditingController();
  final _youtubeController = TextEditingController(); // 유튜브 시청시간 컨트롤러 추가
  List<String> _selectedFoods = [];

  // 단계별 질문을 위한 변수
  int _currentStep = 0;
  String _selectedBreakfast = '';
  String _selectedTransportMethod = '';
  double _selectedTime = 0.0;
  double _youtubeTime = 0.0; // 유튜브 시청시간 변수 추가

  // 각 음식에 대한 탄소 배출량 설정 (kg CO₂)
  Map<String, double> foodCarbonEmissions = {
    '밥': 0.5,
    '죽': 0.3,
    '시리얼': 0.4,
    '빵': 0.6,
    '우유': 0.9,
    '패스트푸드': 1.2,
    '고기': 3.0,
    '사과': 0.1,
    '계란': 0.6,
    '안먹었어요': 0.0,
  };

  // 각 교통수단에 따른 탄소 배출량 설정 (kg CO₂ per km)
  Map<String, double> transportCarbonEmissions = {
    '자동차': 0.1,
    '도보': 0.0,
    '지하철': 0.05,
    '버스': 0.2,
    '자전거': 0.0,
  };

  void saveData(double distance, double youtubeTime, double foodCarbon, double transportCarbon) async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      "recorded_date": "2024-12-07",
      "source": _selectedTransportMethod,
      "emission_type": "CO₂",
      "quantity": (distance * transportCarbon) + (youtubeTime * 0.0083) + foodCarbon, // 모든 배출량 합산
      "unit": "kg",
      "location": {
        "city": "Seoul",
        "country": "South Korea",
        "coordinates": {
          "latitude": 37.5665,
          "longitude": 126.9780
        }
      },
      "category": "Personal",
      "metadata": {
        "created_by": "admin",
        "created_at": Timestamp.now(),
        "last_updated": Timestamp.now()
      }
    };

    try {
      await _carbonService.addCarbonEmissionData(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("데이터가 성공적으로 저장되었습니다."),
        backgroundColor: Colors.green,
      ));
      // 저장 후 결과 화면으로 라우팅
      double totalEmissions = (distance * transportCarbon) + (youtubeTime * 0.0083) + foodCarbon;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarbonResultDisplay(totalEmissions: totalEmissions),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("데이터 저장 중 오류가 발생했습니다: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      // 마지막 단계에서 데이터 저장
      double distance = double.tryParse(_distanceController.text) ?? 0.0;
      double foodCarbon = foodCarbonEmissions[_selectedBreakfast] ?? 0.0;
      saveData(distance, _youtubeTime, foodCarbon, transportCarbonEmissions[_selectedTransportMethod] ?? 0.0);
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("개인용 탄소발자국 계산기"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "탄소 배출량을 계산해보세요!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              // Step에 따라 질문을 다르게 표시
              if (_currentStep == 0) ...[
                Text("식사 메뉴는 무엇입니까?"),
                // 아침 메뉴 선택 (아이콘 선택)
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true, // 크기 조정
                  physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    _buildFoodOption(Icons.rice_bowl, '밥'),
                    _buildFoodOption(Icons.soup_kitchen, '죽'),
                    _buildFoodOption(Icons.local_cafe, '시리얼'),
                    _buildFoodOption(Icons.breakfast_dining, '빵'),
                    _buildFoodOption(Icons.local_drink, '우유'),
                    _buildFoodOption(Icons.fastfood, '패스트푸드'),
                    _buildFoodOption(Icons.restaurant, '고기'),
                    _buildFoodOption(Icons.apple, '사과'),
                    _buildFoodOption(Icons.egg, '계란'),
                    _buildFoodOption(Icons.clear_all, '안먹었어요'),
                  ],
                ),
              ] else if (_currentStep == 1) ...[
                Text("교통수단은 무엇입니까?"),
                // 교통수단 선택 (아이콘 선택)
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true, // 크기 조정
                  physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    _buildTransportOption(Icons.directions_car, '자동차'),
                    _buildTransportOption(Icons.directions_walk, '도보'),
                    _buildTransportOption(Icons.directions_subway, '지하철'),
                    _buildTransportOption(Icons.directions_bus, '버스'),
                    _buildTransportOption(Icons.directions_bike, '자전거'),
                  ],
                ),
              ] else if (_currentStep == 2) ...[
                Text("소요시간은 얼마나 소요되었나요?"),
                // 소요시간 입력 (예시로 TextField 사용)
                TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "소요시간 (분)",
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ] else if (_currentStep == 3) ...[
                Text("유튜브 시청시간은 얼마인가요?"),
                // 유튜브 시청시간 입력
                TextField(
                  controller: _youtubeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "유튜브 시청시간 (분)",
                  ),
                  onChanged: (value) {
                    setState(() {
                      _youtubeTime = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ],
              SizedBox(height: 20),
              // Step에 따라 이전/다음 버튼 변경
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: prevStep,
                      child: Text("이전"),
                    ),
                  ElevatedButton(
                    onPressed: nextStep,
                    child: Text(_currentStep == 3 ? "계산하기" : "다음"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 아침 메뉴 옵션을 생성하는 위젯
  Widget _buildFoodOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBreakfast = label;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _selectedBreakfast == label ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5)),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black), // 아이콘 크기 수정
            Text(label),
          ],
        ),
      ),
    );
  }

  // 교통수단 옵션을 생성하는 위젯
  Widget _buildTransportOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransport = label;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _selectedTransport == label ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5)),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black), // 아이콘 크기 수정
            Text(label),
          ],
        ),
      ),
    );
  }
}
