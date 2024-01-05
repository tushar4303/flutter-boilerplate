import 'package:boilerplate/firebase_options.dart';
import 'package:boilerplate/screens/dataGrid.dart';
import 'package:boilerplate/screens/homescreen.dart';
import 'package:boilerplate/screens/loginScreen.dart';
import 'package:boilerplate/utils/AuthHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/quickalert.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

Future<void> _handleSignOut() => _googleSignIn.disconnect();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await AuthHelper.isLoggedIn();
  await Firebase.initializeApp(
    name: "asilia-tech",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? const MyHomePage() : const SignInPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GridScreen(),
    const Signout(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: kTextTabBarHeight + 20,
          title: const Text(
            "Asilia Tech",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
          )),
      body: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromRGBO(173, 170, 173, 1),
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic),
            label: 'Data Grid',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}

class Signout extends StatelessWidget {
  const Signout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            // prompt for confirmation before logging out
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                text: 'Do you want to logout',
                confirmBtnText: 'Yes',
                cancelBtnText: 'No',
                confirmBtnColor: Colors.black,
                onConfirmBtnTap: () {
                  AuthHelper.setLoggedIn(false);
                  _handleSignOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
