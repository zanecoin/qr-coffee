import 'package:flutter/material.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';

class CustomPlaceDropdown extends StatelessWidget {
  CustomPlaceDropdown(
    this.places,
    this.filter,
    this.callback,
    this.savedPlace,
  );

  final List<Place> places;
  final bool filter;
  final Function callback;
  final String? savedPlace;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    List<Place> filteredPlaces = [];
    String? currentPlace;

    if (filter) {
      for (var place in places) {
        if (place.active) {
          filteredPlaces.add(place);
        }
      }
    } else {
      for (var place in places) {
        filteredPlaces.add(place);
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: deviceWidth > kDeviceUpperWidthTreshold
          ? Responsive.width(60, context)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                hint: Text(
                  filteredPlaces.length > 0
                      ? CzechStrings.choosePlace
                      : CzechStrings.noPlace,
                ),
                value: currentPlace,
                items: filteredPlaces.map((place) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: place.active
                              ? (filter ? Colors.black : Colors.grey)
                              : (filter ? Colors.grey : Colors.black),
                        ),
                        Text(
                          place.address.length <
                                  Responsive.textTreshold(context)
                              ? ' ${place.address}'
                              : ' ${place.address.substring(0, Responsive.textTreshold(context))}...',
                          style: TextStyle(
                            color: place.active
                                ? (filter ? Colors.black : Colors.grey)
                                : (filter ? Colors.grey : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    value: place.address,
                  );
                }).toList(),
                onChanged: (val) {
                  currentPlace = val.toString();
                  callback(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
