import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool isLogin = true;

  void _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (isLogin) {
      final user = await _auth.login(email, password);
      if (user != null) {
        print("Login Autenticado: ${user.email}");
      }
    } else {
      final user = await _auth.register(email, password);
      if (user != null) {
        print("Cadastro Autenticado: ${user.email}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 350),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3)
            ),
          ],
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Column(
              children: [
                Text(
                  isLogin ? "Login" : "Cadastro",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isLogin? "Faça login para continuar" : "Preencha os dados abaixo",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    fixedSize: Size(350, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8)
                    )
                  ),
                  
                  child: Text(isLogin ? "Entrar" : "Cadastrar"),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black
                  ),
                  child: Text(isLogin ? "Não tem Conta? Crie uma agora" : "Já tem conta? Entrar"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}