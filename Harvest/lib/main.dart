import 'package:Harvest/providers/Serii.dart';
import 'package:Harvest/screens/MpScreen.dart';
import 'package:Harvest/screens/SeriiScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Serii(),
        )
      ],
      child: MaterialApp(
          title: 'Harvest',
          theme: ThemeData(
            primaryColor: Colors.black,
            fontFamily: 'PTSans',
          ),
          home: SeriiScreen(),
          routes: {
            MpScreen.routeName: (ctx) => MpScreen(),
          }),
    );
  }
}
