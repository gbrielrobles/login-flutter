import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const Cadastro());
}

class Cadastro extends StatelessWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
          flexibleSpace: const Center(
            child: Image(
              image: AssetImage(
                'assets/unicv-logo-site.png',
              ),
              height: 90,
              width: 90,
            ),
          ),
        ),
        backgroundColor: const Color.fromRGBO(58, 92, 51, 1),
        body: Container(
          height: double.infinity,
          color: const Color.fromRGBO(58, 92, 51, 1),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: CadastroForm(),
                  ),
                ),
              ),
              Container(
                color: const Color.fromRGBO(239, 153, 45, 1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Cancelar',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(239, 153, 45, 1),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final formState = CadastroForm.of(context);
                          if (formState != null && formState.validate()) {
                            formState.save();
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: formState.email,
                                password: formState.senha,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cadastro realizado com sucesso!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message ?? 'Erro ao cadastrar usuário.',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor, preencha todos os campos!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Concluir',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(239, 153, 45, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroForm extends StatefulWidget {
  const CadastroForm({Key? key}) : super(key: key);

  @override
  _CadastroFormState createState() => _CadastroFormState();

  static _CadastroFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CadastroFormState>();
  }
}

class _CadastroFormState extends State<CadastroForm> {
  final _chaveForm = GlobalKey<FormState>();
  var _nomeUsuario = '';
  var _senha = '';
  var _email = '';
  var _tipoUsuario;

  final Logger _logger = Logger();

  List<bool> _selections = List.generate(3, (_) => false);

  bool validate() {
    return _chaveForm.currentState!.validate();
  }

  void save() {
    _chaveForm.currentState!.save();
    _logger.d('Nome de Usuário: $_nomeUsuario, Senha: $_senha, Email: $_email');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _chaveForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nome de Usuário',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira um nome de usuário válido.';
              }
              return null;
            },
            onSaved: (value) {
              _nomeUsuario = value!;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Senha',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira uma senha válida.';
              }
              return null;
            },
            onSaved: (value) {
              _senha = value!;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'E-mail',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  !value.contains('@')) {
                return 'Por favor, insira um endereço de email válido.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
