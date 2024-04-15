import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'cadastro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaLogin(),
      debugShowCheckedModeBanner: false, // Remover o banner "DEBUG"
    );
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  var _emailInserido = '';
  var _senhaInserida = '';
  final Logger _logger = Logger();
  bool _erroValidacao =
      false; // Variável para controlar se houve erro de validação

  void _enviar() async {
    setState(() {
      _erroValidacao = false; // Reinicia o estado de erro de validação
    });

    if (!_chaveForm.currentState!.validate()) {
      setState(() {
        _erroValidacao =
            true; // Define o estado de erro de validação como verdadeiro
      });
      return;
    }

    _chaveForm.currentState!.save();

    try {
      if (_emailInserido == 'admin' && _senhaInserida == 'admin') {
        //logar usuario
        _logger.d(
            'Usuário Logado. Email: $_emailInserido, Senha: $_senhaInserida');
        _exibirPopup('Login bem-sucedido', 'Usuário logado com sucesso!');
      } else {
        setState(() {
          _erroValidacao =
              true; // Define o estado de erro de validação como verdadeiro
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha na autenticação.'),
        ),
      );
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
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: _chaveForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 1,
                        bottom: 100,
                        left: 20,
                        right: 20,
                      ),
                      width: 350,
                      child: Image.asset('assets/unicv-logo-site.png'),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Usuário:',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                          errorText: _erroValidacao
                              ? 'Usuario inválido'
                              : null, // Define texto de erro e cor em caso de erro
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, insira um usuario válido.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _emailInserido = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Senha:',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                          errorText: _erroValidacao
                              ? 'Senha inválida'
                              : null, // Define texto de erro e cor em caso de erro
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Senha inválida';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _senhaInserida = value!;
                        },
                      ),
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
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _enviar,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(58, 92, 51, 1),
                  ),
                ),
                child: Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color.fromRGBO(58, 92, 51, 1),
              height: 60,
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  _irParaCadastro(context);
                },
                child: Text(
                  'Não possui uma conta? Registre-se Aqui',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
