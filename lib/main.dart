import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:compradordodia/rotas.dart';
import 'package:compradordodia/splash.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

void main(){
  FirebaseAnalytics analytics = FirebaseAnalytics();
  runApp(
    MaterialApp(
      home: SplashScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: ThemeData(
          primaryColor: Colors.amber,
          accentColor: Colors.amber
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    )
  );
}
