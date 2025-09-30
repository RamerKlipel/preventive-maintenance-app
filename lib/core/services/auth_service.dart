import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // cadastro

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
        );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("O e-mail já está em uso.");
      } else if (e.code == 'weak-password') {
        print("A senha é muito fraca.");
      } else {
        print("Erro no Cadastro: ${e.message}");
      }
      return null;
    }
  }

  //login

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Nenhum usuário encontrado para este e-mail.");
      } else if (e.code == 'wrong-password') {
        print("Senha incorreta.");
      } else {
        print("Erro no Login: ${e.message}");
      }
      return null;
    }
  }

  // Logout

  Future<void> logout() async {
    await _auth.signOut();
  }

  // usuario atual

  User? get currentUser => _auth.currentUser;
}