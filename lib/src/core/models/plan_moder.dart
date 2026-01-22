class PlanModel {
  final String name;
  final double price;
  final String benefit;
  final bool popular;

  PlanModel({
    required this.name,
    required this.price,
    required this.benefit,
    this.popular = false,
  });
}
