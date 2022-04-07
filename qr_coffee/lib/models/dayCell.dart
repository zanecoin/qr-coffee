class DayCell {
  DayCell({
    required this.date,
    required this.lastUpdated,
    required this.numOfOrders,
    required this.totalIncome,
    required this.items,
    required this.states,
  });

  final String date;
  final String lastUpdated;
  final int numOfOrders;
  final int totalIncome;
  final Map<dynamic, dynamic> items;
  final Map<dynamic, dynamic> states;

  factory DayCell.initialData() {
    return DayCell(
        date: '', lastUpdated: '', numOfOrders: 0, totalIncome: 0, items: Map(), states: Map());
  }
}
