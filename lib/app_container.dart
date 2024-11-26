import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/screens/screen.dart';
import 'package:listar_flutter_pro/utils/utils.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int _selectedIndex = 0;
  final List<String> _routes = [
    Routes.home,
    Routes.discovery,
    Routes.wishList,
    Routes.account,
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(_handleNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
  }

  void _handleNotification(RemoteMessage message) {
    final notification = NotificationModel.fromJson(message.data as RemoteMessage);
    if (notification.target != null) {
      Navigator.pushNamed(context, notification.target!, arguments: notification.item);
    }
  }

  void _onAuthStateChanged(AuthenticationState authenticationState) async {
    if (authenticationState == AuthenticationState.fail && _requiresAuth(_routes[_selectedIndex])) {
      final result = await Navigator.pushNamed(context, Routes.signIn, arguments: _routes[_selectedIndex]);
      setState(() {
        _selectedIndex = result != null ? _routes.indexOf(result as String) : 0;
      });
    }
  }

  bool _requiresAuth(String route) {
    return !(route == Routes.home || route == Routes.discovery);
  }

  void _onItemTapped(int index) async {
    final route = _routes[index];
    if (AppBloc.userCubit.state == null && _requiresAuth(route)) {
      final result = await Navigator.pushNamed(context, Routes.signIn, arguments: route);
      if (result == null) return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, authentication) => _onAuthStateChanged(authentication),
        child: IndexedStack(
          index: _selectedIndex,
          children: const <Widget>[Home(), Discovery(), WishList(), Account()],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: const Color(0xFF146C3D), // Primary color updated
        buttonBackgroundColor: const Color(0xFF146C3D), // Button background color updated
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.location_on_outlined, size: 30, color: Colors.white),
          Icon(Icons.bookmark_outline, size: 30, color: Colors.white),
          Icon(Icons.account_circle_outlined, size: 30, color: Colors.white),
        ],
        onTap: _onItemTapped,
        index: _selectedIndex,
      ),
      floatingActionButton: Application.setting.enableSubmit
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF146C3D), // Floating Action Button color updated
              onPressed: _onSubmitButtonPressed,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onSubmitButtonPressed() async {
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(context, Routes.signIn, arguments: Routes.submit);
      if (result == null) return;
    }
    if (mounted) {
      Navigator.pushNamed(context, Routes.submit);
    }
  }
}
