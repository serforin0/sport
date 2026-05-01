import 'package:flutter/material.dart';
import 'package:sport/features/feed/presentation/pages/feed_page.dart';
import 'package:sport/features/feed/presentation/pages/create_post_page.dart';
import 'package:sport/features/search/presentation/pages/search_page.dart';
import 'package:sport/features/chat/presentation/pages/chat_list_page.dart';
import 'package:sport/features/profile/presentation/pages/profile_page.dart';


class MainShellPage extends StatefulWidget {
  const MainShellPage({Key? key}) : super(key: key);

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),         // Index 0
    const SearchPage(),       // Index 1
    const CreatePostPage(),   // Index 2
    const ChatListPage(),     // Index 3
    const ProfilePage(),      // Index 4
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A43),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF001A43),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.blueAccent),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
