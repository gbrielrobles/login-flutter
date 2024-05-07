import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  var _emailInserido = '';
  var _senhaInserida = '';
  bool _erroValidacao = false;

  void _enviar() async {
    setState(() {
      _erroValidacao = false;
    });

    if (!_chaveForm.currentState!.validate()) {
      setState(() {
        _erroValidacao = true;
      });
      return;
    }

    _chaveForm.currentState!.save();

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailInserido,
        password: _senhaInserida,
      );
      ;
      // Se chegou até aqui, o login foi bem-sucedido Teste
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      setState(() {
        _erroValidacao = true;
      });
    }
  }

  void _exibirPopup(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _irParaCadastro(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Cadastro()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _chaveForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 1,
                    bottom: 100,
                  ),
                  width: 350,
                  child: Image.asset('assets/unicv-logo-site.png'),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usuário:',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    errorText: _erroValidacao ? 'Usuário inválido' : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um usuário válido.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _emailInserido = value!;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Senha:',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    errorText: _erroValidacao ? 'Senha inválida' : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma senha válida.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _senhaInserida = value!;
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    print('Esqueceu a senha?');
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(
                      color: Color.fromRGBO(58, 92, 51, 1),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _enviar,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(58, 92, 51, 1),
                    ),
                  ),
                  child: Text('Entrar', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _irParaCadastro(context);
                  },
                  child: Text(
                    'Não possui uma conta? Registre-se Aqui',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}