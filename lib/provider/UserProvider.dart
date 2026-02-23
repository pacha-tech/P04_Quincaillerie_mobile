import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProvider extends ChangeNotifier {
  String? _role;
  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;

  String? get role => _role;
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;
  bool get isUnknown => _status == AuthStatus.unknown;

  UserProvider() {
    _listenToAuthChanges();
    _init();
  }

  Future<void> _init() async {
    await refreshUser();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _currentUser = user;

      if (user == null) {
        _role = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.authenticated;
        await _loadRole(user);
      }

      notifyListeners();
    });
  }

  Future<void> _loadRole(User user) async {
    try {
      final idTokenResult = await user.getIdTokenResult(true);
      _role = idTokenResult.claims?['role'] as String? ?? 'rien';
    } catch (e) {
      debugPrint("Erreur lecture rôle : $e");
      _role = 'CLIENT';
    }
  }

  Future<void> refreshUser() async {
    final user = FirebaseAuth.instance.currentUser;
    _currentUser = user;

    if (user == null) {
      _role = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _status = AuthStatus.authenticated;
      await _loadRole(user);
    }


    notifyListeners();
  }


  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Le listener va automatiquement mettre à jour l'état
    } catch (e) {
      debugPrint("Erreur déconnexion : $e");
    }
  }
}