import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

void main() {
  runApp(const Cadastro());
}

class Cadastro extends StatelessWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CadastroScreen(),
    );
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // Chave global para o formulário (é usada para salvar os dados)
  final _chaveForm = GlobalKey<FormState>();
  var _nomeUsuario = '';
  var _senha = '';
  var _cpf = '';
  var _email = '';
  var _tipoUsuario = 'Estudante';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/unicv-logo-site.png',
              height: 40,
              width: 40,
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        color: const Color.fromRGBO(58, 92, 51, 1),
        padding: EdgeInsets.all(20),
        child: Form(
          key: _chaveForm,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                onChanged: (newValue) {
                  // Atualiza o tipo de usuário selecionado
                  setState(() {
                    _tipoUsuario = newValue!;
                  });
                },
                items: <String>['Estudante', 'Professor']
                    .map<DropdownMenuItem<String>>((String value) {
                  // Exibe as opções para o usuário
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nome de Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um nome de usuário válido.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Salva o nome de usuário
                    _nomeUsuario = value!;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Oculta o campo de senha
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira uma senha válida.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Salva a senha
                    _senha = value!;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'CPF:',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um CPF válido.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Salva o CPF institucional
                    _cpf = value!;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Por favor, insira um endereço de email válido.';
                    } else if (_tipoUsuario == 'Estudante' &&
                        !value.endsWith('@aluno.unicv.edu.br')) {
                      return 'Insira um email de aluno válido.';
                    } else if (_tipoUsuario == 'Professor' &&
                        !value.endsWith('@unicv.edu.br')) {
                      return 'Insira um email de professor válido.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Salva o email
                    _email = value!;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Valida o formulário e salva os dados
                  if (_chaveForm.currentState!.validate()) {
                    _chaveForm.currentState!.save();
                    try {
                      // Cria o usuário no Firebase Authentication
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: _email,
                        password: _senha,
                      );

                      // Adiciona as informações do usuário ao Firestore Database
                      await FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({
                        'nomeUsuario': _nomeUsuario,
                        'senha': _senha,
                        'cpf': _cpf,
                        'email': _email,
                        'tipoUsuario': _tipoUsuario,
                      });

                      // Envia o e-mail de verificação
                      User? user = FirebaseAuth.instance.currentUser;
                      await user!.sendEmailVerification();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Verifique seu email para confirmar o cadastro'),
                      ));
                      Navigator.pushReplacement(
                          context,
                          // Volta para a tela de login em caso de erro
                          MaterialPageRoute(builder: (context) =>const TelaLogin()));
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erro ao criar usuário: ${e.message}'),
                      ));
                    }
                  }
                },
                child: Text('Prosseguir'),
              ),
              const SizedBox(height: 10),
              // Volta para a tela de login
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaLogin()),
                  );
                },
                child: const Text(
                  'Cancelar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
