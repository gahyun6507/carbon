import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carbon_footprint/services/household_service.dart';
import 'package:carbon_footprint/screens/home_screen.dart';

class HouseholdResultDisplay extends StatefulWidget {
  @override
  _HouseholdResultDisplayState createState() => _HouseholdResultDisplayState();
}

class _HouseholdResultDisplayState extends State<HouseholdResultDisplay> {
  final HouseholdService _householdService = HouseholdService();
  bool _showBarChart = false;

  // 이산화탄소 계산 함수
  double _calculateCO2(double usage, double factor) {
    return usage * factor;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // 각 자원별 이산화탄소 발생량 계산
    final double electricityCO2 = _calculateCO2(data['electricity']?.toDouble() ?? 0, 0.4781);
    final double gasCO2 = _calculateCO2(data['gas']?.toDouble() ?? 0, 2.176);
    final double waterCO2 = _calculateCO2(data['water']?.toDouble() ?? 0, 0.237);
    final double transportationCO2 = _calculateCO2(data['transportation']?.toDouble() ?? 0, 2.097 / 16.04);  // 휘발유 이동 거리 기반 계산
    final double wasteCO2 = _calculateCO2(data['waste']?.toDouble() ?? 0, 0.557);

    final double totalCO2 = electricityCO2 + gasCO2 + waterCO2 + transportationCO2 + wasteCO2;
    final double totalUsage = data['electricity']?.toDouble() ?? 0 + data['gas']?.toDouble() ?? 0 + data['water']?.toDouble() ?? 0 + data['transportation']?.toDouble() ?? 0 + data['waste']?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('사용량 분석 결과'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 원형 차트
              if (!_showBarChart)
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(data, totalUsage),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),

              // 막대 그래프
              if (_showBarChart)
                Text('이산화탄소 배출 현황 및 목표 비교',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              if (_showBarChart)
                SizedBox(height: 10),
              if (_showBarChart)
                StreamBuilder<QuerySnapshot>(
                  stream: _householdService.getHouseholdData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('그래프를 그릴 데이터가 없습니다.'));
                    }

                    final records = snapshot.data!.docs;

                    return SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barGroups: _buildBarChartGroups(records),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('우리집');
                                    case 1:
                                      return Text('다른집');
                                    case 2:
                                      return Text('목표');
                                    default:
                                      return Text('');
                                  }
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    );
                  },
                ),

              // 사용량 텍스트
              SizedBox(height: 20),
              Text('주거 형태: ${data['housingType']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),

              // 이산화탄소 배출량
              Text('이산화탄소 배출량 (kg):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 10),
              _buildCO2Result('전기: ${electricityCO2.toStringAsFixed(2)} kg', Colors.blue),
              _buildCO2Result('가스: ${gasCO2.toStringAsFixed(2)} kg', Colors.green),
              _buildCO2Result('수도: ${waterCO2.toStringAsFixed(2)} kg', Colors.orange),
              _buildCO2Result('교통: ${transportationCO2.toStringAsFixed(2)} kg', Colors.red),
              _buildCO2Result('폐기물: ${wasteCO2.toStringAsFixed(2)} kg', Colors.purple),
              SizedBox(height: 10),
              Text('총 이산화탄소 배출량: ${totalCO2.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),

              // 버튼
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);  // 이전 화면으로 이동
                    },
                    child: Text('이전'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()), // 홈 화면으로 이동
                      );
                    },
                    child: Text('홈으로'),
                  ),
                  if (!_showBarChart)
                    SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showBarChart = true;  // 막대 그래프 보기로 전환
                      });
                    },
                    child: Text('다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageResult(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCO2Result(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, dynamic> data, double totalUsage) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: (data['electricity']?.toDouble() ?? 0) / totalUsage * 100,
        title: '전기 ${(data['electricity']?.toDouble() ?? 0).toStringAsFixed(2)} kWh',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: (data['gas']?.toDouble() ?? 0) / totalUsage * 100,
        title: '가스 ${(data['gas']?.toDouble() ?? 0).toStringAsFixed(2)} m³',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: (data['water']?.toDouble() ?? 0) / totalUsage * 100,
        title: '수도 ${(data['water']?.toDouble() ?? 0).toStringAsFixed(2)} m³',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: (data['transportation']?.toDouble() ?? 0) / totalUsage * 100,
        title: '교통 ${(data['transportation']?.toDouble() ?? 0).toStringAsFixed(2)} km',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: (data['waste']?.toDouble() ?? 0) / totalUsage * 100,
        title: '폐기물 ${(data['waste']?.toDouble() ?? 0).toStringAsFixed(2)} kg',
        radius: 50,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }



  BarChartData _buildBarChartData(List<QueryDocumentSnapshot<Object?>> records) {
    return BarChartData(
      barGroups: _buildBarChartGroups(records),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,  // 제목 공간을 확보하기 위해 reservedSize 추가
            getTitlesWidget: (value, meta) {
              // x 값에 따라 제목을 다르게 표시
              switch (value.toInt()) {
                case 0:
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '우리집',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                case 1:
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '다른집',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                case 2:
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '목표',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                default:
                  return Container();  // 기본적으로 빈 컨테이너 반환
              }
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: false),
    );
  }

  List<BarChartGroupData> _buildBarChartGroups(List<QueryDocumentSnapshot<Object?>> records) {
    final double ourHouse = records[0]['electricity']?.toDouble() ?? 0;
    final double otherHouse = records[1]['electricity']?.toDouble() ?? 0;
    final double goal = records[2]['electricity']?.toDouble() ?? 0;

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(toY: ourHouse, color: Colors.blue, width: 20),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(toY: otherHouse, color: Colors.green, width: 20),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(toY: goal, color: Colors.purple, width: 20),
        ],
      ),
    ];
  }

}
