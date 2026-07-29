
import 'package:flutter/material.dart';
import 'package:unidos/telas/comunidades_tela.dart';
import 'package:unidos/telas/home_page.dart';
import 'package:unidos/telas/relatorios_tela.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState
    extends State<MainPage> {

  final PageController _pageController =
      PageController();

  int paginaAtual = 0;

  final List<Widget> paginas = const [
    HomePage(),
    ComunidadesPage(),
    RelatoriosPage()
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void mudarPagina(int index) {
    _pageController.animateToPage(
      index,
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,

        onPageChanged: (index) {
          setState(() {
            paginaAtual = index;
          });
        },

        children: paginas,
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: paginaAtual,

        onTap: mudarPagina,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Comunidades',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}
