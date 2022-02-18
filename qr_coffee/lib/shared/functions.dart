import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:qr_coffee/shared/strings.dart';

String cutTextIfNeccessary(String text, int treshold) {
  return text.length < treshold ? text : '${text.substring(0, treshold)}...';
}

Future<List<Map<String, dynamic>>> loadImages(String folder) async {
  List<Map<String, dynamic>> files = [];

  final ListResult result = await FirebaseStorage.instance.ref(folder).list();
  final List<Reference> allFiles = result.items;

  await Future.forEach<Reference>(allFiles, (file) async {
    final String fileUrl = await file.getDownloadURL();
    files.add({
      'url': fileUrl,
      'path': file.fullPath,
    });
  });
  return files;
}

String chooseUrl(List<Map<String, dynamic>> addresses, String picturePath) {
  String url = '';
  for (var address in addresses) {
    if (address['path'] == picturePath) {
      url = address['url'];
    }
  }
  return url;
}

String timeFormatter(String time) {
  // PARAMS: time in format 'yyyyMMddHHmmss'
  // RETURN: time in format 'HH:mm • dd.MM.yyyy'
  return '${time.substring(8, 10)}:${time.substring(10, 12)} • ${time.substring(6, 8)}.${time.substring(4, 6)}.${time.substring(0, 4)}';
}

int getTotalPrice(List<Product> items, selectedItems) {
  // PARAMS: [items] - all items from database, [selectedItems] - all items selected by user
  // RETURN: [price] - total order price
  int price = 0;
  for (var item in selectedItems) {
    for (var product in items) {
      if (product.name == item.name) price += product.price;
    }
  }
  return price;
}

List<String> getStringList(selectedItems) {
  // PARAMS: [selectedItems] - all items selected by user
  // RETURN: [result] - string list of items selected by user
  List<String> result = [];
  for (var item in selectedItems) {
    result.add(item.name);
  }
  result.sort();
  return result;
}

// IS INPUT INT?
bool isNumeric(String str) {
  bool result = true;
  try {
    int.parse(str);
  } catch (e) {
    result = false;
  }
  return result;
}

String getPickUpTime(double plusTime) {
  // PARAMS: [plusTime] - time that user wants to pick up his order (in minutes)
  // RETURN: [futureTime] - present time + user time (in format yyyyMMddHHmmss)
  String presentTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
  String futureTime = '';
  String augumentMinutes = (int.parse(presentTime.substring(10, 12)) + plusTime.toInt()).toString();

  if (int.parse(augumentMinutes) >= 60) {
    String hourUp = (int.parse(presentTime.substring(8, 10)) + 1).toString();

    if (hourUp == '24') {
      hourUp = '00';
    }
    augumentMinutes = (int.parse(augumentMinutes) - 60).toString();
    if (hourUp.length == 1) {
      hourUp = '0$hourUp';
    }
    if (augumentMinutes.length == 1) {
      augumentMinutes = '0$augumentMinutes';
    }

    futureTime =
        '${presentTime.substring(0, 8)}${hourUp}${augumentMinutes}${presentTime.substring(12, 14)}';
  } else {
    if (augumentMinutes.length == 1) {
      augumentMinutes = '0$augumentMinutes';
    }

    futureTime =
        '${presentTime.substring(0, 10)}${augumentMinutes}${presentTime.substring(12, 14)}';
  }

  return futureTime;
}

List<dynamic> getRemainingTime(Order order, String time) {
  /// PARAMS: [time] - current time; [order] - current order
  /// RETURN: [result] - formatted time based on when user created the order, [color] - color of timestamp
  String result;
  Color color;
  int m1 = int.parse(order.pickUpTime.substring(10, 12)); // minutes
  int m2 = int.parse(time.substring(10, 12));
  int h1 = int.parse(order.pickUpTime.substring(8, 10)); // date and hours
  int h2 = int.parse(time.substring(8, 10));
  int difference = int.parse(order.pickUpTime) - int.parse(time);

  if (difference > -3000) {
    result = (m1 - m2 + 60 * (h1 - h2)).toString();

    if (int.parse(result) > 2) {
      result = '${AppStringValues.pickUpIn} $result min';
      color = Colors.green.shade800;
    } else if (int.parse(result) <= 2 && int.parse(result) > -1) {
      result = '${AppStringValues.pickUpIn} $result min';
      color = Colors.yellow.shade800;
    } else {
      result = '${AppStringValues.pickUpBefore} ${-int.parse(result)} min';
      color = Colors.red.shade700;
    }
  } else {
    result = '${AppStringValues.pickUp30} min';
    color = Colors.black;
  }

  return [result, color];
}

// OBJECT TO LIST CONVERTER
// List<String> objectToList(Object object){
//   List<String> array = [];
//   for (var entry in object) {
//     if(entry is String){
//       array.add(entry);
//     }
//   }
//   return array;
// }

// CURRENCY PARSING METHOD
String moneyFormatter(double amount) {
  List<String> stringNumber = amount.toStringAsFixed(2).split('.');
  String result;
  String temp;
  bool sign = false;

  // extract minus sign
  if (stringNumber[0][0] == '-') {
    stringNumber[0] = stringNumber[0].substring(1);
    sign = true;
  }

  // extract leading digits
  if (stringNumber[0].length > 3) // number greater than 999
  {
    if ((stringNumber[0].length - 1) % 3 == 0) {
      result = stringNumber[0].substring(0, 1) + ' ';
      temp = stringNumber[0].substring(1);
    } else if ((stringNumber[0].length - 2) % 3 == 0) {
      result = stringNumber[0].substring(0, 2) + ' ';
      temp = stringNumber[0].substring(2);
    } else if (stringNumber[0].length % 3 == 0) {
      result = '';
      temp = stringNumber[0];
    } else {
      result = '';
      temp = stringNumber[0];
    }

    // parse digit triplets
    while (temp.length > 3) {
      result = result + temp.substring(0, 3) + ' ';
      temp = temp.substring(3);
    }

    // add remaining triplet and decimal numbers
    result = result + temp + ',' + stringNumber[1];
  } else {
    // number smaller than 999
    result = stringNumber[0] + ',' + stringNumber[1];
  }

  if (sign) {
    result = '-' + result;
  }

  return result;
}

const platform = MethodChannel('cz.pankaci.qr_coffee/payment');
Future<void> getPlatformChannel() async {
  String output;

  try {
    final List<Object?> result =
        await platform.invokeMethod('flutterToNative', {"price": '1000', "name": 'John'});
    output = 'Name: ${result[0]}, price: ${result[1]} Kč.';
  } on PlatformException catch (e) {
    output = "Failed to get data: '${e.message}'.";
  }

  print(output);
}
