import 'package:provider/provider.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';

class QRTokens extends StatefulWidget {
  @override
  _QRTokensState createState() => _QRTokensState();
}

class _QRTokensState extends State<QRTokens> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
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
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserData>(
      stream: UserDatabase(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data!;

          return Scaffold(
            appBar: customAppBar(context, title: Text('')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                      child: TokenTable(
                    controller: _controller,
                    userData: userData,
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
  TokenTable(
      {Key? key,
      required this.controller,
      required this.userData,
      required this.function})
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

  final UserData userData;
  final Function function;
  final AnimationController controller;
  final Animation<double> width;
  final Animation<double> height;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Container(
      width: width.value,
      height: height.value,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(10.0, 10.0),
              blurRadius: 15.0,
              spreadRadius: 5.0),
        ],
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.amber.shade200,
              Colors.amber.shade600,
              Colors.amber.shade700,
            ],
            stops: [
              0.1,
              0.3,
              0.8,
              1
            ]),
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
              '${userData.tokens} QRT',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
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
                      color: Colors.amber.shade700,
                      offset: Offset(3.0, 3.0),
                      blurRadius: 1.0,
                      spreadRadius: 1.0),
                ],
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade50,
                      Colors.amber.shade200,
                      Colors.amber.shade600,
                      Colors.amber.shade700,
                    ],
                    stops: [
                      0.1,
                      0.3,
                      0.8,
                      1
                    ])),
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
