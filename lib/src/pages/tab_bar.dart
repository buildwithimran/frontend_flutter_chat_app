import 'package:chat_app/src/pages/TabPages/main_page.dart';
import 'package:chat_app/src/pages/TabPages/side_menu_page.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class TabsUserScreen extends StatefulWidget {
  const TabsUserScreen({super.key});

  @override
  State<TabsUserScreen> createState() => TabsUserScreenState();
}

class TabsUserScreenState extends State<TabsUserScreen> {
  // Variables
  int selectedIndex = 0;
  var categoriesArr = [];
  List<Widget> pages = [];

  // Functions
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    pages = <Widget>[
      ChatPage(),
      const SideMenu(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: pages.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.menu_1),
            label: 'More',
          ),
        ],
        elevation: 10,
        backgroundColor: lightColor,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor,
        selectedLabelStyle: TextStyle(
          color: primaryColor,
          fontFamily: 'rr',
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'rr',
          color: primaryColor,
          fontSize: 14,
        ),
      ),
    );
  }
}
