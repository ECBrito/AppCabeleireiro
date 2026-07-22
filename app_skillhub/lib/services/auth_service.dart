import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obter o utilizador atual do Firebase Auth
  User? get currentUser => _auth.currentUser;

  // Stream do estado de autenticação (para reagir quando entra/sai)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login com Email e Password
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Registo de Utilizador + Guardar Perfil no Firestore
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String name,
    required String role, // 'client' ou 'owner'
    String? businessId,
  }) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar dados extra no Firestore
      if (res.user != null) {
        await _db.collection('users').doc(res.user!.uid).set({
          'uid': res.user!.uid,
          'name': name,
          'email': email,
          'role': role,
          'businessId': businessId ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Obter dados do utilizador do Firestore
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // Atualizar dados do utilizador no Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}