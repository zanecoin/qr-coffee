import 'package:provider/provider.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class Credits extends StatefulWidget {
  @override
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> with TickerProviderStateMixin {
  late AnimationController _controller;
  final _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  late Customer customer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
  }

  Future<void> _playAnimation() async {
    try {
      customer.updateCredits(customer.credits + 1);
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because it was disposed of
    }
  }

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder<Customer>(
      stream: CustomerDatabase(userID: userFromAuth!.userID).customer,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          customer = snapshot.data!;

          return Scaffold(
            backgroundColor: themeProvider.themeData().backgroundColor,
            appBar: customAppBar(context,
                title: Text(
                  AppStringValues.myCredits,
                  style: TextStyle(color: themeProvider.themeAdditionalData().textColor),
                )),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0),
                    width:
                        Responsive.isLargeDevice(context) ? Responsive.width(60.0, context) : null,
                    child: Form(
                      key: _key,
                      child: CustomTextField(
                        AppStringValues.promoCode,
                        Icons.card_giftcard,
                        _callbackForm,
                        validation: noValidation,
                      ),
                    ),
                  ),
                  CustomOutlinedIconButton(
                    function: _triggerSnackBar,
                    icon: Icons.done,
                    label: AppStringValues.applyCode,
                    iconColor: Colors.green,
                  ),
                  SizedBox(height: Responsive.width(50.0, context)),
                  Column(
                    children: [
                      Container(
                        child: Center(
                            child: TokenTable(
                          controller: _controller,
                          customer: customer,
                          function: _playAnimation,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  void _callbackForm(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  _triggerSnackBar() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      if (formField[AppStringValues.promoCode] == 'qrcoffee') {
        try {
          customer.updateCredits(customer.credits + 250);
        } catch (e) {
          customSnackbar(context: context, text: e.toString());
        }
      } else {
        customSnackbar(context: context, text: AppStringValues.codeInvalid);
      }
    }
  }
}

class TokenTable extends StatelessWidget {
  TokenTable({Key? key, required this.controller, required this.customer, required this.function})
      : width1 = Tween<double>(begin: 260.0, end: 255.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.250, curve: Curves.easeInExpo),
          ),
        ),
        height1 = Tween<double>(begin: 160.0, end: 155.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.250, curve: Curves.easeInExpo),
          ),
        ),
        width2 = Tween<double>(begin: 240.0, end: 235.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.250, curve: Curves.easeInExpo),
          ),
        ),
        height2 = Tween<double>(begin: 140.0, end: 135.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.250, curve: Curves.easeInExpo),
          ),
        ),
        fontsize = Tween<double>(begin: 35.0, end: 33.5).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.250, curve: Curves.easeInExpo),
          ),
        ),
        super(key: key);

  final Customer customer;
  final Function function;
  final AnimationController controller;
  final Animation<double> width1;
  final Animation<double> height1;
  final Animation<double> width2;
  final Animation<double> height2;
  final Animation<double> fontsize;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: width1.value,
      height: height1.value,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
        shape: BoxShape.rectangle,
        boxShadow: [
          themeProvider.isLightMode()
              ? BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(10.0, 10.0),
                  blurRadius: 15.0,
                  spreadRadius: 5.0)
              : BoxShadow(),
        ],
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isLightMode() ? kGold : kSilver,
            stops: [0.1, 0.3, 0.8, 1]),
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
        onTap: () => function(),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            width: width2.value,
            height: height2.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '< ${AppStringValues.app_name} >',
                  style: TextStyle(
                    color: themeProvider.isLightMode()
                        ? Color.fromARGB(255, 148, 101, 0)
                        : Color.fromARGB(255, 60, 60, 70),
                    fontSize: 5.0,
                  ),
                ),
                Text(
                  '${customer.credits} CR',
                  style: TextStyle(
                    color: themeProvider.isLightMode()
                        ? Color.fromARGB(255, 148, 101, 0)
                        : Color.fromARGB(255, 60, 60, 70),
                    fontSize: fontsize.value,
                  ),
                ),
                Text(
                  '< ${AppStringValues.app_name} >',
                  style: TextStyle(
                    color: themeProvider.isLightMode()
                        ? Color.fromARGB(255, 148, 101, 0)
                        : Color.fromARGB(255, 60, 60, 70),
                    fontSize: 5.0,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                      color: themeProvider.isLightMode()
                          ? Colors.amber.shade700
                          : Colors.grey.shade700,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 1.0,
                      spreadRadius: 1.0),
                ],
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: themeProvider.isLightMode() ? kGold : kSilver,
                    stops: [0.1, 0.3, 0.8, 1])),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(builder: _buildAnimation, animation: controller);
  }
}
