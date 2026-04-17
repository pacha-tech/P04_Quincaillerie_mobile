import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../service/hive/PanierHiveService.dart';
import '../service/message/MessageStomp.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProvider extends ChangeNotifier {
  String? _role;
  String? _quincaillerieId;
  String? _token;
  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;


  static const String _userBoxName  = 'userBox';
  static const String _keyRole      = 'user_role';
  static const String _keyQuincId   = 'user_quincaillerie_id';


  String? get role             => _role;
  String? get quincaillerieId  => _quincaillerieId;
  String? get token            => _token;
  AuthStatus get status        => _status;
  bool get isAuthenticated     => _status == AuthStatus.authenticated;
  bool get isUnauthenticated   => _status == AuthStatus.unauthenticated;
  bool get isUnknown           => _status == AuthStatus.unknown;
  User? get currentUser        => _currentUser;

  UserProvider() {
    _listenToAuthChanges();
  }


  Box get _userBox => Hive.box(_userBoxName);

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _currentUser = user;

      if (user == null) {
        _role = null;
        _quincaillerieId = null;
        _token = null;
        _status = AuthStatus.unauthenticated;
        MessageStomp().disconnect();
        await _clearLocalSession();
        notifyListeners();
      } else {
        _status = AuthStatus.authenticated;

        await _loadUserClaims(user);

        if(_token != null ){
          debugPrint("Initialisation STOMP avec Token présent");
          String identifier = (_role == "VENDEUR" && _quincaillerieId != null) ? _quincaillerieId! : user.uid;
          MessageStomp().init(identifier, _getFreshToken);

        }
      }
    });
  }

  Future<void> _loadUserClaims(User user) async {
    try {

      final idTokenResult = await user.getIdTokenResult(false);

      _token = idTokenResult.token;

      final roleData = idTokenResult.claims?['role'];
      if (roleData is List) {
        _role = roleData.first.toString();
      } else {
        _role = roleData?.toString();
      }

      _quincaillerieId = idTokenResult.claims?['quincaillerieId']?.toString();

      await _saveLocalSession();

      debugPrint("Claims chargés depuis Firebase : Rôle=$_role, Quincaillerie=$_quincaillerieId");
    } catch (e) {

      debugPrint("Erreur lecture claims Firebase : $e — lecture depuis Hive");

      _role            = _userBox.get(_keyRole);
      _quincaillerieId = _userBox.get(_keyQuincId);
      _token           = null;

      debugPrint("Claims chargés depuis Hive : Rôle=$_role, Quincaillerie=$_quincaillerieId");
    } finally {
      notifyListeners();
    }
  }


  Future<void> _saveLocalSession() async {
    await _userBox.put(_keyRole, _role);
    if(_role == "VENDEUR"){
      await _userBox.put(_keyQuincId, _quincaillerieId);
    }
  }


  Future<void> _clearLocalSession() async {
    await _userBox.delete(_keyRole);
    await _userBox.delete(_keyQuincId);


    final PanierHiveService panierHiveService = PanierHiveService();
    await panierHiveService.clearCart();
  }


  Future<void> refreshClaimsAfterLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {

        final idTokenResult = await user.getIdTokenResult(true);
        _token = idTokenResult.token;


        await _loadUserClaims(user);


        String identifier = (_role == "VENDEUR") ? _quincaillerieId! : user.uid;
        MessageStomp().init(identifier, _getFreshToken);

      } catch (e) {
        debugPrint("Erreur refresh claims : $e");
      }
    }
  }

  Future<String?> _getFreshToken() async {
    if (_currentUser != null) {
      return await _currentUser!.getIdToken();
    }
    return null;
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

  String get myId {
    return _currentUser?.uid ?? "";
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}