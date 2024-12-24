// lib/models/eco_tips.dart
class EcoTip {
  final String title;
  final String description;
  final double impactReduction; // kg CO2 per year
  final List<String> categories;

  EcoTip({
    required this.title,
    required this.description,
    required this.impactReduction,
    required this.categories,
  });
}

class EcoTipsManager {
  static final List<EcoTip> _allTips = [
    // 교통 관련 팁
    EcoTip(
      title: '대중교통 이용하기',
      description: '자동차 대신 버스나 지하철을 이용하면 탄소 배출을 크게 줄일 수 있어요.',
      impactReduction: 1200.0,
      categories: ['교통'],
    ),
    EcoTip(
      title: '자전거 타기',
      description: '짧은 거리는 자전거를 이용하면 건강과 환경 모두에 좋아요.',
      impactReduction: 800.0,
      categories: ['교통', '운동'],
    ),

    // 음식 관련 팁
    EcoTip(
      title: '채식 하루 늘리기',
      description: '일주일에 한 번만 채식 식단을 선택해도 탄소 배출을 줄일 수 있어요.',
      impactReduction: 600.0,
      categories: ['음식'],
    ),
    EcoTip(
      title: '로컬 푸드 선택하기',
      description: '멀리서 운송된 음식보다 지역 농산물을 선택하세요.',
      impactReduction: 350.0,
      categories: ['음식'],
    ),

    // 에너지 관련 팁
    EcoTip(
      title: '대기전력 줄이기',
      description: '사용하지 않는 전자기기의 플러그를 뽑아보세요.',
      impactReduction: 200.0,
      categories: ['에너지'],
    ),
    EcoTip(
      title: 'LED 전구 사용',
      description: '기존 전구를 에너지 효율이 높은 LED 전구로 교체하세요.',
      impactReduction: 500.0,
      categories: ['에너지'],
    ),
  ];

  static List<EcoTip> getRecommendedTips(double carbonFootprint) {
    // 탄소발자국에 따른 맞춤형 팁 추천
    if (carbonFootprint < 10) {
      return _allTips.where((tip) => tip.impactReduction < 500).toList();
    } else if (carbonFootprint < 20) {
      return _allTips.where((tip) =>
      tip.impactReduction >= 500 && tip.impactReduction < 1000
      ).toList();
    } else {
      return _allTips.where((tip) => tip.impactReduction >= 1000).toList();
    }
  }
}