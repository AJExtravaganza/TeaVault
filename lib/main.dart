// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';
import 'package:teavault/models/teapot_collection.dart';
import 'package:teavault/models/user.dart';
import 'package:teavault/screens/authentication/authentication_wrapper.dart';
import 'package:teavault/screens/climate/climate.dart' as climate;
import 'package:teavault/screens/stash/stash.dart';
import 'package:teavault/screens/teasessions/teasessions.dart';
import 'package:teavault/tea_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future nukeDb(BuildContext context) async {
  final producers = Provider.of<TeaProducerCollectionModel>(context, listen: false);
  final productions = Provider.of<TeaProductionCollectionModel>(context, listen: false);
  final teas = Provider.of<TeaCollectionModel>(context, listen: false);
  final user = await fetchUser();

  final old_producers = await Firestore.instance.collection(producers.dbCollectionName).getDocuments();
  final old_productions = await Firestore.instance.collection(productions.dbCollectionName).getDocuments();
  final old_teas = await user.reference.collection(teas.dbCollectionName).getDocuments();

  print('Deleting all producers, productions and teas...');

  old_teas.documents.forEach((doc) async {
    await doc.reference.delete();
  });
  old_productions.documents.forEach((doc) async {
    await doc.reference.delete();
  });
  old_producers.documents.forEach((doc) async {
    await doc.reference.delete();
  });

  print('Done.');
}

Future rebuildTeaData(BuildContext context) async {
//  await nukeDb(context);

  final producers = Provider.of<TeaProducerCollectionModel>(context, listen: false);
  final productions = Provider.of<TeaProductionCollectionModel>(context, listen: false);

  print('Repopulating database/local collections...');

  final producersPopList = [
    'Wistaria',
    'Xiaguan',
    'Menghai Dayi',
    'Nanqiao',
    'Changtai',
    'Xizihao',
    'Yangqinghao',
    "Sean's Oolongs"
  ];

  final productionPopList = {
    'Wistaria': [
      [2003, 'Zipin'],
      [2003, 'Ziyin You'],
      [2003, 'Ziyin Nannuo'],
      [2007, 'Lanyin'],
      [2007, 'Hongyin'],
    ],
    'Xiaguan': [
      [2001, '8653 Tiebing'],
      [2007, 'Jinsi Tuo', 100],
      [2013, 'Love Forever (Paper Tong)'],
      [2012, '8653'],
      [2007, 'Green G']
    ],
    'Menghai Dayi': [
      [2005, '502-7542'],
      [2003, 'Purple Dayi'],
    ],
    'Nanqiao': [
      [2004, 'Nanqiaowang'],
    ],
    'Changtai': [],
    'Xizihao': [
      [2006, "Laoman'e Gushu", 500],
      [2006, "Huanshanling Youle", 400],
      [2006, "Yiwu Chahuang", 400],
      [2006, "Black Taiji LBZ", 400],
      [2007, 'Huangshanlin', 400],
      [2007, 'Yuanshilin', 400],
      [2007, 'Shenshanlin', 400],
      [2007, "'8582'", 400],
      [2007, '6FTM Blend', 400],
      [2007, 'Dingji Gushu', 400],
      [2007, 'Puzhen', 250],
      [2007, 'Xueshan Chunlu', 250],
    ],
    'Yangqinghao': [
      [2004, 'Tejipin', 500],
      [2004, 'Zhencang Chawang', 400],
      [2007, 'Lingya', 400],
      [2007, 'Jincha']
    ],
    "Sean's Oolongs": [
      [2014, 'Hongshui', 150],
      [2016, 'Foshou', 150],
    ]
  };

  producersPopList.forEach((producerName) async {
    final producer = TeaProducer(producerName, producerName);
    if (!producers.contains(producer)) {
      print('Inserting ${producer.asString()}');
      await producers.put(producer);
    }

    try {
      final prodArr = productionPopList[producerName];
      final producerId = producers.getByName(producerName).id;
      prodArr.forEach((prod) async {
        final production =
            TeaProduction(prod[1], prod.length > 2 ? prod[2] : 357, producers.getById(producerId), prod[0]);
        if (!productions.contains(production)) {
          print('Inserting ${production.asString()}');
          await productions.put(production);
        }
      });
    } catch (err) {
      print(
          'Error populating productions for $producerName - please run again or fix rebuildTeaData() to wait for the async producer insertion');
    }
  });

  print('done.');
}

void main() {
  //This is necessary to allow subscription to the db snapshots prior to calling runApp()
  WidgetsFlutterBinding.ensureInitialized();

  List<BrewingVessel> userTeapotCollection = getSampleVesselList();
  final teaProducerCollectionModel = TeaProducerCollectionModel();
  final teaProductionCollectionModel = TeaProductionCollectionModel(teaProducerCollectionModel);
  final teaCollectionModel = TeaCollectionModel(teaProductionCollectionModel);
  final teaSessionController = TeaSessionController(teaCollectionModel);

  runApp(MaterialApp(
      title: 'TeaVault',
      home: AuthenticationWrapper(MultiProvider(
        providers: [
          ChangeNotifierProvider<TeaProducerCollectionModel>(
            create: (_) => teaProducerCollectionModel,
          ),
          ChangeNotifierProvider<TeaProductionCollectionModel>(
            create: (_) => teaProductionCollectionModel,
          ),
          ChangeNotifierProvider<TeaCollectionModel>(
            create: (_) => teaCollectionModel,
          ),
          ChangeNotifierProvider<TeapotCollectionModel>(create: (_) => TeapotCollectionModel(userTeapotCollection)),
          ChangeNotifierProvider<TeaSessionController>(create: (_) => teaSessionController),
        ],
        child: MyApp(),
      ))));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Append any new TeaProducer/TeaProduction definitions to the database
    rebuildTeaData(context);

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
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: homeTabs.map((Tab tab) {
              if (tab.text == sessionTabLabel) {
                return SessionsView();
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
