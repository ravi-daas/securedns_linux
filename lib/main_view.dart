import 'package:flutter/material.dart';
import 'package:securedns/views/profile_pages/profile_view.dart';
import 'home_new.dart';
import 'views/profile_pages/blogs_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const BlogsView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationSidebar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationSidebar(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  Widget _buildButton(
    String text,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: 140,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF5246dd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   width: 200,
    //   color: const Color(0xFFe0e5ff),
    //   child: ListView(
    //     children: <Widget>[
    //       ListTile(
    //         title: const Text('Home'),
    //         selected: selectedIndex == 0,
    //         onTap: () => onItemTapped(0),
    //       ),
    //       ListTile(
    //         title: const Text('Blog'),
    //         selected: selectedIndex == 1,
    //         onTap: () => onItemTapped(1),
    //       ),
    //       ListTile(
    //         title: const Text('Profile'),
    //         selected: selectedIndex == 2,
    //         onTap: () => onItemTapped(2),
    //       ),
    //     ],
    //   ),
    // );
    return Container(
      width: 200,
      color: const Color(0xFFe0e5ff),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          _buildButton(
            'Home',
            () => onItemTapped(0),
          ),
          _buildButton(
            'Blog',
            () => onItemTapped(1),
          ),
          _buildButton(
            'Profile',
            () => onItemTapped(2),
          ),
        ],
      ),
    );
  }
}

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Profile Screen'),
//     );
//   }
// }
