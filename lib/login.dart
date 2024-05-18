import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Chave global para identificar o formulário
  final _chaveForm = GlobalKey<FormState>();
  // Variáveis para armazenar os dados inseridos pelo usuário
  var _emailInserido = '';
  var _senhaInserida = '';
  // Variável para indicar se houve erro de validação
  bool _erroValidacao = false;

  // Função para enviar os dados do formulário para autenticação
  void _enviar() async {
    // Resetar o estado de erro de validação
    setState(() {
      _erroValidacao = false;
    });

    // Validar o formulário, se inválido, marcar erro de validação e retornar
    if (!_chaveForm.currentState!.validate()) {
      setState(() {
        _erroValidacao = true;
      });
      return;
    }

    // Salvar os dados do formulário
    _chaveForm.currentState!.save();

    try {
      // Tentar fazer login com Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailInserido,
        password: _senhaInserida,
      );

      // Verificar se o email do usuário está verificado
      if (userCredential.user!.emailVerified) {
        // Exibir popup de sucesso
        _exibirPopup('Login bem-sucedido', 'Usuário logado com sucesso!');

        // Obter os dados do usuário do Firestore
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(userCredential.user!.uid)
                .get();
      } else {
        // Exibir popup pedindo para verificar o email
        _exibirPopup('Erro de autenticação',
            'Por favor, verifique seu email antes de fazer login.');
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do FirebaseAuth
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      // Marcar erro de validação
      setState(() {
        _erroValidacao = true;
      });
    }
  }

  // Função para exibir um popup com uma mensagem
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

  // Função para navegar para a tela de cadastro
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
      // Cor de fundo da tela
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
                // Campo de texto para inserir o usuário (email)
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
                // Link para recuperação de senha
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
                // Botão de login
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
