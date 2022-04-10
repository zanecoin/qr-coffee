import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/shared/functions.dart';

List<DayCell> syncCells(List<DayCell> dayCells, List<String> dates) {
  List<DayCell> syncedCells = [];
  bool included;
  DayCell includedCell = DayCell.initialData();

  for (String date in dates) {
    included = false;
    for (DayCell dayCell in dayCells) {
      if (date == dayCell.date) {
        included = true;
        includedCell = dayCell;
      }
    }
    if (included) {
      syncedCells.add(includedCell);
    } else {
      syncedCells.add(DayCell.initialData());
    }
  }

  return syncedCells;
}

List<String> getRawDates(List<DayCell> dayCells) {
  String firstDay = dayCells[0].date;
  String lastDay = dayCells.last.date;

  List<String> dates = getDateList(
    firstDay.substring(8, 10),
    firstDay.substring(5, 7),
    lastDay.substring(8, 10),
    lastDay.substring(5, 7),
    firstDay.substring(0, 4),
  );

  return dates;
}

List<String> getFormattedDates(List<String> dates) {
  for (int i = 0; i < dates.length; i++) {
    dates[i] = '${dates[i].substring(8, 10)}. ${dates[i].substring(5, 7)}. ';
  }

  return dates;
}

List<String> getDateList(String day1, String month1, String day2, String month2, String year) {
  List<String> dateList = [];
  int dayNum = int.parse(day1);
  int monthNum = int.parse(month1);

  int dayNumFinal = int.parse(day2);
  int monthNumFinal = int.parse(month2);

  String monthType = '';
  bool calculate = true;

  while (calculate) {
    if (dayNum == dayNumFinal && monthNum == monthNumFinal) {
      calculate = false;
    }
    String dayString;
    String monthString;
    if (dayNum < 10) {
      dayString = '0$dayNum';
    } else {
      dayString = '$dayNum';
    }
    if (monthNum < 10) {
      monthString = '0$monthNum';
    } else {
      monthString = '$monthNum';
    }
    dateList.add('${year}_${monthString}_${dayString}');

    monthType = 'feb';
    if (monthNum == 1 ||
        monthNum == 3 ||
        monthNum == 5 ||
        monthNum == 7 ||
        monthNum == 8 ||
        monthNum == 10 ||
        monthNum == 12) {
      monthType = 'long';
    }
    if (monthNum == 4 || monthNum == 6 || monthNum == 9 || monthNum == 11) {
      monthType = 'short';
    }
    if ((monthType == 'long' && dayNum == 31) ||
        (monthType == 'short' && dayNum == 30) ||
        (monthType == 'feb' && dayNum == 28)) {
      monthNum++;
      dayNum = 1;
    } else {
      dayNum++;
    }
  }
  return dateList;
}
