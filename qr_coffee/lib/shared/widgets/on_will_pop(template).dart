import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class OnWillPopTemplate extends StatefulWidget {
  const OnWillPopTemplate({Key? key}) : super(key: key);

  @override
  _OnWillPopTemplateState createState() => _OnWillPopTemplateState();
}

class _OnWillPopTemplateState extends State<OnWillPopTemplate> {
  bool show = true;
  // BACK BUTTON BEHAVIOR
  Future<bool> _onWillPop() async {
    if (show == true) {
      return true;
    } else {
      _showSnackbar();
      return false;
    }
  }

  _showSnackbar() {
    customSnackbar(context: context, text: CzechStrings.waitForIt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        title: Text(CzechStrings.stats),
        function: show ? null : _showSnackbar,
      ),
      body: WillPopScope(
        onWillPop: () async => _onWillPop(),
        child: Container(),
      ),
    );
  }
}
