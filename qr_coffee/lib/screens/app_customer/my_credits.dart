import 'package:provider/provider.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';

class Credits extends StatefulWidget {
  @override
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
  }

  Future<void> _playAnimation() async {
    try {
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
          Customer customer = snapshot.data!;

          return Scaffold(
            backgroundColor: themeProvider.themeData().backgroundColor,
            appBar: customAppBar(context, title: Text('')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                      child: TokenTable(
                    controller: _controller,
                    customer: customer,
                    function: _playAnimation,
                  )),
                ),
                // TextButton(
                //     onPressed: () => _playAnimation(), child: Text('play'))
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}

class TokenTable extends StatelessWidget {
  TokenTable({Key? key, required this.controller, required this.customer, required this.function})
      : width = Tween<double>(
          begin: 260.0,
          end: 255.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.050,
              curve: Curves.bounceInOut,
            ),
          ),
        ),
        height = Tween<double>(
          begin: 160.0,
          end: 155.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.050,
              curve: Curves.bounceInOut,
            ),
          ),
        ),
        super(key: key);

  final Customer customer;
  final Function function;
  final AnimationController controller;
  final Animation<double> width;
  final Animation<double> height;

  final List<Color> gold = [
    Colors.amber.shade50,
    Colors.amber.shade200,
    Colors.amber.shade600,
    Colors.amber.shade700,
  ];

  final List<Color> silver = [
    Colors.grey.shade50,
    Colors.grey.shade200,
    Colors.grey.shade600,
    Colors.grey.shade700,
  ];

  Widget _buildAnimation(BuildContext context, Widget? child) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: width.value,
      height: height.value,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
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
            colors: themeProvider.isLightMode() ? gold : silver,
            stops: [0.1, 0.3, 0.8, 1]),
      ),
      child: InkWell(
        onTap: () {
          function;
        },
        child: Center(
          child: Container(
            width: 240,
            height: 140,
            child: Center(
                child: Text(
              '${customer.credits} CR',
              style: TextStyle(
                color: themeProvider.isLightMode()
                    ? Color.fromARGB(255, 148, 101, 0)
                    : Color.fromARGB(255, 60, 60, 70),
                fontSize: 35,
              ),
            )),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
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
                    colors: themeProvider.isLightMode() ? gold : silver,
                    stops: [0.1, 0.3, 0.8, 1])),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
