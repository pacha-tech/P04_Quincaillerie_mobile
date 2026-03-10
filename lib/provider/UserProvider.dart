

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProvider extends ChangeNotifier {
  String? _role;
  String? _quincaillerieId;
  String? _token;
  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;


  String? get role => _role;
  String? get quincaillerieId => _quincaillerieId;
  String? get token => _token;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;
  bool get isUnknown => _status == AuthStatus.unknown;
  User? get currentUser => _currentUser;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user == null) {
        _role = null;
        _quincaillerieId = null;
        _token = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        _status = AuthStatus.authenticated;
        await _loadUserClaims(user);
      }
    });
  }

  Future<void> _loadUserClaims(User user) async {
    try {

      final idTokenResult = await user.getIdTokenResult(true);

      _token = idTokenResult.token;

      final roleData = idTokenResult.claims?['role'];
      if (roleData is List) {
        _role = roleData.first.toString();
      } else {
        _role = roleData?.toString();
      }


      _quincaillerieId = idTokenResult.claims?['quincaillerieId']?.toString();

      debugPrint("Claims chargés : Rôle=$_role, Quincaillerie=$_quincaillerieId");
    } catch (e) {
      debugPrint("Erreur lecture claims : $e");
      //_role = 'CLIENT';
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshClaimsAfterLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Force un refresh du token + claims (le true est important)
        final idTokenResult = await user.getIdTokenResult(true);

        // Recharge les claims
        await _loadUserClaims(user);

        debugPrint("Claims rafraîchis après login : rôle = $_role");
      } catch (e) {
        debugPrint("Erreur refresh claims après login : $e");
      }
    }
  }

  Future<void> refreshUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _loadUserClaims(user);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}