import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import './phase.dart' as phasePage;
import './about.dart' as aboutPage;
import './step.dart' as StepPage;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: PageView(
          controller: _pageController,
          children: <Widget>[
            aboutPage.AboutPage(),
            phasePage.PhasePage(),
            StepPage.StepPage(),
          ],
        ),

        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _page,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: (index) =>
              setState(() {
                _page = index;
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 150), curve: Curves.ease);
              }),

          items: [

            BottomNavyBarItem(
                icon: Icon(Icons.people),
                title: Text('Pfofile'),
                activeColor: Colors.purpleAccent
            ),

            BottomNavyBarItem(
              icon: Icon(Icons.schedule),
              title: Text('Phase'),
              activeColor: Colors.red,
            ),

            BottomNavyBarItem(
                icon: Icon(Icons.map),
                title: Text('Step'),
                activeColor: Colors.blue
            ),


          ],
        )
    );
  }
}
