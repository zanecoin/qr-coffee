
// IS INPUT INT?
//import 'dart:html';

bool isNumeric(String str) {
  bool result = true;
  try {
    int.parse(str);
  } catch (e) {
    result = false;
  }
  return result;
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
String moneyFormatter(double amount){
  List<String> stringNumber = amount.toStringAsFixed(2).split('.');
  String result;
  String temp;
  bool sign = false;
  
  // extract minus sign
  if(stringNumber[0][0] == '-'){
    stringNumber[0] = stringNumber[0].substring(1);
    sign = true;
  }

  // extract leading digits
  if(stringNumber[0].length > 3) // number greater than 999
  {
    if((stringNumber[0].length - 1) % 3 == 0)
    {
      result = stringNumber[0].substring(0,1) + ' ';
      temp = stringNumber[0].substring(1);
    } 
    else if ((stringNumber[0].length - 2) % 3 == 0)
    {
      result = stringNumber[0].substring(0,2) + ' ';
      temp = stringNumber[0].substring(2);
    } 
    else if (stringNumber[0].length % 3 == 0)
    {
      result = '';
      temp = stringNumber[0];
    }
    else
    {
      result = '';
      temp = stringNumber[0];
    }
  
    // parse digit triplets
    while(temp.length > 3){
      result = result + temp.substring(0,3) + ' ';
      temp = temp.substring(3);
    }

    // add remaining triplet and decimal numbers
    result = result + temp + ',' + stringNumber[1];
  }
  else { // number smaller than 999
    result = stringNumber[0] + ',' + stringNumber[1];
  }

  if(sign){
    result = '-' + result;
  }

  return result;
}