import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cadastro.dart';
import 'selecionar_curso.dart';
import 'home.dart'; // Importar a tela inicial

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

      if (userCredential.user!.emailVerified) {
        var userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('cursoSemestreMateria') &&
              (userData['cursoSemestreMateria'] as List<dynamic>).isNotEmpty) {
            // Se cursoSemestreMateria existir e não estiver vazio, navegue para HomeScreen
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          } else {
            // Se não, navegue para a tela de seleção de curso
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => SelecionarCursoScreen()),
              );
            }
          }
        }
      } else {
        _exibirPopup('Erro de autenticação',
            'Por favor, verifique seu email antes de fazer login.');
      }
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _irParaCadastro(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Cadastro()));
  }

  Future<void> _recuperarSenha() async {
    final TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Senha'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'Digite seu e-mail'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Email de recuperação de senha enviado!'),
                  ));
                } on FirebaseAuthException catch (e) {
                  String errorMessage;
                  if (e.code == 'invalid-email') {
                    errorMessage =
                        'Email inválido. Por favor, verifique e tente novamente.';
                  } else if (e.code == 'user-not-found') {
                    errorMessage = 'Nenhuma conta encontrada com este email.';
                  } else {
                    errorMessage =
                        'Erro ao enviar email de recuperação: ${e.message}';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(errorMessage),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Por favor, insira um email válido.'),
                ));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
      ),
      backgroundColor: const Color.fromRGBO(230, 231, 232, 1),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                          labelText: 'E-mail:',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
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
                        onTap: _recuperarSenha,
                        child: const Text(
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
                            const Color.fromRGBO(58, 92, 51, 1),
                          ),
                        ),
                        child: const Text('Entrar',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          _irParaCadastro(context);
                        },
                        child: const Text(
                          'Não possui uma conta? Registre-se Aqui',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color.fromRGBO(58, 92, 51, 1), // Green color
            height: 50.0, // Height of the green bar at the bottom
          ),
        ],
      ),
    );
  }
}
