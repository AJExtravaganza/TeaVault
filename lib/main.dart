// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production_collection.dart';
import 'package:teavault/models/teapot_collection.dart';
import 'package:teavault/screens/authentication/authentication_wrapper.dart';
import 'package:teavault/screens/climate/climate.dart' as climate;
import 'package:teavault/screens/stash/stash.dart';
import 'package:teavault/screens/teasessions/helper_functions.dart';
import 'package:teavault/screens/teasessions/tea_session_view.dart';
import 'package:teavault/tea_session_controller.dart';

void main() {
  //This is necessary to allow subscription to the db snapshots prior to calling runApp()
  WidgetsFlutterBinding.ensureInitialized();

  List<BrewingVessel> userTeapotCollection = getSampleVesselList();

  void subscribeModels() async {
    teaProducersCollection.subscribeToDb();
    teaProductionsCollection.subscribeToDb();
    teasCollection.subscribeToDb();
  }

  runApp(MaterialApp(
      title: 'TeaVault',
      home: AuthenticationWrapper(
          builder: () => MultiProvider(
                providers: [
                  ChangeNotifierProvider<TeaProducerCollectionModel>(
                    create: (_) => teaProducersCollection,
                  ),
                  ChangeNotifierProvider<TeaProductionCollectionModel>(
                    create: (_) => teaProductionsCollection,
                  ),
                  ChangeNotifierProvider<TeaCollectionModel>(
                    create: (_) => teasCollection,
                  ),
                  ChangeNotifierProvider<TeapotCollectionModel>(
                      create: (_) => TeapotCollectionModel(userTeapotCollection)),
                  ChangeNotifierProvider<TeaSessionController>(create: (_) => TeaSessionController(teasCollection)),
                ],
                child: MyApp(onBuild: subscribeModels),
              ))));
}

class MyApp extends StatelessWidget {
  Function _onBuild;

  MyApp({Function onBuild}) {
    _onBuild = onBuild;
  }

  @override
  Widget build(BuildContext context) {
    _onBuild();

    return MaterialApp(
      title: 'TeaVault',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: HomeView(),
    );
  }
}

Scaffold getStubContent([String textContent = 'STUBCONTENT']) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${textContent}APPBARTITLE'),
    ),
    body: Center(child: Text(textContent)),
  );
}

class HomeView extends StatefulWidget {
  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  static final String sessionTabLabel = 'Session';
  static final String stashTabLabel = 'Stash';
  static final String climateTabLabel = 'Climate';
  static final SESSIONTABIDX = 0;
  static final STASHTABIDX = 1;

  final List<Tab> homeTabs = <Tab>[
    Tab(
      text: sessionTabLabel,
    ),
    Tab(
      text: stashTabLabel,
    ),
    Tab(
      text: climateTabLabel,
    )
  ];

  TabController _tabController;

  void switchToTab(int tabId) {
    _tabController.index = tabId;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: homeTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: homeTabs.length,
      child: Scaffold(
        appBar: AppBar(
//          title: Text('TeaVault v0.1'),
          title: TabBar(
            controller: _tabController,
            tabs: homeTabs,
            onTap: (_) => onPressDefaultVibrate(),
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: homeTabs.map((Tab tab) {
              if (tab.text == sessionTabLabel) {
                return TeaSessionView();
              } else if (tab.text == stashTabLabel) {
                return StashView();
              } else if (tab.text == climateTabLabel) {
                return climate.DateTimeComboLinePointChart.withSampleData();
              } else {
                return getStubContent('ERROR: INVALID TAB ${tab.text} SPECIFIED');
              }
            }).toList()),
      ),
    );
  }
}
