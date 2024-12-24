// lib/models/carbon_calculator.dart
class CarbonCalculator {
  static double calculateTransport(String mode, double distance) {
    final Map<String, double> emissionFactors = {
      '자동차': 0.192,
      '대중교통': 0.089,
      '자전거/도보': 0.0
    };
    return (emissionFactors[mode] ?? 0.0) * distance;
  }

  static double calculateFood(List<String> foods) {
    final Map<String, double> foodEmissions = {
      '고기': 6.61,
      '채소': 2.89,
      '과일': 1.34,
      '우유': 3.15
    };
    return foods.fold(0.0, (total, food) => total + (foodEmissions[food] ?? 0.0));
  }

  static double calculateTotal(double transport, double food) {
    return transport + food;
  }
}