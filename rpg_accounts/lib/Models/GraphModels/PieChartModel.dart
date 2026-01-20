class PieChartData {
  final double total;
  final double cost;
  final double profit;

  PieChartData({
    required this.total,
    required this.cost,
    required this.profit,
  });

  factory PieChartData.fromJson(Map<String, dynamic> json) {
    return PieChartData(
      total: double.parse(json['total'].toString()),
      cost: double.parse(json['cost'].toString()),
      profit: double.parse(json['profit'].toString()),
    );
  }
}
