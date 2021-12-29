import 'package:flutter/material.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';

class CustomPlaceDropdown extends StatefulWidget {
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
  State<CustomPlaceDropdown> createState() => _CustomPlaceDropdownState();
}

class _CustomPlaceDropdownState extends State<CustomPlaceDropdown> {
  String? currentPlace;

  @override
  void initState() {
    super.initState();
    currentPlace = widget.savedPlace;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    List<Place> filteredPlaces = [];

    if (widget.filter) {
      for (var place in widget.places) {
        if (place.active) {
          filteredPlaces.add(place);
        }
      }
    } else {
      for (var place in widget.places) {
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
                              ? (widget.filter ? Colors.black : Colors.grey)
                              : (widget.filter ? Colors.grey : Colors.black),
                        ),
                        Text(
                          place.address.length <
                                  Responsive.textTreshold(context)
                              ? ' ${place.address}'
                              : ' ${place.address.substring(0, Responsive.textTreshold(context))}...',
                          style: TextStyle(
                            color: place.active
                                ? (widget.filter ? Colors.black : Colors.grey)
                                : (widget.filter ? Colors.grey : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    value: place.address,
                  );
                }).toList(),
                onChanged: (val) {
                  currentPlace = val.toString();
                  widget.callback(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
